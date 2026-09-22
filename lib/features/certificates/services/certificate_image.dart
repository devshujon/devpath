import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/certificate.dart';

/// Captures a [RepaintBoundary] containing a rendered certificate
/// and shares it as a PNG via [share_plus].
///
/// Caller wraps the visible certificate widget in a [RepaintBoundary]
/// constructed with a [GlobalKey], then passes that key here.
class CertificateImage {
  CertificateImage._();
  static final CertificateImage instance = CertificateImage._();

  /// Capture + share. Returns the saved file path, or null if capture
  /// failed (boundary not laid out yet, or PNG encode failed).
  Future<String?> shareFromBoundary({
    required GlobalKey boundaryKey,
    required Certificate certificate,
  }) async {
    final file = await captureToFile(
      boundaryKey: boundaryKey,
      filename: 'devpath_${certificate.id}.png',
    );
    if (file == null) return null;

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      text:
          'I earned the ${certificate.title} on DevPath — Learn Code & Earn!',
      subject: certificate.title,
    );
    return file.path;
  }

  /// Render the bounded subtree to a PNG file in the temp directory.
  Future<File?> captureToFile({
    required GlobalKey boundaryKey,
    required String filename,
    double pixelRatio = 3.0,
  }) async {
    final ctx = boundaryKey.currentContext;
    if (ctx == null) return null;
    final boundary = ctx.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;
    // If the layer is still dirty (first frame), defer one tick.
    if (boundary.debugNeedsPaint) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (byteData == null) return null;
    final bytes = byteData.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    return file.writeAsBytes(bytes, flush: true);
  }
}
