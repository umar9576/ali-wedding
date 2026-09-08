import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../widgets/invitation_layout.dart';

class InvitationExportService {
  const InvitationExportService();

  static const double logicalWidth = InvitationLayout.canvasWidth;
  static const double logicalHeight = InvitationLayout.canvasHeight;
  static const double exportWidth = 1080;

  static double get exportPixelRatio => exportWidth / logicalWidth;

  Future<Uint8List> capturePng(GlobalKey boundaryKey) async {
    await WidgetsBinding.instance.endOfFrame;
    return _captureMounted(boundaryKey);
  }

  Future<Uint8List> _captureMounted(GlobalKey boundaryKey) async {
    final context = boundaryKey.currentContext;
    if (context == null) {
      throw StateError('invitation boundary is not mounted');
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw StateError('invitation boundary is missing');
    }

    final image = await renderObject.toImage(pixelRatio: exportPixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      throw StateError('failed to encode invitation image');
    }
    return bytes.buffer.asUint8List();
  }
}
