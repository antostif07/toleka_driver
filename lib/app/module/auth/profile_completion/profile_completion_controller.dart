import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

enum VehiclePreference { iHaveACar, iNeedACar, unknown }

class ProfileCompletionController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<VehiclePreference> vehiclePreference = VehiclePreference.unknown.obs;
  // On le configure pour l'effet carrousel
  final PageController page0Controller = PageController(
    viewportFraction: 0.85,
  );

  // --- ÉTAPE 1: Infos Personnelles ---
  final formKeyStep1 = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  String get phoneNumber => _auth.currentUser?.phoneNumber ?? '';

  // --- ÉTAPE 2: Infos du Véhicule --- (à créer)
  final formKeyStep2 = GlobalKey<FormState>();
  final carModelController = TextEditingController();
  final licensePlateController = TextEditingController();

  // --- ÉTAPE 3: Documents et Finalisation --- (à créer)
  final formKeyStep3 = GlobalKey<FormState>();

  // --- Contrôleur de Page ---
  late PageController pageController;
  final RxInt currentPage = 0.obs;
  final int totalPages = 3; // Le nombre total de vos écrans de formulaire

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
    print("Préférence sélectionnée: $preference");

    nextPage();
  }

  /// La méthode finale qui valide la dernière étape et soumet tout.
  Future<void> completeProfile() async {
    // Valider la dernière étape
    if (!formKeyStep3.currentState!.validate()) return;
    if (!termsAccepted.value) {
      Get.snackbar("Attention", "Veuillez accepter les termes et conditions.");
      return;
    }

    isLoading.value = true;
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) { /* ... gérer l'erreur ... */ }

    try {
      // TODO: Télécharger les images sur Firebase Storage et obtenir les URLs

      final driverData = {
        'vehiclePreference': vehiclePreference.value.toString().split('.').last,
        'fullName': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'carModel': carModelController.text.trim(),
        'licensePlate': licensePlateController.text.trim(),
        // 'idCardUrl': "url_de_storage",
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('drivers').doc(currentUser!.uid).update(driverData);
      Get.offAllNamed(Routes.home);

    } catch (e) { /* ... gérer l'erreur ... */ }
    finally {
      isLoading.value = false;
    }
  }

  /// Passe à la page suivante si le formulaire de la page actuelle est valide.
  void nextPage() {
    bool isFormValid = true; // Par défaut, on peut avancer

    // On valide les formulaires des étapes qui en ont un
    if (currentPage.value == 1) { // L'étape 2 (index 1) est le formulaire d'infos personnelles
      isFormValid = formKeyStep1.currentState!.validate();
    } else if (currentPage.value == 2) {
      isFormValid = formKeyStep2.currentState!.validate();
    }

    if (isFormValid) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}