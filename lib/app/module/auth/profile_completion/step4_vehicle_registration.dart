import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'profile_completion_controller.dart';

class Step4VehicleRegistration extends StatelessWidget {
  const Step4VehicleRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileCompletionController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Titres ---
          const Text("Étape 5 sur 5", style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            "Prenez une photo de votre plaque d'immatriculation", // <-- TEXTE MODIFIÉ
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const SizedBox(height: 32),

          // --- Zone d'Upload ---
          Obx(() {
            // ON UTILISE LA NOUVELLE VARIABLE
            if (controller.vehicleRegistrationImage.value == null) {
              return _buildUploadPlaceholder(context, controller);
            } else {
              return _buildImagePreview(controller);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder(BuildContext context, ProfileCompletionController controller) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showImageSourceDialog(context, controller),
          child: Container(
            // ...
            child: ElevatedButton.icon(
              onPressed: () => _showImageSourceDialog(context, controller),
              icon: const Icon(Icons.upload),
              label: const Text("Télécharger"),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Assurez-vous que le document est valide et que toutes les informations sont lisibles.", // <-- TEXTE MODIFIÉ
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildImagePreview(ProfileCompletionController controller) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            controller.vehicleRegistrationImage.value!, // <-- ON UTILISE LA NOUVELLE VARIABLE
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
        // Pour la dernière étape, les boutons de navigation sont dans la vue principale
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
                controller.pickImage(ImageSource.gallery, controller.vehicleRegistrationImage);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Appareil photo'),
              onTap: () {
                controller.pickImage(ImageSource.camera, controller.vehicleRegistrationImage);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}