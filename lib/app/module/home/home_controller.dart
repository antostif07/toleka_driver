import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Pour Firebase Auth
import 'package:flutter/material.dart'; // Pour Colors, Snackbars, etc.
import 'package:flutter/services.dart'; // Nécessaire pour rootBundle
import 'package:get/get.dart'; // Pour GetX
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // Pour Mapbox
import 'package:geolocator/geolocator.dart' as geo;

import '../../models/driver_model.dart';
import '../../models/ride_model.dart';
import '../../routes/app_pages.dart';
import '../../services/auth_services.dart'; // Pour Geolocator (avec alias)

// Fonction utilitaire pour charger l'icône depuis les assets (déclarée en dehors de la classe)
Future<Uint8List> loadIconFromAsset(String assetName) async {
  final ByteData byteData = await rootBundle.load(assetName);
  return byteData.buffer.asUint8List();
}

class HomeController extends GetxController {
  // --- Instances Firebase ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Pour gérer l'abonnement aux changements d'état d'authentification
  StreamSubscription<User?>? _authStateSubscription;
  RxBool isLoading = false.obs;

  // --- Propriétés liées au conducteur connecté ---
  // C'est la variable clé qui contiendra les données complètes du conducteur
  final Rx<Driver?> currentDriver = Rx<Driver?>(null);

  // --- Propriétés Mapbox ---
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  PointAnnotation? userLocationMarker;
  Uint8List? markerImage; // L'image du marqueur chargée en mémoire

  // Variable réactive pour indiquer si la carte est prête à être manipulée
  final RxBool isMapReady = false.obs;

  // Options de caméra pour la carte (réactives)
  late Rx<CameraOptions> currentCameraOptions;
  final Point _defaultDevicePosition = Point(coordinates: Position(2.3522, 48.8566)); // Paris
  final double _defaultZoom = 16.0; // Zoom par défaut

  // --- Propriétés de l'état du conducteur et de la localisation ---
  var isLocationLoading = true.obs; // Spécifique pour l'acquisition de la première localisation
  var errorMessage = ''.obs; // Messages d'erreur génériques
  var isOnline = false.obs; // Statut du conducteur (en ligne/hors ligne)

  // --- Timer pour le statut en ligne ---
  Timer? _timer;
  var elapsedTime = '00:00'.obs;
  int _seconds = 0;

  // --- Abonnements aux Streams ---
  StreamSubscription<geo.Position>? _positionStreamSubscription;
  StreamSubscription? _rideRequestsSubscription;
  RxList<RideModel> pendingRideRequests = <RideModel>[].obs; // Demandes de course en attente

  @override
  void onInit() {
    super.onInit();

    // Initialiser les options de la caméra avec une position par défaut
    currentCameraOptions = CameraOptions(
      center: _defaultDevicePosition,
      zoom: _defaultZoom,
      pitch: 0,
      bearing: 0,
    ).obs;

    // Charger l'image du marqueur une seule fois au démarrage du contrôleur
    _loadMarkerImage();

    // Écouter les changements d'état d'authentification de Firebase
    _authStateSubscription = _auth.authStateChanges().listen((user) async {
      if (user != null) {
        // Utilisateur connecté, charger ses données de conducteur
        await _loadDriverData(user.uid); // Attendre le chargement complet des données du driver
        // La logique de démarrage des services (localisation, requêtes) est dans _loadDriverData
      } else {
        // Utilisateur déconnecté ou session expirée
        currentDriver.value = null; // Vider les données du conducteur
        isOnline.value = false; // Mettre hors ligne
        _stopLocationUpdates(); // Arrêter le suivi GPS
        _stopListeningForRideRequests(); // Arrêter l'écoute des requêtes
        _stopTimer();
        Get.offAllNamed(Routes.login); // Rediriger vers l'écran de connexion
      }
    });

    // 2. Vérifier si un utilisateur est déjà connecté au moment où le contrôleur est créé
    // C'est utile pour la persistance de session (utilisateur déjà loggé au démarrage de l'app)
    if (_auth.currentUser != null && currentDriver.value == null) {
      print("Utilisateur déjà connecté au démarrage du contrôleur. Chargement du profil...");
      _loadDriverData(_auth.currentUser!.uid);
    }
  }

