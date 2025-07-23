import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/driver_model.dart';
import '../module/driver_preferences/driver_preferences_model.dart';
import '../routes/app_pages.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
  final verificationId = "".obs;

  final Rxn<Driver> _currentDriver = Rxn<Driver>();
  Driver? get currentDriver => _currentDriver.value;
  Rxn<Driver> get driver => _currentDriver;
  StreamSubscription<DocumentSnapshot>? _driverSubscription;

  @override
  void onInit() {
    _auth.authStateChanges().listen(_handleAuthChanged);
    super.onInit();
  }

  Future<void> _handleAuthChanged(User? firebaseUser) async {
    await Future.delayed(Duration.zero);
    await _driverSubscription?.cancel();
    if (firebaseUser == null) {
      _currentDriver.value = null;
      Get.offAllNamed(Routes.getStarted);
    } else {
      _driverSubscription = _firestore
          .collection('drivers')
          .doc(firebaseUser.uid)
          .snapshots()
          .listen(
          _onDriverDocumentChanged, // Appelle cette méthode à chaque changement
          onError: (error) {
            Get.snackbar('Erreur de Synchronisation', 'Impossible d\'écouter votre profil en temps réel.');
            logout(); // En cas d'erreur grave (ex: droits), on déconnecte
          }
      );
    }
  }

  Future<void> _onDriverDocumentChanged(DocumentSnapshot<Map<String, dynamic>> docSnapshot) async {
    if (docSnapshot.exists) {
      // Le document existe, on le met à jour
      final driver = Driver.fromFirestore(docSnapshot);
      _currentDriver.value = driver;

      if (driver.profileCompleted == false) {
        // S'assure de ne pas être déjà sur la page pour éviter les boucles de redirection
        if (Get.currentRoute != Routes.profileCompletion) {
          Get.offAllNamed(Routes.profileCompletion);
        }
      } else {
        // Le profil est complet, on va à l'accueil
        if (Get.currentRoute != Routes.home) {
          Get.offAllNamed(Routes.home);
        }
      }
    } else {
      // Le document n'existe pas ENCORE. C'est probablement une première inscription.
      // On déclenche la Cloud Function pour le créer.
      // Après l'exécution de la fonction, Firestore enverra un nouvel événement
      // à notre écouteur, et on passera dans le bloc "if (docSnapshot.exists)".
      try {
        final callable = _functions.httpsCallable('finalizeSignUp');
        final result = await callable.call<Map<String, dynamic>>({'role': 'driver'});
        if (result.data['success'] != true) {
          throw Exception("La création du profil via la Cloud Function a échoué.");
        }
        // Pas besoin de naviguer ici, l'écouteur s'en chargera au prochain événement.
      } catch (e) {
        Get.snackbar('Erreur Critique', 'Impossible de finaliser votre profil. $e');
        await logout();
      }
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

  Future<void> updateDriverPreferences(DriverPreferences newPreferences) async {
    if (currentDriver == null) throw Exception("Utilisateur non connecté.");
    final driverDocRef = _firestore.collection('drivers').doc(currentDriver!.id);
    await driverDocRef.update({'preferences': newPreferences.toMap()});
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