import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'profile_completion_controller.dart';

class Step0VehiclePreference extends StatelessWidget {
  const Step0VehiclePreference({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileCompletionController>();

    // On définit les données de nos cartes ici pour plus de clarté
    final preferences = [
      {
        'title': "J'ai une voiture",
        'description': "Vous possédez ou prévoyez d'acheter un véhicule. Vous conduirez vous-même mais pourriez aussi employer d'autres personnes pour conduire votre véhicule.",
        'imagePath': 'assets/images/has_car.webp',
        'preference': VehiclePreference.iHaveACar,
      },
      {
        'title': "J'ai besoin d'une voiture",
        'description': "Je souhaite être employé comme chauffeur par un des partenaires de Toleka et conduire pour eux.",
        'imagePath': 'assets/images/needs_car.webp',
        'preference': VehiclePreference.iNeedACar,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Titres ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Indiquez votre préférence de véhicule",
                  style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // --- LE CARROUSEL ---
          SizedBox(
            height: 400, // Donner une hauteur fixe au carrousel
            child: PageView.builder(
              controller: controller.page0Controller,
              itemCount: preferences.length,
              itemBuilder: (context, index) {
                final pref = preferences[index];
                return _PreferenceCard(
                  title: pref['title'] as String,
                  description: pref['description'] as String,
                  imagePath: pref['imagePath'] as String,
                  onTap: () => controller.selectVehiclePreference(pref['preference'] as VehiclePreference),
                );
              },
            ),
          ),

          // --- Indicateurs de page (les points) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(preferences.length, (index) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(index == 0 ? 0.9 : 0.4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET DE CARTE SÉPARÉ POUR LA LISIBILITÉ ---
class _PreferenceCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final VoidCallback onTap;

  const _PreferenceCard({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // On ajoute un padding pour que les cartes ne soient pas collées
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                imagePath,
                height: 180, // On réduit un peu la hauteur de l'image
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              // On enveloppe le reste dans un Expanded pour qu'il prenne la place restante
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // On limite le nombre de lignes pour éviter les débordements
                      Text(
                        description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(), // Le Spacer pousse la flèche vers le bas
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}