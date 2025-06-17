// lib/app/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart'; // Pour les snackbars/dialogues

import '../routes/app_pages.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool _isReady = false.obs;
  bool get isReady => _isReady.value;

  RxBool isLocationServiceEnabled = false.obs;
  Rx<LocationPermission> locationPermission = LocationPermission.denied.obs;

  @override
  void onInit() {
    super.onInit();
    print("AuthService initialized, starting initial checks...");
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    // 1. Vérifier le service de localisation
    isLocationServiceEnabled.value = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled.value) {
      // Si le service est désactivé, montrer un dialogue pour l'activer
      _showLocationServiceDisabledDialog();
      return; // Ne pas continuer tant que ce n'est pas résolu
    }

    // 2. Vérifier et demander les permissions de localisation
    locationPermission.value = await Geolocator.checkPermission();

    if (locationPermission.value == LocationPermission.denied) {
      locationPermission.value = await Geolocator.requestPermission();
      if (locationPermission.value == LocationPermission.denied) {
        // Si l'utilisateur refuse la permission directement
        _showPermissionDeniedDialog(
          "La permission de localisation est requise pour utiliser cette application. Veuillez l'accorder.",
          allowOpenSettings: true, // Offrir d'ouvrir les paramètres de l'application
        );
        return;
      }
    }

    if (locationPermission.value == LocationPermission.deniedForever) {
      // Si la permission est définitivement refusée
      _showPermissionDeniedDialog(
        "La permission de localisation est définitivement refusée. Veuillez l'activer manuellement dans les paramètres de l'application.",
        allowOpenSettings: true,
      );
      return;
    }

    // 3. Toutes les vérifications passées : l'application est prête
    _isReady.value = true;
    _redirectToAppropriateScreen();
  }

  // Nouveau dialogue pour le service de localisation désactivé
  void _showLocationServiceDisabledDialog() {
    Get.defaultDialog(
      title: "Service de Localisation Désactivé",
      middleText: "Le service de localisation est requis pour cette application. Veuillez l'activer dans les paramètres système.",
      textConfirm: "Ouvrir les paramètres",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await Geolocator.openLocationSettings(); // Ouvre les paramètres de localisation
        Get.back(); // Ferme le dialogue
        // On relance la vérification après que l'utilisateur soit revenu
        // Pour cela, on peut s'abonner au cycle de vie de l'application
        // ou simplement relancer _checkAndRequestPermissions après un court délai
        Future.delayed(const Duration(seconds: 1), () => _checkAndRequestPermissions());
      },
      textCancel: "Fermer l'application",
      cancelTextColor: Get.theme.colorScheme.error,
      onCancel: () {
        // SystemNavigator.pop(); // Ferme l'application
      },
      barrierDismissible: false,
    );
  }

  // Dialogue mis à jour pour les permissions refusées
  void _showPermissionDeniedDialog(String message, {bool allowOpenSettings = false}) {
    Get.defaultDialog(
      title: "Permission Requise",
      middleText: message,
      textConfirm: allowOpenSettings ? "Ouvrir les paramètres de l'app" : "OK",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // Ferme le dialogue
        if (allowOpenSettings) {
          await Geolocator.openAppSettings(); // Ouvre les paramètres de l'application
          // On relance la vérification après que l'utilisateur soit revenu
          Future.delayed(const Duration(seconds: 1), () => _checkAndRequestPermissions());
        }
      },
      textCancel: "Fermer l'application",
      cancelTextColor: Get.theme.colorScheme.error,
      onCancel: () {
        SystemNavigator.pop(); // Ferme l'application
      },
      barrierDismissible: false,
    );
  }

  void _redirectToAppropriateScreen() {
    if (_auth.currentUser != null) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.login);
    }
  }

  static AuthService get to => Get.find<AuthService>();
}