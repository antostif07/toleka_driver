// lib/app/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/driver_model.dart';
import '../routes/app_pages.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
  final Rxn<Driver> _currentDriver = Rxn<Driver>();
  final verificationId = "".obs;

  Stream<Driver?> get driverStream => _currentDriver.stream;
  Driver? get currentDriver => _currentDriver.value;

  @override
  void onInit() {
    _auth.authStateChanges().listen(_handleAuthChanged);
    super.onInit();
  }

  Future<void> _handleAuthChanged(User? firebaseUser) async {
    await Future.delayed(Duration.zero);
    if (firebaseUser == null) {
      _currentDriver.value = null;
      Get.offAllNamed(Routes.getStarted);
    } else {
      await _checkAndFinalizeDriverProfile(firebaseUser.uid);
    }
  }

  /// Vérifie si un profil chauffeur existe. Si non, le crée via la Cloud Function.
  Future<void> _checkAndFinalizeDriverProfile(String uid) async {
    try {
      final driverDocRef = _firestore.collection('drivers').doc(uid);
      final docSnapshot = await driverDocRef.get();

      if (docSnapshot.exists) {
        _currentDriver.value = Driver.fromFirestore(docSnapshot);
        if(_currentDriver.value?.profileCompleted == false) {
          Get.offAllNamed(Routes.profileCompletion);
        } else {
          Get.offAllNamed(Routes.home);
        }
      } else {
        // Le profil n'existe pas, c'est une première inscription.
        print("Profil chauffeur non trouvé. Appel de la Cloud Function pour le créer...");

        // --- APPEL À LA CLOUD FUNCTION ---
        final callable = _functions.httpsCallable('finalizeSignUp');
        final result = await callable.call<Map<String, dynamic>>({
          'role': 'driver',
        });

        if (result.data['success'] == true) {
          print("Cloud Function a réussi. Redirection vers la complétion du profil.");
          // Le profil de base a été créé. On navigue vers le formulaire pour le compléter.
          Get.offAllNamed(Routes.profileCompletion); // ou votre route 'registerDriver'
        } else {
          throw Exception("La création du profil a échoué côté serveur.");
        }
      }
    } catch (e) {
      Get.snackbar('Erreur Critique', 'Impossible de configurer votre profil. $e');
      await logout(); // Déconnecter l'utilisateur en cas d'erreur grave
    }
  }

  // Méthode pour vérifier le code OTP saisi par l'utilisateur
  Future<void> verifyOtp(String otpCode) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otpCode,
      );

      await _auth.signInWithCredential(credential);
      // Si successful, la redirection est gérée par l'écouteur authStateChanges dans AuthService.
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      throw Exception('Une erreur inattendue est survenue: $e');
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
    _currentDriver.value = null;
  }

  Future<void> sendOtp(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-vérification (rare)
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception(_getFirebaseErrorMessage(e.code));
        },
        codeSent: (String verId, int? resendToken) {
          verificationId.value = verId;
        },
        codeAutoRetrievalTimeout: (String verId) {
          // Délai d'attente pour la récupération auto du code expiré
          verificationId.value = verId;
        },
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      throw Exception('Une erreur inattendue est survenue: $e');
    }
  }

  // Fonctions d'aide pour les messages d'erreur Firebase
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-verification-code': return 'Le code SMS est invalide. Veuillez réessayer.';
      case 'invalid-phone-number': return 'Le numéro de téléphone est mal formaté ou invalide.';
      case 'too-many-requests': return 'Trop de tentatives. Veuillez réessayer plus tard.';
      case 'session-expired': return 'La session a expiré. Veuillez renvoyer le code.';
      case 'quota-exceeded': return 'Le quota d\'envois de SMS a été dépassé. Contactez l\'assistance.';
      case 'network-request-failed': return 'Problème de connexion internet. Vérifiez votre réseau.';
      case 'missing-verification-id': return 'ID de vérification manquant. Renvoyez le code.';
      default: return 'Une erreur d\'authentification est survenue. Code: $errorCode';
    }
  }
}