import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toleka_driver/app/routes/app_pages.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            // Utiliser addPostFrameCallback pour naviguer après le build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed(Routes.login);
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed(Routes.login);
            });
          }
        }
        // Pendant que l'on vérifie l'état, afficher un loader
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}