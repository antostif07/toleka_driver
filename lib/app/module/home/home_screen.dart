import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:toleka_driver/app/module/home/home_bottomsheet_content.dart';
import 'package:toleka_driver/app/routes/app_pages.dart';

import '../../models/driver_model.dart';
import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  static const double bottomSheetHeight = 250.0;
  static const double buttonBottomMargin = 40.0;
  static const double buttonHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final driver = controller.currentDriver.value;
        final errorMessage = controller.errorMessage.value;
        final isOnline = controller.isOnline.value;
        final hasPendingRides = controller.pendingRides.isNotEmpty;

        if (driver == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMessage.isNotEmpty) {
          return Center(child: Text("Erreur: $errorMessage"));
        }

        return _buildContent(
          context: context,
          driver: driver,
          isOnline: isOnline,
          hasPendingRides: hasPendingRides,
          onMapCreated: controller.onMapCreated, // <-- On passe la fonction
          onRecenterTap: controller.recenterMapOnUserLocation, // <-- On passe la fonction
          onProfileTap: () => Get.toNamed(Routes.profile), // <-- On passe la fonction
        );
      }),
    );
  }
}

Widget _buildContent({
  required BuildContext context,
  required Driver driver,
  required bool isOnline,
  required bool hasPendingRides,
  required void Function(MapboxMap) onMapCreated, // <-- Type du callback
  required VoidCallback onRecenterTap, // <-- Type du callback
  required VoidCallback onProfileTap,  // <-- Type du callback
}) {
  return Stack(
    alignment: Alignment.center,
    children: [
      // 1. La carte en arrière-plan
      MapWidget(
        key: const ValueKey("mapboxMap"),
        styleUri: MapboxStyles.MAPBOX_STREETS,
        onMapCreated: onMapCreated,
        textureView: true,
      ),
      // Positioned(
      //   // Positionnement du bouton (en haut à droite, sous le cadre de profil)
      //   top: 120, // Ajustez cette valeur pour qu'elle soit sous le cadre de profil
      //   right: 16, // Même alignement à droite que le cadre de profil
      //   child: FloatingActionButton(
      //     mini: true, // Pour un bouton plus petit (comme sur l'image)
      //     onPressed: controller.recenterMapOnUserLocation,
      //     backgroundColor: Colors.white, // Fond blanc
      //     foregroundColor: Colors.black, // Icône noire
      //     elevation: 4,
      //     shape: const CircleBorder(), // S'assurer qu'il est bien rond
      //     child: const Icon(Icons.my_location), // Icône de localisation
      //   ),
      // ),

      Positioned(
        top: 40, // Marge du haut (ajustez si nécessaire, par exemple si vous avez une barre d'état transparente)
        right: 8, // Marge de droite
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Plus arrondi pour ressembler à l'image
          ),
          color: Colors.white, // Fond blanc
          child: InkWell( // Utiliser InkWell pour l'effet de tap et le rend cliquable
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Get.toNamed(Routes.profile); // Naviguer vers la page de profil
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Occupe juste l'espace nécessaire
                children: [
                  // Colonne pour le texte (montant et commandes)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end, // Aligner le texte à droite
                    children: [
                      Text(
                        '20000 CDF', // Afficher les gains (formaté)
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        '8 commandes', // Afficher le nombre de commandes
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10), // Espace entre le texte et l'avatar
                  // Avatar du conducteur
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(51),
                    // Utilise l'URL du driver pour l'image
                    backgroundImage: driver.profilePictureUrl != null && driver.profilePictureUrl!.isNotEmpty
                        ? NetworkImage(driver.profilePictureUrl!) as ImageProvider
                        : null,
                    child: driver.profilePictureUrl == null || driver.profilePictureUrl!.isEmpty
                        ? Icon(Icons.person, size: 80, color: Theme.of(context).colorScheme.primary)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      if (!(hasPendingRides && isOnline)) Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: const HomeBottomsheetContent(),
      ),
    ],
  );
}