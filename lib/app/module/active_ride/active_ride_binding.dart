// lib/app/modules/active_ride/active_ride_binding.dart
import 'package:get/get.dart';
import 'active_ride_controller.dart';

class ActiveRideBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActiveRideController>(() => ActiveRideController());
  }
}