  @override
  void onClose() {
    // Annuler tous les abonnements pour éviter les fuites de mémoire
    _timer?.cancel();
    _authStateSubscription?.cancel();
    _positionStreamSubscription?.cancel();
    _rideRequestsSubscription?.cancel();
    // Les contrôleurs Mapbox n'ont pas de méthode dispose() directe dans ce SDK
    super.onClose();
    print("HomeController fermé.");
  }

  /// Met à jour l'URL de la photo de profil du conducteur dans Firestore et en local.
  Future<void> updateDriverProfilePicture(String newUrl) async {
    if (currentDriver.value == null) return;

    isLoading.value = true; // Indiquer un chargement global si pertinent
    try {
      // Mettre à jour l'objet Driver localement pour une réactivité immédiate
      currentDriver.value = currentDriver.value!.copyWith(profilePictureUrl: newUrl);

      // Mettre à jour le document Firestore
      await _firestore.collection('drivers').doc(currentDriver.value!.id).update({
        'profilePictureUrl': newUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("URL de photo de profil mise à jour dans Firestore pour ${currentDriver.value!.id}");
    } catch (e) {
      print("Erreur de mise à jour de l'URL de photo de profil: $e");
      Get.snackbar("Erreur", "Impossible de mettre à jour votre photo de profil.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error);
      // Optionnel: Revenir à l'ancienne URL si la mise à jour Firestore échoue
      // currentDriver.value = currentDriver.value!.copyWith(profilePictureUrl: currentDriver.value!.profilePictureUrl);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDriverStatsOnCompletion(RideModel completedRide) async {
    if (currentDriver.value == null) return;

    try {
      // Mettre à jour les stats locales et déclencher la réactivité
      currentDriver.value = currentDriver.value!.copyWith(
        totalRides: currentDriver.value!.totalRides + 1,
        dailyEarnings: currentDriver.value!.dailyEarnings + completedRide.estimatedPrice,
      );

      // Mettre à jour Firestore
      // await _firestore.collection('drivers').doc(currentDriver.value!.id).update({
      //   'totalRides': FieldValue.increment(1),
      //   'dailyEarnings': FieldValue.increment(completedRide.estimatedPrice),
      //   'updatedAt': FieldValue.serverTimestamp(),
      // });
      Get.snackbar("Course Terminée !", "Vos gains ont été mis à jour.", snackPosition: SnackPosition.TOP);
    } catch (e) {
      print("Erreur de mise à jour des stats du driver: $e");
      Get.snackbar("Erreur", "Impossible de mettre à jour vos gains.", snackPosition: SnackPosition.BOTTOM);
      // Optionnel: annuler la mise à jour locale si Firestore échoue pour la cohérence
      // currentDriver.value = currentDriver.value!.copyWith(...)
    }
  }

  // --- Méthodes de Gestion du Timer ---
  void _startTimer() {
    _seconds = 0;
    _timer?.cancel(); // Annule un timer précédent s'il existe
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      int minutes = _seconds ~/ 60;
      int seconds = _seconds % 60;
      elapsedTime.value = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    });
    print("Timer démarré.");
  }

  void _stopTimer() {
    _timer?.cancel();
    elapsedTime.value = '00:00';
    print("Timer arrêté.");
  }

  // --- Méthodes de Gestion de la Carte Mapbox ---

  // Charge l'image du marqueur depuis les assets
  Future<void> _loadMarkerImage() async {
    try {
      markerImage = await loadIconFromAsset('assets/images/driver-location.png');
      print("Image du marqueur chargée.");
    } catch (e) {
      print("Erreur lors du chargement de l'image du marqueur: $e");
      errorMessage.value = "Impossible de charger l'icône de localisation.";
    }
  }

  // Appelé lorsque la carte Mapbox est prête
  void onMapCreated(MapboxMap controller) async {
    mapboxMap = controller;
    print("MapboxMap créé.");

    // S'assurer que l'image du marqueur est chargée
    if (markerImage == null) {
      await _loadMarkerImage();
    }

    pointAnnotationManager = await mapboxMap?.annotations.createPointAnnotationManager();
    print("PointAnnotationManager créé.");

    // Indiquer que la carte est prête
    isMapReady.value = true;

    // Tenter d'obtenir la localisation initiale et de centrer la carte
    // Ceci est appelé APRES que la carte et les marqueurs soient prêts.
    await _updateDeviceLocation(isInitialLoad: true);

    // Si le conducteur est déjà en ligne (suite à _loadDriverData() et persistance), démarrer le stream de localisation
    if (isOnline.value) {
      _startLocationUpdates();
      _startListeningForRideRequests();
    }
  }

  // Met à jour (ou crée) le marqueur de la position de l'utilisateur sur la carte
  void _updateMarkerOnMap(Point position, {double iconBearing = 0.0}) async {
    if (pointAnnotationManager == null || markerImage == null) {
      print("Manager de marqueurs ou image non prêts, ne peut pas mettre à jour le marqueur.");
      return;
    }
    print("DEBUG_MARKER: Appel à _updateMarkerOnMap. userLocationMarker est: ${userLocationMarker == null ? 'NULL (va créer)' : 'EXISTANT (va maj)'}");

    try {
      if (userLocationMarker == null) {
        print("DEBUG_MARKER: Création effective du marqueur.");
        final options = PointAnnotationOptions(
          geometry: position,
          image: markerImage,
          iconSize: 0.5, // Ajustez la taille si nécessaire
          iconRotate: iconBearing,
        );
        userLocationMarker = await pointAnnotationManager?.create(options);
        print("Marqueur créé à la position : ${position.coordinates}");
      } else {
        print("DEBUG_MARKER: Mise à jour effective du marqueur existant.");
        userLocationMarker!.geometry = position;
        userLocationMarker!.iconRotate = iconBearing;
        pointAnnotationManager?.update(userLocationMarker!);
        print("Marqueur mis à jour à la position : ${position.coordinates}, Icon Bearing: $iconBearing");
      }
      print("DEBUG_MARKER: Marqueur à: ${position.coordinates.lng}, ${position.coordinates.lat}, Rotate: $iconBearing");
    } catch (e) {
      print("Erreur lors de la mise à jour du marqueur: $e");
      errorMessage.value = "Erreur de mise à jour du marqueur: $e";
    }
  }

  // Obtenir la localisation de l'appareil et centrer la carte
  Future<void> _updateDeviceLocation({bool isInitialLoad = false}) async {
    isLocationLoading.value = true;
    errorMessage.value = '';

    // Vérifier les permissions et le service de localisation via AuthService
    // AuthService est censé avoir déjà redirigé ou affiché des dialogues si ça ne va pas.
    // Cette vérification ici est une sécurité redondante, mais utile si l'utilisateur change les perms en cours d'app.
    if (!AuthService.to.isLocationServiceEnabled.value ||
        (AuthService.to.locationPermission.value != geo.LocationPermission.whileInUse &&
            AuthService.to.locationPermission.value != geo.LocationPermission.always)) {
      errorMessage.value = 'Services de localisation ou permissions non accordées.';
      isLocationLoading.value = false;
      // Optionnel: proposer à l'utilisateur de réouvrir les paramètres ici
      // AuthService.to.showLocationServiceDisabledDialog(); ou AuthService.to.showPermissionDeniedDialog
      return;
    }

    try {
      geo.Position currentGeoPosition = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high);

      final newPoint = Point(coordinates: Position(currentGeoPosition.longitude, currentGeoPosition.latitude));

      // Obtenir le zoom actuel de la caméra de manière asynchrone pour le conserver
      // Uniquement si mapboxMap est disponible (il doit l'être ici car isMapReady est vérifié)
      CameraState? currentCameraState = await mapboxMap?.getCameraState();
      double zoomToUse = currentCameraState?.zoom ?? _defaultZoom;

      double cameraBearing =  0.0;

      double iconBearing = currentGeoPosition.heading ?? 0.0;

      currentCameraOptions.value = CameraOptions(
        center: newPoint,
        zoom: zoomToUse,
        pitch: 0,
        bearing: cameraBearing,
      );

      _updateMarkerOnMap(newPoint, iconBearing: iconBearing);

      if (mapboxMap != null) {
        mapboxMap?.flyTo(currentCameraOptions.value, MapAnimationOptions(duration: 1500));
        print("Carte animée vers la nouvelle position: ${newPoint.coordinates.toString()}");
      } else {
        print("MapboxMap non disponible pour l'animation dans _updateDeviceLocation (après avoir obtenu la position).");
      }
    } catch (e) {
      errorMessage.value = "Impossible d'obtenir la localisation: $e";
      print("Erreur dans _updateDeviceLocation: $e");
      // Fallback: si l'obtention de la localisation échoue, centrer sur la position par défaut
      if (mapboxMap != null) {
        mapboxMap?.flyTo(CameraOptions(center: _defaultDevicePosition, zoom: _defaultZoom), MapAnimationOptions(duration: 1000));
      }
    } finally {
      isLocationLoading.value = false;
    }
  }

  // Recentre la carte sur la position actuelle de l'utilisateur
  Future<void> recenterMapOnUserLocation() async {
    // Vérifier que la carte est prête avant de tenter de recentrer
    if (!isMapReady.value || mapboxMap == null) {
      Get.snackbar("Carte non prête", "Veuillez patienter pendant le chargement de la carte.", snackPosition: SnackPosition.BOTTOM);
      return;
    }
    await _updateDeviceLocation(isInitialLoad: false);
  }

  // Démarre l'écoute des mises à jour de position continues
  void _startLocationUpdates() async {
    // Vérification des permissions et services via AuthService
    if (!AuthService.to.isLocationServiceEnabled.value ||
        (AuthService.to.locationPermission.value != geo.LocationPermission.whileInUse &&
            AuthService.to.locationPermission.value != geo.LocationPermission.always)) {
      Get.snackbar("Localisation inactive", "Veuillez activer la localisation et les permissions.",
          snackPosition: SnackPosition.BOTTOM);
      isOnline.value = false;
      return;
    }

    if (_positionStreamSubscription != null) return; // Empêche les abonnements multiples

    const geo.LocationSettings locationSettings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.high,
      distanceFilter: 10, // Mètres (met à jour la position toutes les 10m)
    );

    _positionStreamSubscription = geo.Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (geo.Position position) async { // Callback rendu async
        final newPoint = Point(coordinates: Position(position.longitude, position.latitude));

        _updateMarkerOnMap(newPoint); // Mettre à jour le marqueur

        // Obtenir le zoom actuel de la caméra de manière asynchrone pour le conserver
        CameraState? currentCameraState = await mapboxMap?.getCameraState();
        double zoomToUse = currentCameraState?.zoom ?? _defaultZoom;

        double bearingToUse = 0.0;

        // Animer la caméra
        mapboxMap?.flyTo(
          CameraOptions(center: newPoint, zoom: zoomToUse, bearing: bearingToUse),
          MapAnimationOptions(duration: 1000),
        );

        // Mettre à jour la position du conducteur dans Firestore (si connecté et en ligne)
        if (currentDriver.value != null && isOnline.value) {
          _updateDriverLocationInFirestore(position);
        }
      },
      onError: (error) {
        print("Erreur de flux de position: $error");
        errorMessage.value = "Erreur de localisation en temps réel: $error";
        Get.snackbar("Erreur", "Problème de localisation en temps réel. Vous êtes peut-être hors ligne.",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      },
    );
    print("Flux de localisation démarré.");
  }

