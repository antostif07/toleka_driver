import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toleka_driver/app/module/auth/profile_completion/step0_vehicle_pref.dart';
import 'package:toleka_driver/app/module/auth/profile_completion/step1_personal_info.dart';
import 'package:toleka_driver/app/module/auth/profile_completion/step5_profile_photo.dart';
import 'profile_completion_controller.dart';
import 'step2_vehicule_info.dart';
import 'step3_documents.dart';
import 'step4_vehicle_registration.dart';

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
                Step2VehicleInfo(),
                Step3Documents(),
                Step4VehicleRegistration(),
                Step5ProfilePhoto()
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
                final isFirstPage = controller.currentPage.value == 0;
                final isLastPage = controller.currentPage.value == controller.totalPages - 1;

                return Row(
                  children: [
                    // --- BOUTON RETOUR (CONDITIONNEL) ---
                    if (!isFirstPage)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.previousPage,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text("Retour"),
                        ),
                      ),

                    // Ajouter un espace entre les boutons s'ils sont deux
                    if (!isFirstPage) const SizedBox(width: 16),

                    // --- BOUTON SUIVANT / TERMINER ---
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLastPage ? controller.completeProfile : controller.nextPage,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                            : Text(isLastPage ? "Terminer" : "Suivant"),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}