import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toleka_driver/app/module/auth/profile_completion/step0_vehicle_pref.dart';
import 'package:toleka_driver/app/module/auth/profile_completion/step1_personal_info.dart';
import 'profile_completion_controller.dart';

class ProfileCompletionView extends GetView<ProfileCompletionController> {
  const ProfileCompletionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compléter votre profil"),
        backgroundColor: Colors.white,
        // Indicateur de progression dans l'app bar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Obx(() => LinearProgressIndicator(
            value: (controller.currentPage.value + 1) / controller.totalPages,
            backgroundColor: Colors.grey[300],
          )),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller.pageController,
              // Empêcher le swipe manuel pour forcer l'utilisation des boutons
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                controller.currentPage.value = index;
              },
              children: [
                Step0VehiclePreference(),
                Step1PersonalInfo(),
                // Step2VehicleInfo(),
                // Step3Documents(),
              ],
            ),
          ),
          // Boutons de navigation en bas
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: Obx(() {
                // Le bouton change en fonction de la page
                bool isLastPage = controller.currentPage.value == controller.totalPages - 1;
                return ElevatedButton(
                  onPressed: isLastPage ? controller.completeProfile : controller.nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                      : Text(isLastPage ? "Terminer l'inscription" : "Suivant"),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}