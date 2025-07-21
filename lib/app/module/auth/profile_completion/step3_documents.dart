import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'profile_completion_controller.dart';

class Step3Documents extends StatelessWidget {
  const Step3Documents({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileCompletionController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Titres ---
          const Text("Étape 4 sur 4", style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            "Prenez une photo de votre Permis de Conduire",
            style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const SizedBox(height: 32),

          // --- Zone d'Upload ---
          Obx(() {
            // On affiche le bon widget en fonction de si une image est sélectionnée
            if (controller.driverLicenseImage.value == null) {
              return _buildUploadPlaceholder(context, controller);
            } else {
              return _buildImagePreview(controller);
            }
          }),
        ],
      ),
    );
  }

  // Widget affiché avant que l'image ne soit choisie
  Widget _buildUploadPlaceholder(BuildContext context, ProfileCompletionController controller) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showImageSourceDialog(context, controller),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              // ... (style du cadre en pointillés)
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey, style: BorderStyle.solid,),
            ),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => _showImageSourceDialog(context, controller),
                icon: const Icon(Icons.upload),
                label: const Text("Télécharger"),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Assurez-vous que votre permis n'est pas expiré. Prenez une photo nette et évitez d'utiliser le flash.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Widget affiché après que l'image a été choisie
  Widget _buildImagePreview(ProfileCompletionController controller) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            controller.driverLicenseImage.value!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Soumettez cette image si vous la jugez lisible, ou téléchargez-en une autre.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Dialogue pour choisir entre Caméra et Galerie
  void _showImageSourceDialog(BuildContext context, ProfileCompletionController controller) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie de photos'),
              onTap: () {
                controller.pickImage(ImageSource.gallery, controller.driverLicenseImage);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Appareil photo'),
              onTap: () {
                controller.pickImage(ImageSource.camera, controller.driverLicenseImage);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}