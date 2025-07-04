// lib/app/modules/splash/splash_screen.dart
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ce widget ne fait plus rien d'intelligent.
    // Il attend que AuthService fasse la redirection.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Ou votre logo
      ),
    );
  }
}