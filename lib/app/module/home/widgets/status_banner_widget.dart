import 'package:flutter/material.dart';

/// Un widget de bannière pour afficher des notifications ou des statuts importants.
class StatusBannerWidget extends StatelessWidget {
  /// Le message principal à afficher sur la bannière.
  final String message;

  /// La fonction à appeler lorsque l'utilisateur appuie sur la bannière.
  final VoidCallback? onTap;

  const StatusBannerWidget({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Marge extérieure de la bannière
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0), // Pour un effet d'ondulation arrondi
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            // La couleur de fond gris clair de la bannière
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            // Alignement vertical centré des éléments
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icône d'information à gauche
              const CircleAvatar(
                backgroundColor: Color(0xFF3A385E), // Couleur indigo foncé
                radius: 12,
                child: Icon(
                  Icons.info,
                  color: Colors.white,
                  size: 15,
                ),
              ),
              const SizedBox(width: 12.0),

              // Le texte (prend toute la place disponible)
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    height: 1.3, // Espace entre les lignes de texte
                  ),
                ),
              ),
              const SizedBox(width: 8.0),

              // Flèche vers la droite
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}