  // Arrête l'écoute des mises à jour de position
  void _stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    // Supprimer le marqueur de la carte quand on arrête le suivi
    if (pointAnnotationManager != null && userLocationMarker != null) {
      pointAnnotationManager?.delete(userLocationMarker!);
      userLocationMarker = null;
    }
    print("Flux de localisation arrêté.");
  }


  // --- Fonctions de Firebase (Réintroduites) ---

  /// Charge les données du conducteur depuis Firestore en utilisant l'UID.
  Future<void> _loadDriverData(String uid) async {
    isLoading.value = true;
    print("Chargement des données du driver pour UID: $uid");
    try {
      final docSnapshot = await _firestore.collection('drivers').doc(uid).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        currentDriver.value = Driver.fromFirestore(docSnapshot);

        isOnline.value = currentDriver.value!.isOnline;

        // Si le conducteur était enregistré comme "en ligne" lors du dernier démarrage
        // et que la carte est prête (isMapReady)

        if (isOnline.value && isMapReady.value) {
          _startLocationUpdates(); // Redémarrer le tracking de localisation
          _startListeningForRideRequests(); // Redémarrer l'écoute des requêtes
          _startTimer(); // Redémarrer le timer
        } else {
          // Si le statut était hors ligne ou les prérequis localisation/carte non ok, on reste hors ligne
          isOnline.value = false;
          await _updateDriverStatusInFirestore(false); // S'assurer que le statut est bien hors ligne en BDD
        }
      } else {
        // L'utilisateur est authentifié mais son document Driver n'existe pas
        Get.snackbar(
          'Erreur de profil', 'Profil conducteur introuvable. Veuillez contacter l\'administration.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        logout(); // Déconnecter l'utilisateur, car le profil est corrompu ou manquant
      }
    } catch (e) {
      Get.snackbar(
        'Erreur de chargement', 'Impossible de charger votre profil. Veuillez réessayer.',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      print("Erreur de chargement du profil conducteur: $e");
      logout();
    } finally {
      isLoading.value = false;
    }
  }

  // Met à jour la position GPS du conducteur dans Firestore
  Future<void> _updateDriverLocationInFirestore(geo.Position position) async {
    if (currentDriver.value == null) return;
    try {
      await _firestore.collection('drivers').doc(currentDriver.value!.id).update({
        'currentLocation': GeoPoint(position.latitude, position.longitude),
        'locationTimestamp': FieldValue.serverTimestamp(),
        'currentBearing': position.heading, // <-- AJOUTER LA MISE À JOUR DU BEARING
        'speed': position.speed, // Optionnel: ajouter aussi la vitesse
      });
    } catch (e) {
      print("Erreur de mise à jour de la position pour ${currentDriver.value!.id} : $e");
    }
  }

  // Met à jour le statut en ligne/hors ligne du conducteur dans Firestore
  Future<void> _updateDriverStatusInFirestore(bool online) async {
    if (currentDriver.value == null) return;
    try {
      await _firestore.collection('drivers').doc(currentDriver.value!.id).set(
        {'isOnline': online, 'lastSeen': FieldValue.serverTimestamp(), 'email': _auth.currentUser?.email},
        SetOptions(merge: true), // 'merge: true' pour ne pas écraser les autres champs
      );
    } catch (e) {
      print("Erreur de mise à jour du statut pour ${currentDriver.value!.id} : $e");
      Get.snackbar("Erreur de synchronisation", "Impossible de mettre à jour le statut.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // Bascule le statut en ligne/hors ligne du conducteur
  void toggleOnlineStatus() async {
    // Vérifier que le conducteur est bien chargé
    if (currentDriver.value == null) {
      Get.snackbar("Erreur", "Profil chauffeur non chargé.", snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // Vérifier que la carte est prête pour les opérations de localisation
    if (!isMapReady.value || mapboxMap == null) {
      Get.snackbar("Carte non prête", "Veuillez patienter pendant le chargement de la carte.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Vérifier les permissions de localisation via AuthService AVANT de changer le statut
    if (!AuthService.to.isLocationServiceEnabled.value ||
        (AuthService.to.locationPermission.value != geo.LocationPermission.whileInUse &&
            AuthService.to.locationPermission.value != geo.LocationPermission.always)) {
      Get.snackbar("Action impossible", "Veuillez activer la localisation et accorder les permissions.",
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 4));
      return; // Ne pas changer le statut si les prérequis ne sont pas là
    }

    bool newStatus = !isOnline.value; // Déterminer le nouveau statut
    isOnline.value = newStatus; // Mettre à jour l'état réactif pour l'UI

    try {
      await _updateDriverStatusInFirestore(newStatus); // Mettre à jour dans Firestore

      if (newStatus) {
        _startLocationUpdates(); // Démarrer le suivi GPS
        _startListeningForRideRequests(); // Commencer à écouter les requêtes
        _startTimer(); // Démarrer le timer
        Get.snackbar("Statut", "Vous êtes maintenant EN LIGNE",
            snackPosition: SnackPosition.TOP, backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        _stopLocationUpdates(); // Arrêter le suivi GPS
        _stopListeningForRideRequests(); // Arrêter l'écoute des requêtes
        _stopTimer(); // Arrêter le timer
        Get.snackbar("Statut", "Vous êtes maintenant HORS LIGNE",
            snackPosition: SnackPosition.TOP, backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      // En cas d'erreur de mise à jour Firestore, annuler le changement d'état UI
      isOnline.value = !newStatus;
      Get.snackbar(
        "Erreur", "Impossible de changer le statut. Veuillez réessayer.",
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      print("Erreur de mise à jour du statut online: $e");
    }
  }


  // --- LOGIQUE DES REQUÊTES DE COURSE (Réintroduites) ---
  void _startListeningForRideRequests() {
    // if (_rideRequestsSubscription != null) return;
    // // La requête doit aussi filtrer par les demandes proches du chauffeur et non assignées
    // Query rideRequestsQuery = _firestore.collection('rideRequests')
    //     .where('status', isEqualTo: 'pending'); // Ajouter .where('assignedDriverId', isNull: true) si nécessaire
    //
    // _rideRequestsSubscription = rideRequestsQuery.snapshots().listen((snapshot) {
    //   List<RideModel> requests = snapshot.docs.map((doc) => RideModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
    //   pendingRideRequests.assignAll(requests);
    //
    //   // Notifier l'utilisateur s'il est en ligne et qu'il y a de nouvelles demandes
    //   if (requests.isNotEmpty && isOnline.value) {
    //     Get.snackbar("Nouvelle(s) Demande(s)!", "${requests.length} en attente.",
    //         snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 3));
    //   }
    // }, onError: (error) {
    //   print("Erreur d'écoute des demandes: $error");
    //   pendingRideRequests.clear();
    //   Get.snackbar("Erreur", "Impossible de charger les demandes de course.",
    //       snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Colors.white);
    // });
    // print("Écoute des demandes de course démarrée.");
  }

  void _stopListeningForRideRequests() {
    _rideRequestsSubscription?.cancel();
    _rideRequestsSubscription = null;
    pendingRideRequests.clear();
    print("Écoute des demandes de course arrêtée.");
  }

  // Accepter une demande de course
  Future<void> acceptRideRequest(RideModel request) async {
    if (currentDriver.value == null) return;
    isLoading.value = true;
    try {
      await _firestore.collection('rideRequests').doc(request.id).update({
        'status': 'accepted',
        'assignedDriverId': currentDriver.value!.id,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      pendingRideRequests.removeWhere((r) => r.id == request.id);
      Get.snackbar("Course Acceptée", "Vers ${request.pickupAddress}.",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.lightGreen, colorText: Colors.black);
      // TODO: Naviguer vers un écran de course active: Get.toNamed(Routes.ACTIVE_RIDE, arguments: request);
    } catch (e) {
      Get.snackbar("Erreur", "Impossible d'accepter la course.", snackPosition: SnackPosition.BOTTOM);
      print("Erreur acceptation course: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Rejeter une demande de course
  Future<void> rejectRideRequest(RideModel request) async {
    isLoading.value = true;
    try {
      // await _firestore.collection('rideRequests').doc(request.id).update({
      //   'rejectedBy': FieldValue.arrayUnion([currentDriver.value!.id]),
      // });
      // pendingRideRequests.removeWhere((r) => r.id == request.id);
      // Get.snackbar("Course Refusée", "Demande retirée.", snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de refuser la course.", snackPosition: SnackPosition.BOTTOM);
      print("Erreur rejet course: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Autres fonctions d'action
  void viewRideRequests() {
    if (pendingRideRequests.isEmpty) {
      Get.snackbar("Demandes", "Aucune demande en attente.", snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("Demandes", "${pendingRideRequests.length} demande(s) affichée(s).", snackPosition: SnackPosition.BOTTOM);
    }
  }

  void viewEarnings() {
    Get.snackbar("Fonctionnalité", "Écran des gains (à implémenter).", snackPosition: SnackPosition.BOTTOM);
  }

  // Gère la déconnexion de l'utilisateur
  Future<void> logout() async {
    isLoading.value = true;
    if (isOnline.value) {
      _stopLocationUpdates();
      _stopListeningForRideRequests();
      _stopTimer();
      await _updateDriverStatusInFirestore(false);
    }
    await _auth.signOut(); // Déconnexion de Firebase Auth
    // La redirection vers la page de login est gérée par l'écouteur authStateChanges
    isLoading.value = false;
  }
}