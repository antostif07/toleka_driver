// lib/app/modules/auth/login/login_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 64.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                        'Entrez votre numéro de téléphone pour continuer',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 24, letterSpacing: 0.5, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        'Nous allons envoyer un code de vérification à votre numéro de téléphone.',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 12, letterSpacing: 0.5, fontWeight: FontWeight.bold, color: Colors.grey)
                    ),
                    const SizedBox(height: 32),

                    IntlPhoneField(
                      controller: controller.phoneNumberController, // Contrôleur de texte
                      decoration: InputDecoration(
                        labelText: 'Numéro de téléphone',
                        hintText: "999000000",
                        filled: true,
                        fillColor: Colors.transparent,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        )
                      ),
                      initialCountryCode: 'CD',
                      languageCode: 'fr',
                      onChanged: (phone) {
                        controller.completePhoneNumber.value = phone.completeNumber;
                      },
                      validator: (phone) {
                        if (phone == null || phone.number.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone.';
                        }
                        if (!phone.isValidNumber()) { // Validation intégrée du package
                          return 'Numéro de téléphone invalide.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    Obx(() {
                      return ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.sendOtp,
                        child: controller.isLoading.value
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black))
                            : const Text('Envoyer le code'),
                      );
                    }),
                    const SizedBox(height: 20),

                    Obx(() {
                      if (controller.errorMessage.value.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              )
          ),
      ),
    );
  }
}