import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/ride_model.dart';

class RideActivityController extends GetxController {
  // --- VARIABLES D'ÉTAT ---
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isLoading = true.obs;

  // Contient toutes les activités, groupées par jour.
  final RxList<DailyActivity> dailyActivities = <DailyActivity>[].obs;

  // --- PROPRIÉTÉS CALCULÉES ---
  String get selectedWeekRange {
    final startOfWeek = selectedDate.value.subtract(Duration(days: selectedDate.value.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return "${DateFormat('d MMM').format(startOfWeek)} - ${DateFormat('d MMM').format(endOfWeek)}";
  }

  double get weeklyEarnings => dailyActivities.fold(0.0, (sum, day) => sum + day.dailyTotal);
  int get weeklyRides => dailyActivities.fold(0, (sum, day) => sum + day.rides.length);

  @override
  void onInit() {
    super.onInit();
    fetchRideData();
  }

  /// Simule la récupération et le groupement des données.
  Future<void> fetchRideData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simule un appel réseau

    // -- Scénario 1: Il y a de l'activité --
    dailyActivities.value = _getDummyData();

    // -- Scénario 2: Aucune activité --
    // dailyActivities.value = [];

    isLoading.value = false;
  }

  // Change la semaine sélectionnée
  void previousWeek() => selectedDate.value = selectedDate.value.subtract(const Duration(days: 7));
  void nextWeek() => selectedDate.value = selectedDate.value.add(const Duration(days: 7));


  // --- DONNÉES DE SIMULATION ---
  List<DailyActivity> _getDummyData() {
    return [
      DailyActivity(
        date: DateTime(2025, 3, 10), // Sam 10 Mars
        rides: [
          Ride(destination: "Course vers West Field Cafe", timestamp: DateTime.now(), amount: 15.87),
          Ride(destination: "Course vers WeWork", timestamp: DateTime.now(), amount: 9.36),
          Ride(destination: "Course vers la région du centre-ville", timestamp: DateTime.now(), amount: 12.18),
          Ride(destination: "Course vers 8080 Railroad St.", timestamp: DateTime.now(), amount: 2.02),
        ],
      ),
      DailyActivity( // Une journée sans activité
        date: DateTime(2025, 3, 8),
        rides: [],
      ),
      DailyActivity(
        date: DateTime(2025, 3, 7), // Sam 7 Mars
        rides: [
          Ride(destination: "Course vers 9 Evergreen Center", timestamp: DateTime.now(), amount: 1.21),
          Ride(destination: "Course vers 1 Vernon Point", timestamp: DateTime.now(), amount: 8.04),
          Ride(destination: "Course vers 1147 Merchant Parkway", timestamp: DateTime.now(), amount: 5.13),
        ],
      ),
    ];
  }
}