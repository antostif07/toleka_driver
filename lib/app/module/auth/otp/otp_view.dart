import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:toleka_driver/app/module/auth/login/login_controller.dart';

class OtpView extends GetView<LoginController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    // Thème de style pour les cases du Pinput
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.white,
        border: BorderDirectional(
          bottom: BorderSide(
            color: Colors.black54,
            width: 2,
          ),
        )
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: BorderDirectional(
          bottom: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          )
        )
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.red),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Section Titres ---
              const SizedBox(height: 16),
              Text(
                "Entrez le code de vérification",
                style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                  children: [
                    const TextSpan(text: "Nous vous avons envoyé un code à 6 chiffres sur le "),
                    TextSpan(
                      text: controller.completePhoneNumber.value,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // --- Champ de Saisie OTP avec Pinput ---
              Center(
                child: Pinput(
                  length: 6,
                  controller: controller.smsCodeController,
                  focusNode: controller.focusNode,
                  autofocus: true,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: focusedPinTheme,
                  errorPinTheme: errorPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 8),
                  onCompleted: (pin) => controller.verifyOtp(),
                  onChanged: (value) {
                    controller.errorMessage.value = ''; // Effacer l'erreur en tapant
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Affichage de l'erreur
              Obx(() {
                if(controller.errorMessage.isNotEmpty) {
                  return Center(child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)));
                }
                return const SizedBox.shrink();
              }),

              const Spacer(),

              // --- Bouton Renvoyer et Connexion ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Compte à rebours
                  Obx(() => TextButton.icon(
                    onPressed: controller.canResend.value ? controller.resendOtp : null,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(
                      controller.canResend.value
                          ? "Renvoyer le code"
                          : "Renvoyer dans ${controller.resendCooldown.value}s",
                    ),
                  )),
                  // Bouton de connexion
                  Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () => controller.verifyOtp(),
                    child: controller.isLoading.value
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
                        : const Text("Login"),
                  )),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}