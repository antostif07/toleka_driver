import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:toleka_driver/app/theme/app_theme.dart';

import 'app/routes/app_pages.dart';
import 'app/services/auth_services.dart';
import 'app/services/driver_location_service.dart';
import 'app/services/driver_map_service.dart';
import 'app/services/location_permission_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MapboxOptions.setAccessToken("pk.eyJ1IjoiYW50b3N0aXVzaGluZGkiLCJhIjoiY21hOG5qYmJjMWUxbDJxcXppYnkwZHZwNCJ9.9Gnm6R1Pa-BY9S96bs9vbg");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(LocationPermissionService(), permanent: true);
  Get.put(DriverLocationService(), permanent: true);
  Get.put(DriverMapService(), permanent: true);

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
      initialRoute: AppPages.initial, // Sera défini dans vos routes
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
    );
  }
}