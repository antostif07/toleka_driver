import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';

class DriverLocationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<geo.Position>? _positionStreamSubscription;

  // La variable que tout le monde écoutera
  final Rx<geo.Position?> currentUserPosition = Rx<geo.Position?>(null);

  String? _currentDriverId;

  // Méthode pour démarrer le suivi
  void startUpdating(String driverId) {
    if (_positionStreamSubscription != null) return; // Déjà en cours
    _currentDriverId = driverId;

    // Assurez-vous que les permissions sont déjà gérées avant d'appeler cette méthode
    _positionStreamSubscription = geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      currentUserPosition.value = position;
      _updateDriverLocationInFirestore(position);
    });
  }

  // Méthode pour arrêter le suivi
  void stopUpdating() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _currentDriverId = null;
    currentUserPosition.value = null;
    print("[LocationService] Arrêt du suivi de position.");
  }

  // Méthode privée pour mettre à jour Firestore
  Future<void> _updateDriverLocationInFirestore(geo.Position position) async {
    if (_currentDriverId == null) return;
    try {
      await _firestore.collection('drivers').doc(_currentDriverId).update({
        'currentLocation': GeoPoint(position.latitude, position.longitude),
        'locationTimestamp': FieldValue.serverTimestamp(),
        'currentBearing': position.heading,
      });
    } catch (e) {
      print("[LocationService] Erreur de mise à jour de la position: $e");
    }
  }

  @override
  void onClose() {
    stopUpdating();
    super.onClose();
  }
}