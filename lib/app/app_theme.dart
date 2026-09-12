import 'package:flutter/material.dart';

import '../design_system/theme/design_system_theme.dart';

/// Application theme access point.
///
/// Everything visual is centralized in the design system; this wrapper is the
/// single reference used by the app shell. Add theme extensions here when
/// needed.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => DesignSystemTheme.lightTheme;

  static ThemeData get darkTheme => DesignSystemTheme.darkTheme;
}
