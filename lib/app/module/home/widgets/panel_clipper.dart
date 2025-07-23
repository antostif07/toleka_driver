import 'package:flutter/material.dart';

class PanelClipper extends CustomClipper<Path> {
  final double panelCornerRadius;
  final double notchWidth;
  final double notchDepth;

  /// Le rayon pour arrondir les coins qui entrent et sortent de l'encoche.
  final double notchTransitionRadius;

  PanelClipper({
    this.panelCornerRadius = 12.0,
    required this.notchWidth,
    required this.notchDepth,
    this.notchTransitionRadius = 8.0, // Un bon rayon de transition
  });

  @override
  Path getClip(Size size) {
    // Calculs géométriques
    final center = size.width / 2;
    final notchRadius = notchDepth; // Pour les coins bas de l'encoche

    // Points clés sur l'axe X pour définir l'encoche
    final notchLeft = center - notchWidth / 2;
    final notchRight = center + notchWidth / 2;

    final path = Path()
      ..moveTo(0, panelCornerRadius)
      ..arcToPoint(Offset(panelCornerRadius, 0), radius: Radius.circular(panelCornerRadius))

    // Ligne jusqu'au DÉBUT de la transition vers l'encoche
      ..lineTo(notchLeft - notchTransitionRadius, 0)

    // --- TRANSITION ARRONDIE GAUCHE (Entrée de l'encoche) ---
    // Le point de contrôle est le coin pointu que nous voulons éviter.
    // Le point de fin est le début de la ligne verticale de l'encoche.
      ..quadraticBezierTo(
        notchLeft, 0, // Point de contrôle (le coin)
        notchLeft, notchTransitionRadius, // Point de fin
      )

    // Ligne verticale gauche de l'encoche (maintenant plus courte)
      ..lineTo(notchLeft, notchDepth - notchRadius)

    // --- Coin arrondi en bas à gauche de l'encoche ---
      ..arcToPoint(
        Offset(notchLeft + notchRadius, notchDepth),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )

    // Ligne droite au fond de l'encoche
      ..lineTo(notchRight - notchRadius, notchDepth)

    // --- Coin arrondi en bas à droite de l'encoche ---
      ..arcToPoint(
        Offset(notchRight, notchDepth - notchRadius),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )

    // Ligne verticale droite de l'encoche (maintenant plus courte)
      ..lineTo(notchRight, notchTransitionRadius)

    // --- TRANSITION ARRONDIE DROITE (Sortie de l'encoche) ---
      ..quadraticBezierTo(
        notchRight, 0, // Point de contrôle (le coin)
        notchRight + notchTransitionRadius, 0, // Point de fin
      )

      ..lineTo(size.width - panelCornerRadius, 0)
      ..arcToPoint(Offset(size.width, panelCornerRadius), radius: Radius.circular(panelCornerRadius))
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}