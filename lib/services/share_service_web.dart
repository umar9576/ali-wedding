import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'share_types.dart';

class ShareService {
  bool? _supportsFileShare;

  Future<bool> get supportsFileShare async {
    final cached = _supportsFileShare;
    if (cached != null) {
      return cached;
    }

    try {
      final blob = web.Blob(
        <JSAny>[].toJS,
        web.BlobPropertyBag(type: 'image/png'),
      );
      final file = web.File(
        <JSAny>[blob].toJS,
        'invite.png',
        web.FilePropertyBag(type: 'image/png'),
      );
      final supported = web.window.navigator.canShare(
        web.ShareData(files: <web.File>[file].toJS),
      );
      _supportsFileShare = supported;
      return supported;
    } catch (_) {
      _supportsFileShare = false;
      return false;
    }
  }

  Future<ShareOutcome> sharePng({
    required Uint8List pngBytes,
    required String fileName,
    required String text,
  }) async {
    final blob = web.Blob(
      <JSAny>[Uint8List.fromList(pngBytes).toJS].toJS,
      web.BlobPropertyBag(type: 'image/png'),
    );
    final file = web.File(
      <JSAny>[blob].toJS,
      fileName,
      web.FilePropertyBag(type: 'image/png'),
    );
    final shareData = web.ShareData(files: <web.File>[file].toJS, text: text);

    try {
      if (web.window.navigator.canShare(shareData)) {
        await web.window.navigator.share(shareData).toDart;
        _supportsFileShare = true;
        return ShareOutcome.shared;
      }
    } on web.DOMException catch (error) {
      if (error.name == 'AbortError') {
        return ShareOutcome.cancelled;
      }
    } catch (error) {
      final message = error.toString().toLowerCase();
      if (message.contains('abort')) {
        return ShareOutcome.cancelled;
      }
    }

    _downloadBlob(blob, fileName);
    _openWhatsApp(text);
    return ShareOutcome.fallbackDownloadAndWhatsApp;
  }

  void _downloadBlob(web.Blob blob, String fileName) {
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = fileName;
    anchor.style.display = 'none';
    web.document.body?.appendChild(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
  }

  void _openWhatsApp(String text) {
    final uri = Uri.https('wa.me', '/', {'text': text});
    web.window.open(uri.toString(), '_blank', 'noopener,noreferrer');
  }
}
