// lib/app/modules/earnings_history/earnings_history_binding.dart
import 'package:get/get.dart';
import 'earnings_history_controller.dart';

class EarningsHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EarningsHistoryController>(() => EarningsHistoryController());
  }
}