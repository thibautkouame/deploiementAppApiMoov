// lib/src/themes/theme.dart

import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3AE374);  // Bleu principal
  static const Color secondary = Color(0xFFFFB300); // Jaune secondaire
  static const Color accent = Color(0xFF1C1C1C);    // Couleur d'accentuation
  static const Color background = Color(0xFFF0F0F0); // Fond clair
  static const Color textPrimary = Color(0xFF212121); // Texte principal
  static const Color textSecondary = Color(0xFF757575); // Texte secondaire
  static const Color error = Color(0xFFD32F2F);   // Rouge pour les erreurs
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16.0,
    color: AppColors.textSecondary,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle errorText = TextStyle(
    fontSize: 14.0,
    color: AppColors.error,
  );
}

