import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox_maps;

import '../../models/driver_model.dart';
import '../../models/ride_model.dart';
import '../../services/auth_services.dart';
import '../../services/driver_location_service.dart';
import '../../services/driver_map_service.dart';


class HomeController extends GetxController {
  // --- INJECTION DES SERVICES GLOBAUX ---
  final AuthService _authService = Get.find();
  final DriverLocationService _locationService = Get.find();
  final DriverMapService _mapService = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- ÉTAT DE L'UI ---
  final RxBool isOnline = false.obs;
  final RxBool isLoading = false.obs;
  final selectedTabIndex = 0.obs;

  // variable pour suivre la position du panel (0.0 = fermé, 1.0 = ouvert)
  final panelPosition = 0.0.obs;

  // --- DRIVER DATA ---
  final Rxn<Driver> driver = Rxn<Driver>();

  // --- DONNÉES DE COURSE ---
  final RxList<RideModel> pendingRides = <RideModel>[].obs;
  StreamSubscription? _rideRequestsSubscription;

  // --- ABONNEMENTS AUX SERVICES ---
  StreamSubscription? _driverStatusSubscription;
  StreamSubscription? _locationSubscription;

  // --- PROPRIÉTÉS DE LA CARTE (LOCALES À CETTE PAGE) ---
  mapbox_maps.MapboxMap? mapboxMap;

  // --- STATISTIQUES ---
  final RxString dailyEarnings = "0 CDF".obs;
  final RxString timeOnline = "0h 0m".obs;
  final RxInt ridesCompleted = 0.obs;
  // Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  void _initialize() async {
  // // On attend que le profil du chauffeur soit chargé par l'AuthService
  // // 'once' attend que la condition soit vraie, puis se désabonne.
  //   once(currentDriver, (Driver? driver) {
  //     if (driver != null) {
  //       // Le profil est chargé, on peut initialiser l'état de isOnline
  //       isOnline.value = driver.isOnline;
  //
  //       // Si le chauffeur était déjà en ligne, on active les services
  //       if (isOnline.value) {
  //         _activateOnlineServices();
  //       }
  //     }
  //   }, condition: () => _authService.currentDriver != null);
  }

  @override
  void onClose() {
    _driverStatusSubscription?.cancel();
    _locationSubscription?.cancel();
    _rideRequestsSubscription?.cancel();
    super.onClose();
  }

    /// Appelée par le bouton "Go Online" / "Go Offline"
  void toggleOnlineStatus() async {
    if (_authService.currentDriver == null) return;
    if (isLoading.value) return;

    try {
      // 1. Démarrer le chargement
      isLoading.value = true;

      // 2. SIMULATION D'UN APPEL RÉSEAU
      // Ici, vous mettriez votre logique pour appeler le serveur
      // (par ex: mettre à jour un champ dans Firestore, appeler une Cloud Function...)
      await Future.delayed(const Duration(seconds: 2));

      // 3. Mettre à jour le statut
      // On utilise l'état inverse de l'état actuel
      isOnline.value = !isOnline.value;

      // Ici, vous pouvez ajouter un snackbar de confirmation si vous le souhaitez
      Get.snackbar(
        'Statut mis à jour',
        isOnline.value ? 'Vous êtes maintenant en ligne.' : 'Vous êtes maintenant hors ligne.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black54,
        colorText: Colors.white,
      );

    } catch (e) {
      // Gérer les erreurs
      Get.snackbar('Erreur', 'Impossible de changer votre statut. Veuillez réessayer.');
    } finally {
      // 4. Arrêter le chargement, que ce soit un succès ou un échec
      isLoading.value = false;
    }
  }

  /// changer l'onglet
  void changeTabIndex(int index) {
    selectedTabIndex.value = index;
  }

  /// mettre à jour la position
  void updatePanelPosition(double position) {
    panelPosition.value = position;
  }

  /// Appelée par le MapWidget de la HomeScreen.
  void onMapCreated(mapbox_maps.MapboxMap controller) async {
    mapboxMap = controller;

    // // Démarrer le suivi de la position et mettre à jour le marqueur
    // _locationService.currentUserPosition.listen((position) {
    //   if (position != null) {
    //     final point = Point(coordinates: Position(position.longitude, position.latitude));
    //     _updateDriverMarker(point, bearing: position.heading);
    //   }
    // });
  }

  /// Démarre tous les services nécessaires quand le chauffeur est en ligne.
  void _activateOnlineServices() {
    print("[HomeController] Activation des services en ligne...");
    // 1. Démarrer l'écoute de la position
    _locationSubscription =
        _locationService.currentUserPosition.listen((position) {
          if (position != null) {
            final point = mapbox_maps.Point(
                coordinates: mapbox_maps.Position(position.longitude, position.latitude));
            // 2. Mettre à jour la carte via le MapService
            _mapService.updateMarkerPosition(point, bearing: position.heading);

            // 3. Mettre à jour Firestore via un service dédié (ou directement)
            _updateDriverLocationInFirestore(position);
          }
        });
    // 4. Démarrer l'écoute des courses
    _startListeningForRideRequests();
  }

  /// Arrête tous les services quand le chauffeur se met hors ligne.
  void _deactivateOnlineServices() {
    print("[HomeController] Désactivation des services en ligne...");
    _locationSubscription?.cancel();
    _rideRequestsSubscription?.cancel();
    _mapService.removeUserMarker(); // Nouvelle méthode dans MapService
  }

  /// Centre la carte sur la position actuelle du chauffeur.
  void recenterMapOnUserLocation() {
    final lastPosition = _locationService.currentUserPosition.value;
    if (lastPosition != null) {
      _mapService.flyTo(mapbox_maps.Point(coordinates: mapbox_maps.Position(lastPosition.longitude, lastPosition.latitude)));
    }
  }

  // --- Logique de gestion des courses (reste la même) ---
  void _startListeningForRideRequests() { /* ... / }
void _stopListeningForRideRequests() { / ... / }
Future<void> acceptRideRequest(RideModel request) async { / ... */ }
// ...
// --- Logique de mise à jour Firestore ---
  Future<void> _updateDriverLocationInFirestore(geo.Position position) async {
    if (_authService.currentDriver == null) return;
    await _firestore.collection('drivers').doc(_authService.currentDriver!.id).update({
      'currentLocation': GeoPoint(position.latitude, position.longitude),
      'currentBearing': position.heading,
    });
  }

  // Gère la déconnexion
  Future<void> logout() async {
    if (isOnline.value) {
      await _firestore.collection('drivers').doc(_authService.currentDriver!.id).update({'isOnline': false});
    }
    _authService.logout();
  }
}