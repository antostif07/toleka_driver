  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:toleka_driver/app/module/home/home_bottomsheet_content.dart';
import 'package:toleka_driver/app/routes/app_pages.dart';

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
        // État de chargement initial pour la carte et le contrôleur
        if (
        // controller.isLocationLoading.value
        // ||
        controller.currentDriver.value == null
        ) {
          return const Center(child: CircularProgressIndicator());
        }

        // Si une erreur est présente
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Erreur: ${controller.errorMessage.value}",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            // 1. La carte en arrière-plan
            MapWidget(
              key: const ValueKey("mapboxMap"),
              cameraOptions: controller.currentCameraOptions.value,
              styleUri: MapboxStyles.MAPBOX_STREETS,
              onMapCreated: controller.onMapCreated,
              textureView: true,
            ),

            Positioned(
              // Positionnement du bouton (en haut à droite, sous le cadre de profil)
              top: 120, // Ajustez cette valeur pour qu'elle soit sous le cadre de profil
              right: 16, // Même alignement à droite que le cadre de profil
              child: FloatingActionButton(
                mini: true, // Pour un bouton plus petit (comme sur l'image)
                onPressed: controller.recenterMapOnUserLocation,
                backgroundColor: Colors.white, // Fond blanc
                foregroundColor: Colors.black, // Icône noire
                elevation: 4,
                shape: const CircleBorder(), // S'assurer qu'il est bien rond
                child: const Icon(Icons.my_location), // Icône de localisation
              ),
            ),

            Obx(() => controller.isOnline.value // <-- C'est ici que la condition est vérifiée
                ? Positioned(
              top: 40,
              left: 8,
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/lotties/online_lottie.json',
                    width: 60,
                  ),
                  const Text("En Ligne")
                ],
              ),
            )
                : const SizedBox.shrink(), // <-- Si isOnline est false, ne rien afficher
            ),

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
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          // Utilise l'URL du driver pour l'image
                          backgroundImage: controller.currentDriver.value!.profilePictureUrl != null && controller.currentDriver.value!.profilePictureUrl!.isNotEmpty
                              ? NetworkImage(controller.currentDriver.value!.profilePictureUrl!) as ImageProvider
                              : null,
                          child: controller.currentDriver.value!.profilePictureUrl == null || controller.currentDriver.value!.profilePictureUrl!.isEmpty
                              ? Icon(Icons.person, size: 80, color: Theme.of(context).colorScheme.primary)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Obx(() => AnimatedPositioned(
            //   duration: const Duration(milliseconds: 300),
            //   curve: Curves.easeInOut,
            //   bottom: 0,
            //   left: 50,
            //   right: 50,
            //   child: SizedBox(
            //     height: buttonHeight,
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Theme.of(context).colorScheme.primary, // Le jaune du thème
            //         foregroundColor: Colors.black, // Texte noir
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(30),
            //         ),
            //         elevation: 5,
            //       ),
            //       onPressed: controller.toggleOnlineStatus,
            //       child: Text(
            //         controller.isOnline.value ? 'EN LIGNE' : 'HORS LIGNE',
            //         style: const TextStyle(
            //           fontSize: 18,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),
            // )),


            // 3. Le contenu du bottom sheet (déjà présent)
            Obx(() {
              if (controller.pendingRides.isNotEmpty && controller.isOnline.value) {
                return const SizedBox.shrink(); // Ne rien afficher
              } else {
                // S'il n'y a pas de course, on affiche le panneau d'information principal.
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: const HomeBottomsheetContent(),
                );
              }
            })
          ],
        );
      }),
    );
  }
}