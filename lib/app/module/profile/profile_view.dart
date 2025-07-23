// lib/app/modules/profile/profile_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_services.dart';
import 'profile_controller.dart'; // Importez votre ProfileController

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService homeController = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        centerTitle: true,
      ),
      // body: Obx(() {
      //   if (homeController.currentDriver == null) {
      //     return const Center(child: CircularProgressIndicator());
      //   }
      //
      //   final driver = homeController.currentDriver;
      //
      //   return SingleChildScrollView(
      //     padding: const EdgeInsets.all(16.0),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       children: [
      //         // --- Section Photo de Profil et Nom ---
      //         Stack( // Utiliser un Stack pour superposer l'avatar et le bouton
      //           children: [
      //             CircleAvatar(
      //               radius: 60,
      //               backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      //               // Utilise l'URL du driver pour l'image
      //               backgroundImage: driver.profilePictureUrl != null && driver.profilePictureUrl!.isNotEmpty
      //                   ? NetworkImage(driver.profilePictureUrl!) as ImageProvider
      //                   : null,
      //               child: driver.profilePictureUrl == null || driver.profilePictureUrl!.isEmpty
      //                   ? Icon(Icons.person, size: 80, color: Theme.of(context).colorScheme.primary)
      //                   : null,
      //             ),
      //             // Bouton pour changer la photo
      //             Positioned(
      //               bottom: 0,
      //               right: 0,
      //               child: Obx(() { // Obx pour réagir à l'état d'upload
      //                 return controller.isUploading.value
      //                     ? const CircularProgressIndicator() // Indicateur de chargement
      //                     : GestureDetector(
      //                   onTap: controller.pickAndUploadProfilePicture,
      //                   child: CircleAvatar(
      //                     radius: 20,
      //                     backgroundColor: Theme.of(context).colorScheme.primary, // Couleur du thème
      //                     child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
      //                   ),
      //                 );
      //               }),
      //             ),
      //           ],
      //         ),
      //         const SizedBox(height: 16),
      //         Text(
      //           driver.fullName,
      //           style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      //           textAlign: TextAlign.center,
      //         ),
      //         Text(
      //           'ID Conducteur: ${driver.driverID}',
      //           style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
      //           textAlign: TextAlign.center,
      //         ),
      //         const SizedBox(height: 24),
      //         const Divider(),
      //         const SizedBox(height: 16),
      //
      //         // --- Reste de votre code de ProfileView (informations de contact, véhicule, stats, dates, bouton déconnexion) ---
      //         // ...
      //         Card(
      //           margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      //           elevation: 2,
      //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //           child: Column(
      //             children: [
      //               ListTile(
      //                 leading: const Icon(Icons.email, color: Colors.blueGrey),
      //                 title: const Text('E-mail'),
      //                 subtitle: Text(driver.email),
      //               ),
      //               ListTile(
      //                 leading: const Icon(Icons.phone, color: Colors.blueGrey),
      //                 title: const Text('Téléphone'),
      //                 subtitle: Text(driver.phoneNumber),
      //               ),
      //             ],
      //           ),
      //         ),
      //         const SizedBox(height: 16),
      //
      //         Card(
      //           margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      //           elevation: 2,
      //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //           child: Column(
      //             children: [
      //               ListTile(
      //                 leading: const Icon(Icons.directions_car, color: Colors.teal),
      //                 title: const Text('Modèle du Véhicule'),
      //                 subtitle: Text(driver.vehicleModel),
      //               ),
      //               ListTile(
      //                 leading: const Icon(Icons.color_lens, color: Colors.teal),
      //                 title: const Text('Couleur du Véhicule'),
      //                 subtitle: Text(driver.vehicleColor),
      //               ),
      //               ListTile(
      //                 leading: const Icon(Icons.badge, color: Colors.teal),
      //                 title: const Text('Plaque d\'immatriculation'),
      //                 subtitle: Text(driver.licensePlate),
      //               ),
      //             ],
      //           ),
      //         ),
      //         const SizedBox(height: 16),
      //
      //         Card(
      //           margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      //           elevation: 2,
      //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //           child: Column(
      //             children: [
      //               ListTile(
      //                 leading: const Icon(Icons.star_half, color: Colors.amber),
      //                 title: const Text('Note Moyenne'),
      //                 subtitle: Text('${driver.rating.toStringAsFixed(1)} / 5.0'),
      //               ),
      //               ListTile(
      //                 leading: const Icon(Icons.local_taxi, color: Colors.blue),
      //                 title: const Text('Courses Terminées'),
      //                 subtitle: Text('${driver.totalRides}'),
      //               ),
      //               ListTile(
      //                 leading: const Icon(Icons.monetization_on, color: Colors.green),
      //                 title: const Text('Gains Journaliers'),
      //                 subtitle: Text('${driver.dailyEarnings.toStringAsFixed(0)} CFA'),
      //               ),
      //             ],
      //           ),
      //         ),
      //         const SizedBox(height: 16),
      //
      //         Card(
      //           margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      //           elevation: 2,
      //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //           child: Column(
      //             children: [
      //               ListTile(
      //                 leading: const Icon(Icons.date_range, color: Colors.purple),
      //                 title: const Text('Membre depuis'),
      //                 subtitle: Text(
      //                   '${driver.createdAt.day}/${driver.createdAt.month}/${driver.createdAt.year}',
      //                 ),
      //               ),
      //               if (driver.updatedAt != null)
      //                 ListTile(
      //                   leading: const Icon(Icons.update, color: Colors.purple),
      //                   title: const Text('Dernière mise à jour'),
      //                   subtitle: Text(
      //                     '${driver.updatedAt!.day}/${driver.updatedAt!.month}/${driver.updatedAt!.year} à ${driver.updatedAt!.hour}h${driver.updatedAt!.minute}',
      //                   ),
      //                 ),
      //             ],
      //           ),
      //         ),
      //         const SizedBox(height: 24),
      //
      //         ElevatedButton.icon(
      //           icon: const Icon(Icons.logout),
      //           label: const Text('Se Déconnecter'),
      //           onPressed: homeController.logout,
      //           style: ElevatedButton.styleFrom(
      //             backgroundColor: Colors.red.shade600,
      //             foregroundColor: Colors.white,
      //             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //           ),
      //         ),
      //       ],
      //     ),
      //   );
      // }),
    );
  }
}