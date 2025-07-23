import 'package:get/get.dart';
import 'package:toleka_driver/app/module/ride_activity/ride_activity_controller.dart';

class RideActivityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RideActivityController());
  }
}