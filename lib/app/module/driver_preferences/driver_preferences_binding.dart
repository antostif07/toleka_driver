import 'package:get/get.dart';

import 'driver_preferences_controller.dart';

class DriverPreferencesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverPreferencesController>(() => DriverPreferencesController());
  }

}