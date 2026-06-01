import 'package:flutter/material.dart';

/// Palette de l'application. Construite autour d'un indigo "fintech" + accents
/// vert (gains) / rouge (dépenses).
abstract class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color primaryDark = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color accent = Color(0xFFFBBF24); // Amber

  // Semantics
  static const Color gain = Color(0xFF10B981); // Emerald
  static const Color spent = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Light theme
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF1F5F9);
  static const Color lightOnBg = Color(0xFF0F172A);
  static const Color lightOnSurface = Color(0xFF1E293B);
  static const Color lightMuted = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark theme
  static const Color darkBg = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceAlt = Color(0xFF1F2937);
  static const Color darkOnBg = Color(0xFFF1F5F9);
  static const Color darkOnSurface = Color(0xFFE5E7EB);
  static const Color darkMuted = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF1F2937);

  // Gradients
  static const List<Color> primaryGradient = [Color(0xFF4F46E5), Color(0xFF7C3AED)];
  static const List<Color> gainGradient = [Color(0xFF10B981), Color(0xFF059669)];
  static const List<Color> spentGradient = [Color(0xFFEF4444), Color(0xFFDC2626)];
  static const List<Color> heroGradient = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
    Color(0xFF06B6D4),
  ];

  static List<Color> chartPalette(Brightness b) => const [
        Color(0xFF6366F1),
        Color(0xFF06B6D4),
        Color(0xFF10B981),
        Color(0xFFF59E0B),
        Color(0xFFEF4444),
        Color(0xFF8B5CF6),
        Color(0xFFEC4899),
        Color(0xFF14B8A6),
      ];
}
