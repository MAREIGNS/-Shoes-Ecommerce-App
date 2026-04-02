import 'package:flutter/material.dart';

/// Centralized colors for consistency and easy theme changes.
/// Keeps the app visually consistent and reduces magic numbers.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFFF4500);
  static const Color primaryLight = Color(0xFFFF6B35);
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceVariant = Color(0xFF1E1E1E);

  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFE53935);

  static Color whiteOpacity(double opacity) => Colors.white.withOpacity(opacity);
  static Color primaryOpacity(double opacity) => primary.withOpacity(opacity);
}
