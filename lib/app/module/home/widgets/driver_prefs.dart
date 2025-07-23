import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class DriverPrefs extends StatelessWidget {
  const DriverPrefs({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding horizontal pour l'aligner avec les autres cartes
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        // InkWell permet d'avoir l'effet d'ondulation au clic sur toute la carte
        child: InkWell(
          onTap: () {
            Get.toNamed(Routes.driverPreferences);
          },
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            // L'icône de réglages à gauche. `Icons.tune` est très similaire
            leading: const Icon(Icons.tune, color: Colors.black87),
            title: const Text(
              'Préférences de conduite',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            // La flèche vers la droite
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}