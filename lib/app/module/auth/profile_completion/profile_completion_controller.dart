import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../routes/app_pages.dart';

enum VehiclePreference { iHaveACar, iNeedACar, unknown }

class ProfileCompletionController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // On le configure pour l'effet carrousel
  final PageController page0Controller = PageController(
    viewportFraction: 0.85,
  );


  // --- Contrôleur de Page ---
  late PageController pageController;
  final RxInt currentPage = 0.obs;
  final int totalPages = 6; // Le nombre total de vos écrans de formulaire

  // --- ÉTAPE 1: Type de chauffeur ---
  final Rx<VehiclePreference> vehiclePreference = VehiclePreference.unknown.obs;

  // --- ÉTAPE 2: Infos Personnelles ---
  final formKeyStep1 = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  String get phoneNumber => _auth.currentUser?.phoneNumber ?? '';

  // --- ÉTAPE 3: Infos du Véhicule (sera à l'index 2) ---
  final formKeyStep2 = GlobalKey<FormState>();
  // Pour les dropdowns, on stockera la valeur sélectionnée dans des RxString
  final Rx<String?> make = Rx<String?>(null); // Marque
  final Rx<String?> color = Rx<String?>(null); // Couleur
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final licensePlateController = TextEditingController();
  final List<String> carMakes = ['Toyota', 'Honda', 'Ford', 'Mercedes-Benz', 'BMW'];
  final List<String> carColors = ['Noir', 'Blanc', 'Gris', 'Bleu', 'Rouge'];

  // --- ÉTAPE 4: Documents ---
  final ImagePicker _picker = ImagePicker();
  final Rx<File?> driverLicenseImage = Rx<File?>(null);

  // --- ÉTAPE 5: Carte Grise ---
  final Rx<File?> vehicleRegistrationImage = Rx<File?>(null);

  // --- ÉTAPE 6: Photo de Profil (Optionnelle) ---
  final Rx<File?> profilePhotoImage = Rx<File?>(null);

  // États de l'UI
  final RxBool isLoading = false.obs;
  final RxBool termsAccepted = false.obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  /// Méthode appelée lorsqu'une carte de préférence est cliquée
  void selectVehiclePreference(VehiclePreference preference) {
    vehiclePreference.value = preference;

    nextPage();
  }

  /// La méthode finale qui valide la dernière étape et soumet tout.
  Future<void> completeProfile() async {
    // Valider la dernière étape
    if (driverLicenseImage.value == null || vehicleRegistrationImage.value == null) {
      Get.snackbar("Attention", "Veuillez télécharger tous les documents requis.");
      return;
    }

    isLoading.value = true;
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return;
    }

    try {
      // --- ÉTAPE A: Télécharger l'image sur Firebase Storage ---
      // --- Télécharger les DEUX images sur Firebase Storage ---
      final String driverLicenseUrl = await _uploadDocument(
        file: driverLicenseImage.value!,
        userId: currentUser.uid,
        docName: 'driver_license.jpg',
      );

      final String vehicleRegistrationUrl = await _uploadDocument(
        file: vehicleRegistrationImage.value!,
        userId: currentUser.uid,
        docName: 'vehicle_registration.jpg',
      );

      String? profilePhotoUrl;

      // --- Télécharger la photo de profil SEULEMENT si elle a été choisie ---
      if (profilePhotoImage.value != null) {
        profilePhotoUrl = await _uploadDocument(
          file: profilePhotoImage.value!,
          userId: currentUser.uid,
          docName: 'profile_photo.jpg',
        );
      }

      final driverData = {
        'vehiclePreference': vehiclePreference.value.toString().split('.').last,
        'fullName': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'vehicleMake': make.value,
        'vehicleModel': modelController.text.trim(),
        'vehicleYear': yearController.text.trim(),
        'vehicleColor': color.value,
        'licensePlate': licensePlateController.text.trim(),
        'driverLicenseUrl': driverLicenseUrl,
        'vehicleRegistrationUrl': vehicleRegistrationUrl,
        'profilePictureUrl': profilePhotoUrl,
        'profileCompleted': true,
        'isApproved': false,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('drivers').doc(currentUser.uid).update(driverData);
      Get.offAllNamed(Routes.home);

    } catch (e) {
      print(e);
      Get.snackbar("Erreur finale", "Impossible de sauvegarder votre profil");    }
    finally {
      isLoading.value = false;
    }
  }

  // --- MÉTHODE HELPER POUR LE TÉLÉCHARGEMENT ---
  Future<String> _uploadDocument({
    required File file,
    required String userId,
    required String docName,
  }) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('driver_documents')
        .child(userId)
        .child(docName);

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  /// Passe à la page suivante si le formulaire de la page actuelle est valide.
  void nextPage() {
    bool isFormValid = true;

    // On valide les formulaires des étapes qui en ont un
    if (currentPage.value == 1) { // Infos personnelles
      isFormValid = formKeyStep1.currentState?.validate() ?? false;
      if (!termsAccepted.value) {
        Get.snackbar("Attention", "Veuillez accepter les termes et conditions.");
        return;
      }
    } else if (currentPage.value == 2) { // Étape des infos véhicule
      isFormValid = formKeyStep2.currentState!.validate();
      // On valide aussi que les dropdowns ont été sélectionnés
      if (make.value == null || color.value == null) {
        isFormValid = false;
        Get.snackbar("Champs requis",
            "Veuillez sélectionner la marque, le modèle et la couleur.");
      }
    } else if (currentPage.value == 3) { // Étape 4: Permis de conduire
      isFormValid = driverLicenseImage.value != null;
      if (!isFormValid) Get.snackbar("Attention", "Veuillez télécharger votre permis.");
    } else if (currentPage.value == 4) { // Étape 5: Carte grise
      isFormValid = vehicleRegistrationImage.value != null;
      if (!isFormValid) Get.snackbar("Attention", "Veuillez télécharger votre carte grise.");
    }

    if (isFormValid) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Passe à la page précédente.
  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> pickImage(ImageSource source, Rx<File?> imageFile) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
      }
    } catch (e) { Get.snackbar("Erreur", "Impossible de sélectionner une image."); }
  }

  void clearImage(Rx<File?> imageFile) {
    imageFile.value = null;
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    yearController.dispose();
    licensePlateController.dispose();
    super.onClose();
  }
}