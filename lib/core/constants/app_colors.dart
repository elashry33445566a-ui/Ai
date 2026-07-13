import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryDark = Color(0xFF00A882);
  static const Color primaryLight = Color(0xFF33DDB8);
  static const Color primaryAccent = Color(0xFF00FFD1);

  // Secondary Palette
  static const Color secondary = Color(0xFF7C4DFF);
  static const Color secondaryDark = Color(0xFF5E35C9);
  static const Color secondaryLight = Color(0xFF9E74FF);

  // Backgrounds
  static const Color backgroundDark = Color(0xFF0A0E1A);
  static const Color backgroundCard = Color(0xFF131929);
  static const Color backgroundSurface = Color(0xFF1A2236);
  static const Color backgroundElevated = Color(0xFF212D42);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BAD0);
  static const Color textMuted = Color(0xFF6B7A9A);
  static const Color textHint = Color(0xFF4A5568);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF2196F3);

  // Nutrition Macro Colors
  static const Color protein = Color(0xFF7C4DFF);
  static const Color carbs = Color(0xFFFFC107);
  static const Color fats = Color(0xFFFF6B6B);
  static const Color caloriesColor = Color(0xFF00D4AA);
  static const Color fiber = Color(0xFF4CAF50);
  static const Color water = Color(0xFF2196F3);

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF7C4DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0E1A), Color(0xFF131929)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A2236), Color(0xFF131929)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Borders
  static const Color border = Color(0xFF2A3452);
  static const Color divider = Color(0xFF1E2A40);

  // Overlays
  static const Color overlayDark = Color(0xCC000000);
  static const Color overlayLight = Color(0x1AFFFFFF);

  // Shimmer
  static const Color shimmerBase = Color(0xFF1A2236);
  static const Color shimmerHighlight = Color(0xFF2A3452);
}
