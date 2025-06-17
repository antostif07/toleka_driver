import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:toleka_driver/app/theme/app_theme.dart';

import 'app/routes/app_pages.dart';
import 'app/services/auth_services.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MapboxOptions.setAccessToken("pk.eyJ1IjoiYW50b3N0aXVzaGluZGkiLCJhIjoiY21hOG5qYmJjMWUxbDJxcXppYnkwZHZwNCJ9.9Gnm6R1Pa-BY9S96bs9vbg");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = Get.put(AuthService(), permanent: true);
  authService.onReady;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Toleka Chauffeur',
      initialRoute: AppPages.INITIAL, // Sera défini dans vos routes
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // home: StreamBuilder<User?>(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Scaffold(body: Center(child: CircularProgressIndicator())); // Écran de chargement
      //     }
      //     if (snapshot.hasData && snapshot.data != null) {
      //       // Utilisateur connecté
      //       // Il est important que le dashboard ait son propre binding via GetPage.
      //       // On peut naviguer ici, mais GetX s'assurera que le binding est chargé.
      //       // Pour être sûr que le binding est appelé, il vaut mieux laisser GetX gérer la navigation via initialRoute
      //       // et avoir un "splash" ou "auth wrapper" screen qui gère cette logique.
      //       // Pour une solution rapide :
      //       // Future.microtask(() => Get.offAllNamed(Routes.DRIVER_DASHBOARD));
      //       // return const Scaffold(body: Center(child: CircularProgressIndicator())); // Évite le flash de l'écran Auth
      //
      //       // Solution plus propre avec un "wrapper":
      //       // Créons un écran intermédiaire qui décide où aller.
      //       WidgetsBinding.instance.addPostFrameCallback((_) {
      //         Get.offAllNamed(Routes.DRIVER_DASHBOARD);
      //       });
      //       return const Scaffold(body: Center(child: Text("Redirection..."))); // Ou un vrai splash
      //     } else {
      //       // Utilisateur non connecté
      //       WidgetsBinding.instance.addPostFrameCallback((_) {
      //         Get.offAllNamed(Routes.AUTH);
      //       });
      //       return const Scaffold(body: Center(child: Text("Redirection..."))); // Ou un vrai splash
      //     }
      //     // Si on utilise initialRoute avec un wrapper, cette partie n'est pas nécessaire.
      //     // return AuthScreen(); // Fallback
      //   },
      // ),
      // theme: ThemeData(...) // Thème spécifique pour l'app chauffeur
    );
  }
}