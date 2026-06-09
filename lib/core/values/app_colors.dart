import 'package:flutter/material.dart';

/// Palette de l'application — direction « néo-banque » (Revolut / BitStack) :
/// fonds profonds, accents indigo→violet vibrants, verre dépoli et lueurs douces.
abstract class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6D5DF6); // Indigo-violet vibrant
  static const Color primaryDark = Color(0xFF5B4FE0);
  static const Color secondary = Color(0xFF22D3EE); // Cyan
  static const Color accent = Color(0xFFFBBF24); // Amber

  // Semantics
  static const Color gain = Color(0xFF12D18E); // Emerald lumineux
  static const Color spent = Color(0xFFFB5468); // Rose-rouge
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Light theme
  static const Color lightBg = Color(0xFFF6F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFEEF1F8);
  static const Color lightOnBg = Color(0xFF0B1020);
  static const Color lightOnSurface = Color(0xFF1E293B);
  static const Color lightMuted = Color(0xFF6B7488);
  static const Color lightBorder = Color(0xFFE6E9F2);

  // Dark theme — fonds quasi-noirs légèrement bleutés (profondeur Revolut)
  static const Color darkBg = Color(0xFF070A12);
  static const Color darkSurface = Color(0xFF111726);
  static const Color darkSurfaceAlt = Color(0xFF192031);
  static const Color darkOnBg = Color(0xFFF4F6FB);
  static const Color darkOnSurface = Color(0xFFE5E9F2);
  static const Color darkMuted = Color(0xFF8A93A8);
  static const Color darkBorder = Color(0xFF222A3D);

  // Gradients — accents premium
  static const List<Color> primaryGradient = [Color(0xFF7C6BFF), Color(0xFFA855F7)];
  static const List<Color> gainGradient = [Color(0xFF2DE0A6), Color(0xFF10B981)];
  static const List<Color> spentGradient = [Color(0xFFFF7A8A), Color(0xFFF43F5E)];
  static const List<Color> heroGradient = [
    Color(0xFF7C6BFF),
    Color(0xFFA855F7),
    Color(0xFF22D3EE),
  ];

  /// Lueurs d'ambiance (blobs flous derrière le contenu).
  static const Color glowViolet = Color(0xFF7C6BFF);
  static const Color glowCyan = Color(0xFF22D3EE);
  static const Color glowEmerald = Color(0xFF12D18E);

  static List<Color> chartPalette(Brightness b) => const [
        Color(0xFF7C6BFF),
        Color(0xFF22D3EE),
        Color(0xFF12D18E),
        Color(0xFFFBBF24),
        Color(0xFFFB5468),
        Color(0xFFA855F7),
        Color(0xFFEC4899),
        Color(0xFF14B8A6),
      ];
}
