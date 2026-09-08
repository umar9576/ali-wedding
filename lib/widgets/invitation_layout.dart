import 'dart:math';

import 'package:flutter/material.dart';

import '../models/invitation_kind.dart';

class InvitationLayout {
  InvitationLayout._();

  static const double canvasWidth = 1024;
  static const double canvasHeight = 1536;

  static const String groomAsset = 'assets/invitation/card_groom.jpg';
  static const String fatherAsset = 'assets/invitation/card_father.jpg';

  static const Color overlayFill = Color(0xFFF4EBDA);
  static const Color textColor = Color(0xFF382718);
  static const String fontFamily = 'Amiri';
  static const FontWeight fontWeight = FontWeight.w700;

  static const double guestTextLeft = 395;
  static const double guestTextTop = 688;
  static const double guestTextWidth = 500;
  static const double guestTextHeight = 56;
  static const double guestFontSize = 44;
  static const double guestMinFontSize = 27;

  static const double seatValueLeft = 118;
  static const double seatValueTop = 711;
  static const double seatValueWidth = 155;
  static const double seatValueHeight = 38;
  static const double seatFontSize = 34;
  static const double seatMinFontSize = 24;

  static const double reservationLeft = 88;
  static const double reservationTop = 784;
  static const double reservationWidth = 215;
  static const double reservationHeight = 40;
  static const double reservationFontSize = 22;
  static const double reservationMinFontSize = 16;

  static const int minSeatCount = 1;
  static const int maxSeatCount = 20;
  static const int defaultSeatCount = 2;

  static String assetFor(InvitationKind kind) {
    return switch (kind) {
      InvitationKind.groom => groomAsset,
      InvitationKind.father => fatherAsset,
    };
  }

  static String guestLine(String prefix, String name) {
    final trimmedPrefix = prefix.trim();
    final trimmedName = name.trim();
    if (trimmedPrefix.isEmpty) {
      return trimmedName;
    }
    if (trimmedName.isEmpty) {
      return trimmedPrefix;
    }
    return '$trimmedPrefix / $trimmedName';
  }

  static String seatLine(int seatCount) => '$seatCount';

  static String reservationLine(String number) => 'رقم الحجز $number';

  static String createReservationNumber([Random? random]) {
    final rng = random ?? Random();
    return (1000 + rng.nextInt(9000)).toString();
  }
}
