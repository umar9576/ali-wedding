import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/invitation_kind.dart';
import '../widgets/invitation_layout.dart';

class InvitationExportService {
  const InvitationExportService();

  static const double logicalWidth = InvitationLayout.canvasWidth;
  static const double logicalHeight = InvitationLayout.canvasHeight;
  static const double exportWidth = 1080;

  static final Map<String, ui.Image> _cachedBackgrounds = {};

  static double get exportPixelRatio => exportWidth / logicalWidth;

  static double get exportHeight => exportWidth * logicalHeight / logicalWidth;

  Future<Uint8List> capturePng({
    required InvitationKind kind,
    required String prefix,
    required String name,
    required int seatCount,
    required String reservationNumber,
  }) async {
    final background = await _loadBackground(InvitationLayout.assetFor(kind));
    final width = exportWidth.round();
    final height = exportHeight.round();
    final scale = exportWidth / logicalWidth;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint =
        Paint()
          ..isAntiAlias = true
          ..filterQuality = FilterQuality.high;

    canvas.drawImageRect(
      background,
      Rect.fromLTWH(
        0,
        0,
        background.width.toDouble(),
        background.height.toDouble(),
      ),
      Rect.fromLTWH(0, 0, exportWidth, exportHeight),
      paint,
    );

    _paintOverlay(
      canvas: canvas,
      scale: scale,
      left: InvitationLayout.guestTextLeft,
      top: InvitationLayout.guestTextTop,
      width: InvitationLayout.guestTextWidth,
      height: InvitationLayout.guestTextHeight,
      text: InvitationLayout.guestLine(prefix, name),
      fontSize: InvitationLayout.guestFontSize,
      minFontSize: InvitationLayout.guestMinFontSize,
    );
    _paintOverlay(
      canvas: canvas,
      scale: scale,
      left: InvitationLayout.seatValueLeft,
      top: InvitationLayout.seatValueTop,
      width: InvitationLayout.seatValueWidth,
      height: InvitationLayout.seatValueHeight,
      text: InvitationLayout.seatLine(seatCount),
      fontSize: InvitationLayout.seatFontSize,
      minFontSize: InvitationLayout.seatMinFontSize,
    );
    _paintOverlay(
      canvas: canvas,
      scale: scale,
      left: InvitationLayout.reservationLeft,
      top: InvitationLayout.reservationTop,
      width: InvitationLayout.reservationWidth,
      height: InvitationLayout.reservationHeight,
      text: InvitationLayout.reservationLine(reservationNumber),
      fontSize: InvitationLayout.reservationFontSize,
      minFontSize: InvitationLayout.reservationMinFontSize,
      fill: false,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    if (bytes == null) {
      throw StateError('failed to encode invitation image');
    }

    return Uint8List.fromList(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
  }

  Future<ui.Image> _loadBackground(String asset) async {
    final cached = _cachedBackgrounds[asset];
    if (cached != null) {
      return cached;
    }

    final data = await rootBundle.load(asset);
    final encoded = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final codec = await ui.instantiateImageCodec(
      encoded,
      targetWidth: exportWidth.round(),
      targetHeight: exportHeight.round(),
    );
    final frame = await codec.getNextFrame();
    _cachedBackgrounds[asset] = frame.image;
    return frame.image;
  }

  void _paintOverlay({
    required Canvas canvas,
    required double scale,
    required double left,
    required double top,
    required double width,
    required double height,
    required String text,
    required double fontSize,
    required double minFontSize,
    bool fill = true,
  }) {
    final box = Rect.fromLTWH(
      left * scale,
      top * scale,
      width * scale,
      height * scale,
    );
    if (fill) {
      canvas.drawRect(box, Paint()..color = InvitationLayout.overlayFill);
    }

    final painter = _fittedPainter(
      text: text,
      box: box,
      fontSize: fontSize * exportPixelRatio,
      minFontSize: minFontSize * exportPixelRatio,
    );
    final offset = Offset(
      box.left + (box.width - painter.width) / 2,
      box.top + (box.height - painter.height) / 2,
    );
    painter.paint(canvas, offset);
  }

  TextPainter _fittedPainter({
    required String text,
    required Rect box,
    required double fontSize,
    required double minFontSize,
  }) {
    var size = fontSize;
    late TextPainter painter;
    while (true) {
      painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: InvitationLayout.fontFamily,
            fontWeight: InvitationLayout.fontWeight,
            fontSize: size,
            height: 1.1,
            color: InvitationLayout.textColor,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: box.width);

      if (size <= minFontSize ||
          (!painter.didExceedMaxLines && painter.height <= box.height)) {
        break;
      }
      size -= 1;
    }
    return painter;
  }
}
