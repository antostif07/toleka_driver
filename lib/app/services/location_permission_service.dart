import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';

class LocationPermissionService extends GetxService {
  final RxBool isPermissionGranted = false.obs;
  final RxBool isServiceEnabled = false.obs;
  final RxBool isPermanentlyDenied = false.obs;

  static LocationPermissionService get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    // On lance la vérification dès que le service est initialisé.
    checkAndRequestPermissions();
  }

  /// Vérifie l'état des services et des permissions et les demande si nécessaire.
  /// Retourne `true` si tout est en ordre, `false` sinon.
  Future<bool> checkAndRequestPermissions() async {
    // 1. Vérifier si le service de localisation est activé sur l'appareil
    isServiceEnabled.value = await geo.Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled.value) {
      Get.snackbar(
        "Service Requis",
        "Veuillez activer les services de localisation de votre appareil.",
        snackPosition: SnackPosition.BOTTOM,
      );
      // On peut proposer d'ouvrir les paramètres
      // await geo.Geolocator.openLocationSettings();
      return false;
    }

    // 2. Vérifier les permissions de l'application
    geo.LocationPermission permission = await geo.Geolocator.checkPermission();

    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        Get.snackbar("Permission Requise", "La localisation est nécessaire pour utiliser l'application.");
        isPermissionGranted.value = false;
        return false;
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      isPermanentlyDenied.value = true;
      Get.snackbar(
          "Permission Bloquée",
          "Veuillez activer manuellement la permission de localisation dans les paramètres de l'application.",
          duration: const Duration(seconds: 5),
          mainButton: TextButton(
            onPressed: () => geo.Geolocator.openAppSettings(),
            child: const Text("OUVRIR", style: TextStyle(color: Colors.white)),
          )
      );
      isPermissionGranted.value = false;
      return false;
    }

    // 3. Si on arrive ici, tout est en ordre.
    print("[LocationPermissionService] Permissions de localisation accordées.");
    isPermissionGranted.value = true;
    isPermanentlyDenied.value = false;
    return true;
  }
}