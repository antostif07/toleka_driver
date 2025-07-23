import 'package:flutter/material.dart';

class DriverStats extends StatelessWidget {
  const DriverStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Un léger padding vertical pour l'espacement
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Colonne 1: Gains
            _buildStatColumn(
              titre: 'Gains',
              valeur: '\$12.2',
            ),

            // Séparateur vertical
            SizedBox(
              height: 40,
              child: VerticalDivider(
                color: Colors.grey.shade300,
                thickness: 1,
              ),
            ),

            // Colonne 2: En ligne
            _buildStatColumn(
              titre: 'En ligne',
              valeur: '1h 12min',
            ),

            // Séparateur vertical
            SizedBox(
              height: 40,
              child: VerticalDivider(
                color: Colors.grey.shade300,
                thickness: 1,
              ),
            ),

            // Colonne 3: Courses
            _buildStatColumn(
              titre: 'Courses',
              valeur: '02',
            ),
          ],
        ),
      ),
    );
  }

  /// Méthode d'aide pour construire une seule colonne de statistique
  Widget _buildStatColumn({required String titre, required String valeur}) {
    return Column(
      mainAxisSize: MainAxisSize.min, // La colonne prend la hauteur minimale
      children: [
        Text(
          titre,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          valeur,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}