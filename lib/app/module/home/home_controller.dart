// lib/app/modules/home/home_controller.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;

import '../../models/driver_model.dart';
import '../../models/ride_model.dart'; // Assurez-vous que le chemin est correct
import '../../routes/app_pages.dart';
import '../../services/auth_services.dart';
import '../../services/driver_location_service.dart';
import '../../services/driver_map_service.dart';
import '../../services/location_permission_service.dart';
import 'widgets/ride_request_panel.dart';

// Fonction utilitaire pour charger l'icône depuis les assets
Future<Uint8List> loadIconFromAsset(String assetName) async {
  final ByteData byteData = await rootBundle.load(assetName);
  return byteData.buffer.asUint8List();
}

class HomeController extends GetxController {
  // --- INJECTION DES SERVICES ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationPermissionService _permissionService = Get.find();
  final DriverLocationService _locationService = Get.find();
  final DriverMapService _mapService = Get.find();

  // --- ÉTAT ---
  final Rx<Driver?> currentDriver = Rx<Driver?>(null);
  var isOnline = false.obs;
  RxList<RideModel> pendingRides = <RideModel>[].obs;
  StreamSubscription? _rideRequestsSubscription;
  StreamSubscription? _authStateSubscription;

  // --- État de l'UI ---
  RxBool isLoading = false.obs;
  var isLocationLoading = true.obs;
  var errorMessage = ''.obs;

  // --- Propriétés liées au conducteur connecté ---
  // var elapsedTime = '00:00'.obs;
  // Timer? _timer;
  // int _seconds = 0;

  // --- Propriétés Mapbox ---
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  PointAnnotation? userLocationMarker;
  Uint8List? markerImage;
  final RxBool isMapReady = false.obs;
  late Rx<CameraOptions> currentCameraOptions;
  final double _defaultZoom = 16.0;

