import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: controller.onboardingPages.length,
            itemBuilder: (context, index) {
              final pageData = controller.onboardingPages[index];
              return OnboardingPageWidget(
                lottieAsset: pageData['lottie']!,
                title: pageData['title']!,
                description: pageData['description']!,
              );
            },
          ),
          Positioned(
            bottom: 80.0,
            left: 20.0,
            right: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => controller.currentPageIndex.value == 0
                    ? TextButton(
                  onPressed: controller.skipOnboarding,
                  child: Text('Passer', style: TextStyle(color: theme.hintColor)),
                )
                    : const SizedBox(width: 70) // Pour garder l'alignement
                ),
                SmoothPageIndicator(
                  controller: controller.pageController,
                  count: controller.onboardingPages.length,
                  effect: WormEffect(
                    dotHeight: 10,
                    dotWidth: 10,
                    activeDotColor: theme.colorScheme.primary,
                    dotColor: theme.disabledColor.withAlpha((theme.disabledColor.alpha * 0.5).round()),
                    type: WormType.thin,
                  ),
                  onDotClicked: (index) {
                    controller.pageController.animateToPage(
                      index,
                      duration: 300.milliseconds,
                      curve: Curves.ease,
                    );
                  },
                ),
                Obx(() => TextButton(
                  onPressed: controller.nextPage,
                  child: Text(
                    controller.currentPageIndex.value == controller.onboardingPages.length - 1
                        ? 'Terminé'
                        : 'Suivant',
                  ),
                )),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Obx(() => controller.currentPageIndex.value != 0 && controller.currentPageIndex.value != controller.onboardingPages.length -1
                ? TextButton(
              onPressed: controller.skipOnboarding,
              child: Text('Passer', style: TextStyle(color: theme.hintColor)),
            )
                : const SizedBox.shrink()
            ),
          )
        ],
      ),
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final String lottieAsset;
  final String title;
  final String description;

  const OnboardingPageWidget({
    super.key,
    required this.lottieAsset,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Lottie.asset(
              lottieAsset,
              width: Get.width * 0.8,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 15),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyMedium?.color),
          ),
          const Spacer(flex: 2), // Pour pousser le contenu vers le haut
        ],
      ),
    );
  }
}