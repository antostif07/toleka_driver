// lib/app/modules/ride_requests/ride_requests_binding.dart
import 'package:get/get.dart';
import 'ride_requests_controller.dart';

class RideRequestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RideRequestsController>(() => RideRequestsController());
  }
}