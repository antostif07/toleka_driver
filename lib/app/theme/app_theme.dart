// lib/app/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // On ne veut pas que cette classe soit instanciée
  AppTheme._();

  // --- COULEURS ---
  static const Color _primaryColor = Color(0xFFFFC107); // Un beau jaune (Amber de Material)
  static const Color _primaryColorDark = Color(0xFFFFA000); // Un peu plus foncé pour les variantes
  static const Color _textColorDark = Colors.black;
  static const Color _textColorLight = Colors.white;

  // --- LE THÈME LUMINEUX ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Définition de la palette de couleurs
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      primary: _primaryColor,
      brightness: Brightness.light,
    ),

    // Personnalisation de la police (optionnel mais recommandé)
    // N'oubliez pas d'ajouter le package google_fonts au pubspec.yaml
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    ).apply(
      bodyColor: _textColorDark,
      displayColor: _textColorDark,
    ),

    // --- Personnalisation des Widgets ---

    // AppBar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: _primaryColor,
      foregroundColor: _textColorDark, // Couleur du titre et des icônes
    ),

    // Boutons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor, // Le fond jaune comme demandé
        foregroundColor: _textColorDark, // Le texte en noir comme demandé
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // Champs de texte
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryColorDark, width: 2),
      ),
    ),

    // ... vous pouvez ajouter d'autres personnalisations ici (CardTheme, etc.)
  );
}