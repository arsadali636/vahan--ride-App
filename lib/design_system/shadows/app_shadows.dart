import 'package:flutter/material.dart';

/// Central shadow scale.
///
/// All elevation in the app is defined here. Shadows are subtle and neutral to
/// keep the MedNexus visual language clean.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Single-shadow convenience for cards.
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 10,
    offset: Offset(0, 4),
  );
}
