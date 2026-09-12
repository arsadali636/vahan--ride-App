import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

/// Central typography tokens.
///
/// Every text style in the app is defined here. Widgets and screens must use
/// these styles (or the `TextTheme` derived from them) instead of defining
/// their own `TextStyle`.
class AppTypography {
  AppTypography._();

  // Weights
  static const FontWeight wRegular = FontWeight.w400;
  static const FontWeight wMedium = FontWeight.w500;
  static const FontWeight wSemiBold = FontWeight.w600;
  static const FontWeight wBold = FontWeight.w700;

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontSize: 34,
    fontWeight: wBold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 30,
    fontWeight: wBold,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  // Headings
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: wBold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: wSemiBold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: wSemiBold,
    color: AppColors.textPrimary,
    height: 1.35,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: wSemiBold,
    color: AppColors.textPrimary,
    height: 1.35,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: wSemiBold,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: wRegular,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: wRegular,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: wRegular,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: wSemiBold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: wMedium,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: wMedium,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // Misc
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: wMedium,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
    height: 1.4,
  );
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: wSemiBold,
    color: AppColors.textSecondary,
    letterSpacing: 1.0,
    height: 1.3,
  );
}
