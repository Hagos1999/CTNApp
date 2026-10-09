import 'package:flutter/material.dart';

/// CTNApp brand color palette — Green, White & Black
class AppColors {
  AppColors._();

  // ── Primary Green ────────────────────────────────────────────
  static const Color green = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF388E3C);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color greenWithOpacity = Color(0x334CAF50); // 20%

  // ── Accent / Gold (legacy WATT theme → mapped to green) ────
  static const Color gold = Color(0xFF4CAF50);
  static const Color mutedGold = Color(0xFF66BB6A);

  // ── Backgrounds ─────────────────────────────────────────────
  static const Color scaffoldBg = Color(0xFFF5F5F5); // White/Light Gray
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBgElevated = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFFEEEEEE);
  static const Color bottomNavBg = Color(0xFFFFFFFF);

  // ── Text ────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF000000); // Black
  static const Color textSecondary = Color(0xFF424242);
  static const Color textMuted = Color(0xFF757575);
  static const Color textGreen = Color(0xFF4CAF50);

  // ── Status ──────────────────────────────────────────────────
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);

  // ── Input / Border ──────────────────────────────────────────
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocusBorder = Color(0xFF4CAF50);
  static const Color divider = Color(0xFFE0E0E0);

  // ── Gradients ───────────────────────────────────────────────
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradientVertical = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGreenGlow = LinearGradient(
    colors: [Color(0x1A4CAF50), Color(0x004CAF50)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
