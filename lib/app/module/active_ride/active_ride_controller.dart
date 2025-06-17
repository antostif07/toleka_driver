// lib/app/modules/active_ride/active_ride_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/ride_model.dart';
import '../../routes/app_pages.dart';
import '../home/home_controller.dart';

class ActiveRideController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HomeController homeController = Get.find<HomeController>();

  // La course active est passée comme argument
  late Rx<RideModel> activeRide;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is RideModel) {
      activeRide = args.obs;
      // Optionnel: Écouter les changements du document de course en temps réel
      _firestore.collection('rideRequests').doc(activeRide.value.id).snapshots().listen((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          activeRide.value = RideModel.fromFirestore(snapshot);
        } else {
          // La course a été supprimée ou annulée par le passager
          Get.snackbar('Course annulée', 'La course a été annulée par le passager.', snackPosition: SnackPosition.TOP);
          Get.offAllNamed(Routes.home);
        }
      });
    } else {
      // Gérer le cas où aucun argument n'est passé (erreur)
      Get.snackbar('Erreur', 'Aucune course active trouvée.', snackPosition: SnackPosition.TOP);
      Get.offAllNamed(Routes.home);
    }
  }

  // Méthodes pour mettre à jour le statut de la course
  Future<void> updateRideStatus(String newStatus) async {
    isLoading.value = true;
    try {
      await _firestore.collection('rideRequests').doc(activeRide.value.id).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        // Ajouter d'autres timestamps selon le statut
        if (newStatus == 'picked_up') 'startedAt': FieldValue.serverTimestamp(),
        if (newStatus == 'completed') 'completedAt': FieldValue.serverTimestamp(),
      });
      activeRide.value = activeRide.value.copyWith(status: newStatus); // Mettre à jour l'état local

      Get.snackbar('Statut mis à jour', 'Course: ${newStatus.capitalizeFirst}', snackPosition: SnackPosition.TOP);

      // Si la course est terminée, mettre à jour les stats du chauffeur et retourner à l'accueil
      if (newStatus == 'completed') {
        // await homeController.updateDriverStatsOnCompletion(activeRide.value); // Nouvelle méthode à créer
        Get.offAllNamed(Routes.home);
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour le statut.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

// TODO: Ajoutez ici la logique pour la navigation GPS, appeler le passager, etc.
}