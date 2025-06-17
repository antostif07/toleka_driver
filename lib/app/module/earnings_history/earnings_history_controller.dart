// lib/app/modules/earnings_history/earnings_history_controller.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../models/ride_model.dart';

class EarningsHistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<RideModel> completedRides = <RideModel>[].obs;
  final RxDouble totalEarnings = 0.0.obs;
  final RxBool isLoading = false.obs;

  StreamSubscription? _earningsSubscription;

  @override
  void onInit() {
    super.onInit();
    _fetchEarningsHistory();
  }

  @override
  void onClose() {
    _earningsSubscription?.cancel();
    super.onClose();
  }

  Future<void> _fetchEarningsHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Erreur', 'Veuillez vous connecter pour voir vos gains.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      // Écouter les courses terminées de ce chauffeur
      _earningsSubscription = _firestore
          .collection('rideRequests')
          .where('assignedDriverId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'completed')
          .orderBy('completedAt', descending: true) // Les plus récentes en premier
          .snapshots()
          .listen((snapshot) {
        double currentTotal = 0.0;
        List<RideModel> rides = snapshot.docs.map((doc) {
          final ride = RideModel.fromFirestore(doc);
          currentTotal += ride.estimatedPrice;
          return ride;
        }).toList();

        completedRides.assignAll(rides);
        totalEarnings.value = currentTotal;
        isLoading.value = false;
      }, onError: (error) {
        print("Erreur de récupération des gains: $error");
        Get.snackbar('Erreur', 'Impossible de charger l\'historique des gains.', snackPosition: SnackPosition.BOTTOM);
        isLoading.value = false;
      });
    } catch (e) {
      print("Erreur de récupération initiale des gains: $e");
      isLoading.value = false;
    }
  }
}