import 'package:flutter/material.dart';

// Widget principal que vous ajouterez à votre écran
class HelpAndSupportWidget extends StatelessWidget {
  const HelpAndSupportWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Help and support',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildHelpItem(
            icon: Icons.question_mark,
            title: 'Get your queries resolved',
            subtitle: 'Call or chat with us at anytime and get your issues solved instantly',
            onTap: () {
              // Action pour la résolution des requêtes
            },
          ),
          const Padding(
            padding: EdgeInsets.only(left: 56.0), // Aligné avec le texte
            child: Divider(),
          ),
          _buildHelpItem(
            icon: Icons.info_outline,
            title: 'Setup an emergency contact',
            subtitle: 'We\'ll call them if an issue is reported and you don\'t respond.',
            onTap: () {
              // Action pour configurer le contact d'urgence
            },
          ),
        ],
      ),
    );
  }

  /// Crée un élément de la liste d'aide, réutilisable
  Widget _buildHelpItem({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // L'icône
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black87,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            // La colonne de textes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.3),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}