  @override
  void onInit() {
    super.onInit();
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _authStateSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        if (currentDriver.value == null) _loadDriverData(user.uid);
      } else {
        _handleLogoutState();
      }
    });
  }

  @override
  void onClose() {
    _authStateSubscription?.cancel();
    _rideRequestsSubscription?.cancel();
    super.onClose();
  }

  void recenterMapOnUserLocation() async {
    final pos = await geo.Geolocator.getCurrentPosition();
    final point = Point(coordinates: Position(pos.longitude, pos.latitude));
    _mapService.flyTo(point, zoom: 16.0);
  }

  /// --- GESTION DU STATUT EN LIGNE ---
  void toggleOnlineStatus() async {
    if (currentDriver.value == null) return;

    // On vérifie les permissions AVANT de changer de statut
    final hasPermission = await _permissionService.checkAndRequestPermissions();
    if (!hasPermission) {
      Get.snackbar("Permission requise", "Veuillez accorder la permission de localisation pour vous mettre en ligne.");
      return;
    }

    bool newStatus = !isOnline.value;
    await _updateDriverStatusInFirestore(newStatus);
    isOnline.value = newStatus;

    if (newStatus) {
      _locationService.startUpdating(currentDriver.value!.id);
      _startListeningForRideRequests();
      Get.snackbar("Vous êtes EN LIGNE", "En attente de nouvelles courses...", backgroundColor: Colors.green);
    } else {
      _locationService.stopUpdating();
      _stopListeningForRideRequests();
      Get.snackbar("Vous êtes HORS LIGNE", "Vous ne recevrez plus de courses.", backgroundColor: Colors.orange);
    }
  }

  // --- GESTION DES COURSES ---
  void _startListeningForRideRequests() {
    if (_rideRequestsSubscription != null) return;
    print("[HomeController] Démarrage de l'écoute des courses...");

    _rideRequestsSubscription = _firestore.collection('rides').where('status', isEqualTo: 'pending').snapshots().listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        pendingRides.clear();
        return;
      }
      final rides = snapshot.docs.map((doc) => RideModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
      pendingRides.assignAll(rides);

      if (isOnline.value && pendingRides.isNotEmpty && Get.isBottomSheetOpen == false) {
        showRideRequestBottomSheet(pendingRides.first);
      }
    }, onError: (error) => print("Erreur d'écoute des courses: $error"));
  }

  void _stopListeningForRideRequests() {
    _rideRequestsSubscription?.cancel();
    _rideRequestsSubscription = null;
    pendingRides.clear();
    print("[HomeController] Arrêt de l'écoute des courses.");
  }

  void showRideRequestBottomSheet(RideModel ride) {
    if (Get.isBottomSheetOpen == true) Get.back();
    Get.bottomSheet(
      RideRequestPanel(ride: ride),
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> acceptRideRequest(RideModel request) async {
    if (currentDriver.value == null) return;
    if (Get.isBottomSheetOpen == true) Get.back();

    final rideRef = _firestore.collection('rides').doc(request.id);
    final driverRef = _firestore.collection('drivers').doc(currentDriver.value!.id);

    try {
      await _firestore.runTransaction((transaction) async {
        final rideSnapshot = await transaction.get(rideRef);
        if (!rideSnapshot.exists) throw Exception("Course annulée.");
        if (rideSnapshot.data()?['status'] != 'pending') throw Exception("Course déjà prise.");

        transaction.update(rideRef, {'status': 'accepted', 'driverId': currentDriver.value!.id, 'acceptedAt': FieldValue.serverTimestamp()});
        transaction.update(driverRef, {'currentRideId': request.id, 'status': 'in_ride'});
      });

      Get.snackbar("Course Acceptée", "Dirigez-vous vers le point de départ.", backgroundColor: Colors.green);
      Get.toNamed(Routes.rideTracking, arguments: request.id);
    } catch (e) {
      Get.snackbar("Oups !", e.toString());
    }
  }

  Future<void> rejectRideRequest(RideModel request) async {
    if (Get.isBottomSheetOpen == true) Get.back();
    pendingRides.removeWhere((r) => r.id == request.id);
    if (isOnline.value && pendingRides.isNotEmpty) {
      showRideRequestBottomSheet(pendingRides.first);
    }
  }

  // --- LOGIQUE DE LA CARTE ET LOCALISATION ---
  void onMapCreated(MapboxMap controller) async {
    await _mapService.onMapCreated(controller);

    // Centrer la carte sur la dernière position connue ou une position par défaut
    final initialPos = await geo.Geolocator.getLastKnownPosition() ?? await geo.Geolocator.getCurrentPosition();
    final point = Point(coordinates: Position(initialPos.longitude, initialPos.latitude));
    _mapService.flyTo(point);
    _mapService.updateMarkerPosition(point);
  }

  Future<void> _updateDeviceLocation({bool isInitialLoad = false}) async {
    isLocationLoading.value = true;
    try {
      geo.Position pos = await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.high);
      final newPoint = Point(coordinates: Position(pos.longitude, pos.latitude));
      CameraState? camState = await mapboxMap?.getCameraState();

      currentCameraOptions.value = CameraOptions(center: newPoint, zoom: camState?.zoom ?? _defaultZoom);
      if (isInitialLoad) mapboxMap?.flyTo(currentCameraOptions.value, MapAnimationOptions(duration: 1500));
      _updateMarkerOnMap(newPoint, iconBearing: pos.heading);
    } catch (e) {
      errorMessage.value = "Impossible d'obtenir la localisation: $e";
    } finally {
      isLocationLoading.value = false;
    }
  }

  void _updateMarkerOnMap(Point position, {double iconBearing = 0.0}) async {
    if (pointAnnotationManager == null || markerImage == null) return;
    try {
      if (userLocationMarker == null) {
        userLocationMarker = await pointAnnotationManager?.create(PointAnnotationOptions(
          geometry: position, image: markerImage, iconSize: 0.5, iconRotate: iconBearing,
        ));
      } else {
        userLocationMarker!.geometry = position;
        userLocationMarker!.iconRotate = iconBearing;
        pointAnnotationManager?.update(userLocationMarker!);
      }
    } catch (e) {
      print("Erreur de mise à jour du marqueur: $e");
    }
  }

  // --- LOGIQUE UTILITAIRE ET FIREBASE ---
  Future<void> _loadDriverData(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('drivers').doc(uid).get();
      if (docSnapshot.exists) {
        currentDriver.value = Driver.fromFirestore(docSnapshot);
        isOnline.value = currentDriver.value?.isOnline ?? false;
        if (isOnline.value) {
          _locationService.startUpdating(currentDriver.value!.id);
          _startListeningForRideRequests();
        }
      } else {
        throw Exception('Profil conducteur introuvable.');
      }
    } catch (e) {
      Get.snackbar('Erreur de profil', e.toString());
      logout();
    }
  }

  Future<void> _updateDriverStatusInFirestore(bool online) async {
    if (currentDriver.value == null) return;
    await _firestore.collection('drivers').doc(currentDriver.value!.id).set(
      {'isOnline': online, 'lastSeen': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  void _handleLogoutState() {
    currentDriver.value = null;
    isOnline.value = false;
    _locationService.stopUpdating();
    _stopListeningForRideRequests();
    Get.offAllNamed(Routes.login);
  }

  Future<void> logout() async {
    if (isOnline.value) await _updateDriverStatusInFirestore(false);
    await _auth.signOut();
  }
  // Future<void> _loadDriverData(String uid) async {
  //   isLoading.value = true;
  //   try {
  //     final docSnapshot = await _firestore.collection('drivers').doc(uid).get();
  //     if (docSnapshot.exists) {
  //       currentDriver.value = Driver.fromFirestore(docSnapshot);
  //       isOnline.value = currentDriver.value!.isOnline;
  //       if (isOnline.value && isMapReady.value) {
  //         _startLocationUpdates();
  //         _startListeningForRideRequests();
  //         _startTimer();
  //       } else if (isOnline.value) { // si le statut était 'online' mais que la carte n'est pas prête
  //         await _updateDriverStatusInFirestore(false);
  //         isOnline.value = false;
  //       }
  //     }
  //     // --- LOGIQUE DE LA CARTE ET LOCALISATION ---
  //
  // void onMapCreated(MapboxMap controller) async {
  //   mapboxMap = controller;
  //   isMapReady.value = true;
  //   if (markerImage == null) await _loadMarkerImage();
  //   pointAnnotationManager = await mapboxMap?.annotations.createPointAnnotationManager();
  //   awa else {
  //       throw Exception('Profil conducteur introuvable.');
  //     }
  //   } catch (e) {
  //     Get.snackbar('Erreur de profil', e.toString());
  //     logout();
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  //
  // Future<void> _updateDriverLocationInFirestore(geo.Position position) async {
  //   try {
  //     await _firestore.collection('drivers').doc(currentDriver.value!.id).update({
  //       'currentLocation': GeoPoint(position.latitude, position.longitude),
  //       'locationTimestamp': FieldValue.serverTimestamp(),
  //       'currentBearing': position.heading,
  //     });
  //   } catch (e) {
  //     print("Erreur de mise à jour de la position: $e");
  //   }
  // }
  //
  // Future<void> _updateDriverStatusInFirestore(bool online) async {
  //   if (currentDriver.value == null) return;
  //   try {
  //     await _firestore.collection('drivers').doc(currentDriver.value!.id).set(
  //       {'isOnline': online, 'lastSeen': FieldValue.serverTimestamp()},
  //       SetOptions(merge: true),
  //     );
  //   } catch (e) {
  //     print("Erreur de mise à jour du statut: $e");
  //   }
  // }
  //
  // void _handleLogoutState() {
  //   currentDriver.value = null;
  //   isOnline.value = false;
  //   _stopLocationUpdates();
  //   _stopListeningForRideRequests();
  //   _stopTimer();
  //   Get.offAllNamed(Routes.login);
  // }
  //
  // Future<void> logout() async {
  //   if (isOnline.value) {
  //     await _updateDriverStatusInFirestore(false);
  //   }
  //   await _auth.signOut();
  // }
  //
  // Future<void> _loadMarkerImage() async {
  //   try {
  //     markerImage = await loadIconFromAsset('assets/images/driver-location.png');
  //   } catch (e) {
  //     errorMessage.value = "Impossible de charger l'icône de localisation.";
  //   }
  // }
  //
  // void _startTimer() {
  //   _seconds = 0;
  //   _timer?.cancel();
  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     _seconds++;
  //     int minutes = _seconds ~/ 60;
  //     int seconds = _seconds % 60;
  //     elapsedTime.value = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  //   });
  // }
  //
  // void _stopTimer() {
  //   _timer?.cancel();
  //   elapsedTime.value = '00:00';
  // }
  //
}