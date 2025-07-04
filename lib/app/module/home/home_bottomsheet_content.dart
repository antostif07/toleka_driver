// widgets/online_status_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import 'home_controller.dart';

class HomeBottomsheetContent extends StatelessWidget {
  const HomeBottomsheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    // On peut récupérer le contrôleur facilement avec Get.find()
    final HomeController controller = Get.find();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Le BottomSheet prend la hauteur de son contenu
        children: [
          // "Poignée" pour indiquer que c'est un panel que l'on peut tirer
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.amber,
                // Utilise l'URL du driver pour l'image
                backgroundImage: controller.currentDriver.value!.profilePictureUrl != null && controller.currentDriver.value!.profilePictureUrl!.isNotEmpty
                    ? NetworkImage(controller.currentDriver.value!.profilePictureUrl!) as ImageProvider
                    : null,
                child: controller.currentDriver.value!.profilePictureUrl == null || controller.currentDriver.value!.profilePictureUrl!.isEmpty
                    ? Icon(Icons.person, size: 80, color: Theme.of(context).colorScheme.primary)
                    : null,
              ),
              const SizedBox(
                width: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                    controller.currentDriver.value!.fullName,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )),
                  Text(
                    controller.currentDriver.value!.driverID,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => Container( // Obx pour réagir à controller.isOnline.value
            alignment: Alignment.centerLeft, // Aligner le Container à gauche
            child: Text(
              controller.isOnline.value ? "Vous êtes en ligne" : "Vous êtes hors-ligne", // Texte dynamique
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold, // Plus de visibilité
                color: controller.isOnline.value ? Colors.green : Colors.red, // Couleur dynamique
              ),
            ),
          )),
          const SizedBox(height: 8),
          Obx(() => Text( // Obx pour réagir à controller.isOnline.value
            controller.isOnline.value
                ? 'Vous pouvez recevoir des commandes maintenant...'
                : 'Vous ne pouvez pas recevoir des commandes maintenant...',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  backgroundColor: controller.isOnline.value ? Colors.red : Theme.of(context).colorScheme.primary,
                  foregroundColor: controller.isOnline.value ? Colors.white : Colors.black,
              ),
              onPressed: () {
                controller.toggleOnlineStatus();
              },
              child: controller.isOnline.value ? const Text(' Passez Hors-Ligne') : const Text('Passez En Ligne'),
            ),)
          ),
        ],
      ),
    );
  }
}