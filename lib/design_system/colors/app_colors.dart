import 'package:flutter/material.dart';

/// Central color tokens for DocConnect Pro design system.
///
/// Refreshed to match the DocConnect Pro redesign color specification:
/// - Primary blue: #0066FF
/// - Dark navy text: #101828
/// - Secondary text: #667085
/// - Main background: #F5F8FC
/// - Card background: #FFFFFF
/// - Border: #E4EAF2
/// - Success green: #12B76A
/// - Error red: #D92D20
/// - Subtle divider: #EAECF0
/// - Inactive Nav: #24344D
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryDark = Color(0xFF0052CC);
  static const Color secondary = Color(0xFF2563EB);
  static const Color workforce = Color(0xFF12B76A);

  // Surfaces
  static const Color background = Color(0xFFF5F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0F4F9);

  // Text
  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textDisabled = Color(0xFF98A2B3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Navigation
  static const Color navActive = Color(0xFF0066FF);
  static const Color navInactive = Color(0xFF24344D);

  // Status
  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFD92D20);

  // Borders / dividers
  static const Color border = Color(0xFFE4EAF2);
  static const Color borderStrong = Color(0xFFD0D5DD);
  static const Color divider = Color(0xFFEAECF0);

  // Overlays
  static const Color scrim = Color(0x99000000);

  // Dark-mode surfaces
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceDarkMuted = Color(0xFF26262B);

  // Dark-mode text
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Aliases (kept for backward compatibility)
  static const Color primaryVariant = primaryDark;
  static const Color backgroundLight = background;
  static const Color surfaceLight = surface;
  static const Color textPrimaryLight = textPrimary;
  static const Color textSecondaryLight = textSecondary;
}
