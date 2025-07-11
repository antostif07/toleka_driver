// lib/app/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/driver_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rxn<Driver> _currentDriver = Rxn<Driver>();

  Stream<Driver?> get driverStream => _currentDriver.stream;
  Driver? get currentDriver => _currentDriver.value;

  @override
  void onInit() {
    print("AUTH SERVICE INITIALIZED");
    _auth.authStateChanges().listen(_handleAuthChanged);
    super.onInit();
  }

  Future<void> _handleAuthChanged(User? firebaseUser) async {
    await Future.delayed(Duration.zero);
    if (firebaseUser == null) {
      _currentDriver.value = null;
      Get.offAllNamed('/login');
    } else {
      await _fetchDriverData(firebaseUser.uid);
    }
  }

  Future<void> _fetchDriverData(String uid) async {
    try {
      final doc = await _firestore.collection('drivers').doc(uid).get();
      if (doc.exists) {
        _currentDriver.value = Driver.fromFirestore(doc);
        Get.offAllNamed('/home');
      } else {
        throw Exception('Utilisateur non trouvé');
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger le profil');
    }
  }

  // Connexion Email/Mot de passe
  Future<void> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _parseAuthError(e.code);
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
    _currentDriver.value = null;
  }

  // Gestion des erreurs
  String _parseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Utilisateur non trouvé';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Email déjà utilisé';
      default:
        return 'Erreur d\'authentification';
    }
  }

  /// Méthode privée pour interroger Firestore et trouver l'email d'un conducteur par son ID.
  /// Retourne l'email sous forme de String, ou null si non trouvé.
  Future<String?> getEmailFromDriverId(String driverId) async {
    try {
      final querySnapshot = await _firestore
          .collection('drivers')
          .where('driverID', isEqualTo: driverId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data()['email'];
      } else {
        return null;
      }
    } catch (e) {
      print("Erreur lors de la récupération de l'email depuis Firestore: $e");
      return null;
    }
  }
}