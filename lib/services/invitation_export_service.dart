import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/invitation_layout.dart';

class InvitationExportService {
  const InvitationExportService();

  static const double logicalWidth = InvitationLayout.canvasWidth;
  static const double logicalHeight = InvitationLayout.canvasHeight;
  static const double exportWidth = 1080;

  static ui.Image? _cachedBackground;

  static double get exportPixelRatio => exportWidth / logicalWidth;

  static double get exportHeight => exportWidth * logicalHeight / logicalWidth;

  Future<Uint8List> capturePng({
    required String prefix,
    required String name,
  }) async {
    final background = await _loadBackground();
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

    final text = InvitationLayout.guestLine(prefix, name);
    final box = Rect.fromLTWH(
      (InvitationLayout.guestBoxLeft +
              InvitationLayout.contentPaddingHorizontal) *
          scale,
      (InvitationLayout.guestBoxTop + InvitationLayout.contentPaddingVertical) *
          scale,
      (InvitationLayout.guestBoxWidth -
              InvitationLayout.contentPaddingHorizontal * 2) *
          scale,
      (InvitationLayout.guestBoxHeight -
              InvitationLayout.contentPaddingVertical * 2) *
          scale,
    );

    final painter = _guestPainter(text, box);
    final offset = Offset(
      box.left + (box.width - painter.width) / 2,
      box.top + (box.height - painter.height) / 2,
    );
    painter.paint(canvas, offset);

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

  Future<ui.Image> _loadBackground() async {
    final cached = _cachedBackground;
    if (cached != null) {
      return cached;
    }

    final data = await rootBundle.load(InvitationLayout.imageAsset);
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
    _cachedBackground = frame.image;
    return frame.image;
  }

  TextPainter _guestPainter(String text, Rect box) {
    var fontSize = InvitationLayout.fontSize * exportPixelRatio;
    final minSize = InvitationLayout.minFontSize * exportPixelRatio;

    late TextPainter painter;
    while (true) {
      painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: InvitationLayout.fontFamily,
            fontWeight: InvitationLayout.fontWeight,
            fontSize: fontSize,
            height: 1.15,
            color: InvitationLayout.textColor,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        maxLines: 2,
        ellipsis: '…',
      )..layout(maxWidth: box.width);

      if (fontSize <= minSize ||
          (!painter.didExceedMaxLines && painter.height <= box.height)) {
        break;
      }
      fontSize -= 1;
    }
    return painter;
  }
}
