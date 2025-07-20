import 'package:get/get.dart';
import 'package:toleka_driver/app/module/auth/profile_completion/profile_completion_controller.dart';

class ProfileCompletionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileCompletionController());
  }
}