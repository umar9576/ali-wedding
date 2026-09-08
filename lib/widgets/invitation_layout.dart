import 'package:flutter/material.dart';

class InvitationLayout {
  InvitationLayout._();

  static const double canvasWidth = 1024;
  static const double canvasHeight = 1536;
  static const String imageAsset = 'assets/invitation/card.jpg';

  static const double guestBoxLeft = 118;
  static const double guestBoxTop = 686;
  static const double guestBoxWidth = 788;
  static const double guestBoxHeight = 112;
  static const double contentPaddingHorizontal = 42;
  static const double contentPaddingVertical = 20;

  static const String fontFamily = 'Amiri';
  static const double fontSize = 48;
  static const double minFontSize = 28;
  static const FontWeight fontWeight = FontWeight.w700;
  static const Color textColor = Color(0xFF3B2A18);

  static String guestLine(String prefix, String name) {
    final trimmedPrefix = prefix.trim();
    if (trimmedPrefix.isEmpty) {
      return name;
    }
    return '$trimmedPrefix / $name';
  }
}
