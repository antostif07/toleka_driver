// lib/app/modules/auth/login/login_controller.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../services/auth_services.dart';
import '../../../utils/sytem_ui_utils.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find();
  final TextEditingController phoneNumberController = TextEditingController();
  final RxString completePhoneNumber = ''.obs;
  final TextEditingController smsCodeController = TextEditingController();
  final RxBool isLoading = false.obs;
  final focusNode = FocusNode();

  // Logique du timer pour le renvoi du code
  Timer? _timer;
  final RxInt resendCooldown = 60.obs; // 60 secondes de cooldown
  final RxBool canResend = false.obs;

  final RxString errorMessage = ''.obs; // Pour les messages d'erreur spécifiques

  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); // Pour la validation du formulaire

  @override
  void onInit() {
    super.onInit();
    SystemUiUtils.setTransparentStatusBar(
      iconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    );
  }

  Future<void> sendOtp() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    await Future.delayed(Duration(milliseconds: 100));

    try {
      await _authService.sendOtp(completePhoneNumber.value.trim());

      Get.snackbar(
          'Code envoyé',
          'Veuillez saisir le code reçu par SMS.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green
      );
      Get.toNamed(Routes.otp);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst("Exception: ", "");
    } finally {
      isLoading.value = false;
    }
  }

  /// Démarre le compte à rebours pour le renvoi du code.
  void startResendTimer() {
    canResend.value = false;
    resendCooldown.value = 60;
    _timer?.cancel(); // Annuler tout timer précédent
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldown.value > 0) {
        resendCooldown.value--;
      } else {
        timer.cancel();
        canResend.value = true;
      }
    });
  }

  /// Appelé lorsque l'utilisateur clique sur "Renvoyer le code".
  void resendOtp() {
    if (!canResend.value) return; // Ne rien faire si le cooldown n'est pas terminé

    // On redémarre le timer et on relance la demande d'OTP
    startResendTimer();
    // _authService.sendOtp(phoneNumber); // Le AuthService gère déjà l'envoi
  }

  // Méthode pour vérifier le code OTP saisi par l'utilisateur
  Future<void> verifyOtp() async {
    print("verifyOtp called");
    if (smsCodeController.text.isEmpty || _authService.verificationId.value.isEmpty) {
      errorMessage.value = 'Veuillez saisir le code SMS.';
      return;
    }

    isLoading.value = true;
    await Future.delayed(Duration.zero); // Permet à l'UI de rafraîchir le loading
    errorMessage.value = '';

    try {
      await _authService.verifyOtp(smsCodeController.text.trim());
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst("Exception: ", "");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneNumberController.dispose();
    smsCodeController.dispose();
    super.onClose();
  }
}