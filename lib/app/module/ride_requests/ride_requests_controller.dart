// lib/app/modules/ride_requests/ride_requests_controller.dart
import 'package:get/get.dart';
import '../../models/ride_model.dart';
import '../home/home_controller.dart';

class RideRequestsController extends GetxController {
  // Accès au contrôleur principal pour les données des demandes
  final HomeController homeController = Get.find<HomeController>();

  // Vous pouvez ajouter ici la logique spécifique à la gestion de la liste
  // Ex: Filtrer les demandes, gérer des notifications spécifiques, etc.

  // Les demandes sont déjà observées dans homeController.pendingRideRequests
  // Vous pouvez juste les exposer ici si vous voulez un niveau d'abstraction
  RxList<RideModel> get pendingRequests => homeController.pendingRideRequests;

  // Méthodes pour interagir avec les demandes (pass-through vers HomeController)
  Future<void> acceptRequest(RideModel request) => homeController.acceptRideRequest(request);
  Future<void> rejectRequest(RideModel request) => homeController.rejectRideRequest(request);
}