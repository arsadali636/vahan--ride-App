import 'package:flutter/material.dart';

/// Central corner-radius scale.
///
/// Screens and components must use these radii instead of inline values.
class AppRadius {
  AppRadius._();

  static const double xs = 2;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 16;
  static const double xl = 24;
  static const double circular = 999;

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderCircular = BorderRadius.all(
    Radius.circular(circular),
  );

  /// Radius applied to the top corners of modals and bottom sheets.
  static const BorderRadius topSheetRadius = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}
