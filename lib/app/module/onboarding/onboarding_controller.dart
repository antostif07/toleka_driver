import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  RxInt currentPageIndex = 0.obs;

  // Contenu pour chaque slide (à personnaliser)
  final List<Map<String, String>> onboardingPages = [
    {
      'lottie': 'assets/lotties/onboarding_1.json', // Mettez vos chemins
      'title': 'Bienvenue sur Toleka !',
      'description': 'Votre solution de transport simple et rapide.',
    },
    {
      'lottie': 'assets/lotties/driver.json',
      'title': 'Trouvez un chauffeur',
      'description': 'Localisez facilement des chauffeurs près de vous.',
    },
    {
      'lottie': 'assets/lotties/map.json',
      'title': 'Voyagez en sécurité',
      'description': 'Profitez d\'un trajet confortable et sécurisé vers votre destination.',
    },
  ];

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentPageIndex.value = index;
  }

  void nextPage() {
    if (currentPageIndex.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: 300.milliseconds,
        curve: Curves.ease,
      );
    } else {
      // Dernière page, aller à l'authentification
      completeOnboarding();
    }
  }

  void skipOnboarding() {
    completeOnboarding();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    // Get.offAllNamed(Routes.AUTH_PHONE_INPUT); // Ou la route vers votre écran de login/téléphone
  }

  Future<bool> checkIfAlreadySeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenOnboarding') ?? false;
  }
}