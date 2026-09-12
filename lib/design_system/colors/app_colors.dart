import 'package:flutter/material.dart';

/// Central color tokens.
///
/// No feature screen, widget, or component may define colors manually — always
/// reference these tokens or the Material `Theme`/`ColorScheme` derived from
/// them. Changing a value here updates the entire app through
/// `DesignSystemTheme`.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF5B3CC4);
  static const Color primaryDark = Color(0xFF3D267F);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color workforce = Color(0xFF20B486);

  // Surfaces
  static const Color background = Color(0xFFF8F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3F1F4);

  // Text
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF6B6B73);
  static const Color textDisabled = Color(0xFF9E9EA6);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF16A673);
  static const Color warning = Color(0xFFD99000);
  static const Color error = Color(0xFFD94F4F);

  // Borders / dividers
  static const Color border = Color(0xFFE5E3E8);
  static const Color borderStrong = Color(0xFFD2CFD6);

  // Overlays
  static const Color scrim = Color(0x99000000);

  // Dark-mode surfaces
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceDarkMuted = Color(0xFF26262B);

  // Dark-mode text
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Aliases (kept for readability and gradual migration)
  static const Color primaryVariant = primaryDark;
  static const Color backgroundLight = background;
  static const Color surfaceLight = surface;
  static const Color textPrimaryLight = textPrimary;
  static const Color textSecondaryLight = textSecondary;
}
