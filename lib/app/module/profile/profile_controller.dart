// lib/app/modules/profile/profile_controller.dart

import 'dart:io'; // Pour le type File
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Pour choisir l'image
import 'package:firebase_storage/firebase_storage.dart';

import '../home/home_controller.dart'; // Pour Cloud Storage

class ProfileController extends GetxController {
  // final HomeController homeController = Get.find<HomeController>();
  // final ImagePicker _picker = ImagePicker();
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  //
  // final RxBool isUploading = false.obs; // Indique si un upload est en cours
  //
  // /// Permet à l'utilisateur de choisir une image et l'upload vers Firebase Storage.
  // Future<void> pickAndUploadProfilePicture() async {
  //   if (homeController.currentDriver.value == null) {
  //     Get.snackbar('Erreur', 'Profil chauffeur non chargé. Impossible de changer la photo.',
  //         snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error);
  //     return;
  //   }
  //
  //   final String driverUid = homeController.currentDriver.value!.id; // L'UID du driver
  //
  //   try {
  //     final XFile? pickedFile = await _picker.pickImage(
  //       source: ImageSource.gallery, // Ou ImageSource.camera
  //       imageQuality: 75, // Comprimer l'image pour un upload plus rapide et moins de stockage
  //       maxWidth: 500, // Redimensionner pour des avatars (optionnel mais recommandé)
  //       maxHeight: 500,
  //     );
  //
  //     if (pickedFile == null) {
  //       print("Sélection d'image annulée.");
  //       return; // L'utilisateur a annulé la sélection
  //     }
  //
  //     isUploading.value = true; // Activer l'indicateur de chargement
  //
  //     final File imageFile = File(pickedFile.path);
  //
  //     // Créer une référence au fichier dans Firebase Storage
  //     // Le chemin est 'profile_pictures/<UID_DU_CONDUCTEUR>.jpg'
  //     // Cela permet à la règle de sécurité de vérifier l'UID.
  //     final storageRef = _storage.ref().child('profile_pictures').child('$driverUid.jpg');
  //
  //     // Télécharger le fichier
  //     final UploadTask uploadTask = storageRef.putFile(imageFile, SettableMetadata(
  //       // C'est ici que nous ajoutons les métadonnées pour la règle de sécurité
  //       customMetadata: {'uid': driverUid},
  //       contentType: 'image/jpeg', // Assurez-vous que le type correspond à votre image
  //     ));
  //
  //     // Attendre la fin de l'upload
  //     final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
  //
  //     // Obtenir l'URL de téléchargement
  //     final String downloadUrl = await snapshot.ref.getDownloadURL();
  //     print("Photo de profil uploadée: $downloadUrl");
  //
  //     // Mettre à jour l'URL dans Firestore via le HomeController
  //     // await homeController.updateDriverProfilePicture(downloadUrl);
  //
  //     Get.snackbar('Succès', 'Photo de profil mise à jour !',
  //         snackPosition: SnackPosition.TOP, backgroundColor: Colors.green);
  //
  //   } on FirebaseException catch (e) {
  //     print("Erreur Firebase lors de l'upload: $e");
  //     Get.snackbar('Erreur d\'upload', 'Erreur Firebase: ${e.message}',
  //         snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error);
  //   } catch (e) {
  //     print("Erreur inattendue lors de l'upload: $e");
  //     Get.snackbar('Erreur', 'Une erreur inattendue est survenue: $e',
  //         snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error);
  //   } finally {
  //     isUploading.value = false; // Désactiver l'indicateur de chargement
  //   }
  // }
}