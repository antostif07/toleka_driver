import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'profile_completion_controller.dart';

class Step5ProfilePhoto extends StatelessWidget {
  const Step5ProfilePhoto({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileCompletionController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Titres ---
          const Text("Étape 6 sur 6", style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            "Téléchargez votre photo de profil",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const SizedBox(height: 48),

          // --- Zone d'Upload ---
          Obx(() {
            if (controller.profilePhotoImage.value == null) {
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
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
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
          "Montrez bien votre visage et vos épaules. Retirez vos lunettes de soleil ou votre chapeau.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildImagePreview(ProfileCompletionController controller) {
    return Column(
      children: [
        CircleAvatar(
          radius: 100,
          backgroundImage: FileImage(controller.profilePhotoImage.value!),
        ),
        const SizedBox(height: 16),
        Text(
          "Soumettez cette image si elle est bien éclairée, sinon téléchargez-en une autre.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => controller.clearImage(controller.profilePhotoImage),
              child: const Text("Re-télécharger"),
            ),
            // Pas de bouton "Submit" ici, on utilise celui de la vue parente
          ],
        )
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context, ProfileCompletionController controller) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                controller.pickImage(ImageSource.gallery, controller.profilePhotoImage);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Appareil photo'),
              onTap: () {
                controller.pickImage(ImageSource.camera, controller.profilePhotoImage);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}