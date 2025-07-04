// lib/app/modules/login/login_controller.dart


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toleka_driver/app/routes/app_pages.dart';

class LoginController extends GetxController {
  // Instances des services Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      // 2. Récupérer l'e-mail associé à l'ID du conducteur depuis Firestore
      final String enteredDriverId = driverIdController.text.trim();
      final String? email = await _getEmailFromDriverId(enteredDriverId);

      // Si aucun e-mail n'est trouvé, l'ID est incorrect.
      if (email == null) {
        throw FirebaseAuthException(
          code: 'user-not-found', // On utilise un code standard pour simplifier la gestion d'erreur
        );
      }

      // 3. Authentifier l'utilisateur avec l'e-mail trouvé et le mot de passe saisi
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: passwordController.text.trim(),
      );

      // 4. Si la connexion réussit, naviguer vers la page d'accueil
      Get.offAllNamed(Routes.home);

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
      // Gérer toute autre erreur potentielle
      Get.snackbar(
        'Erreur',
        'Une erreur inattendue est survenue.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      // 6. Arrêter le chargement, que la connexion réussisse ou échoue
      isLoading.value = false;
    }
  }

  /// Méthode privée pour interroger Firestore et trouver l'email d'un conducteur par son ID.
  /// Retourne l'email sous forme de String, ou null si non trouvé.
  Future<String?> _getEmailFromDriverId(String driverId) async {
    try {
      final querySnapshot = await _firestore
          .collection('drivers')
          .where('driverID', isEqualTo: driverId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Si un document est trouvé, retourner son champ 'email'
        return querySnapshot.docs.first.data()['email'];
      } else {
        // Si aucun document ne correspond, retourner null
        return null;
      }
    } catch (e) {
      // Pour le débogage, il est bon de voir l'erreur dans la console
      print("Erreur lors de la récupération de l'email depuis Firestore: $e");
      return null;
    }
  }

  // Nettoyer les contrôleurs de texte lorsqu'on quitte l'écran
  @override
  void onClose() {
    // driverIdController.dispose();
    // passwordController.dispose();
    super.onClose();
  }
}