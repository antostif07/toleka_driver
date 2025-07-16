import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/auth_services.dart';

class LoginController extends GetxController {
  // Auth Service
  final AuthService _authService = Get.find();

  // Contrôleurs pour les champs de texte
  final TextEditingController driverIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Variables réactives pour gérer l'état de l'UI
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  // Clé pour le formulaire afin de gérer la validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Méthode pour basculer la visibilité du mot de passe
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Méthode principale de connexion
  Future<void> login() async {
    // 1. Valider le formulaire
    if (!formKey.currentState!.validate()) {
      return; // Si le formulaire n'est pas valide, on ne fait rien
    }

    isLoading.value = true;

    try {
      // 2. Récupérer l'e-mail associé à l'ID du conducteur depuis Firestore via Cloud Functions
      final String enteredDriverId = driverIdController.text.trim();
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('getDriverEmailFromId');

      final HttpsCallableResult result = await callable.call({
        'driverId': enteredDriverId,
      });

      final String? email = result.data['email'];

      // Si aucun e-mail n'est trouvé, l'ID est incorrect.
      if (email == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
        );
      }

      // 3. Authentifier l'utilisateur avec l'e-mail trouvé et le mot de passe saisi
      await _authService.loginWithEmail(
        email.trim(),
        passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      // 5. Gérer les erreurs d'authentification et afficher un message clair
      String errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'ID Conducteur ou mot de passe incorrect.';
      }

      Get.snackbar(
        'Échec de la connexion',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    } catch (e) {
      print(e);
      Get.snackbar(
        'Erreur',
        'Une erreur inattendue est survenue.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Nettoyer les contrôleurs de texte lorsqu'on quitte l'écran
  @override
  void onClose() {
    driverIdController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}