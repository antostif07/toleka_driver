import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../theme/app_theme.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/login-register-bg.webp',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),

          // Un dégradé sombre en bas pour assurer la lisibilité du texte
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withAlpha((0.8 * 255).toInt()), Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.4, 0.7, 1.0],
              ),
            ),
          ),

          Positioned(
            top: 64,
            left: 64,
            right: 64,
            child: Image.asset("assets/images/logo-pro.png"),
          ),
          // Le contenu positionné en bas
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Utilisation du style du titre
                Text(
                  "Prenez le volant de votre avenir.\nConduisez votre succès.",
                  style: AppTheme.onboardingHeadline,
                ),
                const SizedBox(height: 16),

                // Utilisation du style du sous-titre
                Text(
                  "Transformez chaque course en revenu et chaque trajet en opportunité.",
                  style: AppTheme.onboardingSubtitle,
                ),
                const SizedBox(height: 24),

                // Vos boutons ici
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () { Get.toNamed(Routes.login); },
                    child: const Text("Connexion", style: TextStyle(fontSize: 16,)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      )
    );
  }

}