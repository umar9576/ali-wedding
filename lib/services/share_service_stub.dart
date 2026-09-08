import 'dart:typed_data';

import 'share_types.dart';

class ShareService {
  Future<bool> get supportsFileShare async => false;

  Future<ShareOutcome> sharePng({
    required Uint8List pngBytes,
    required String fileName,
    required String text,
  }) async {
    return ShareOutcome.unavailable;
  }
}
