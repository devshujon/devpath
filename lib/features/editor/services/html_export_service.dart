import 'dart:convert';

import 'package:share_plus/share_plus.dart';

import '../utils/playground_preview_document.dart';

class HtmlExportResult {
  final String fileName;
  final String htmlDocument;
  final int byteLength;

  const HtmlExportResult({
    required this.fileName,
    required this.htmlDocument,
    required this.byteLength,
  });
}

/// Exports playground buffers as a single HTML file (untrusted user content).
class HtmlExportService {
  HtmlExportService._();

  /// Maximum exported document size (UTF-8 bytes).
  static const int maxExportBytes = 2 * 1024 * 1024;

  static HtmlExportResult buildExport({
    required String title,
    required String html,
    required String css,
    required String js,
  }) {
    final doc = buildPlaygroundPreviewDocument(html: html, css: css, js: js);
    final bytes = utf8.encode(doc);
    if (bytes.length > maxExportBytes) {
      throw HtmlExportTooLargeException(bytes.length);
    }
    final safeName = _safeFileName(title);
    return HtmlExportResult(
      fileName: '$safeName.html',
      htmlDocument: doc,
      byteLength: bytes.length,
    );
  }

  static Future<void> shareExport(HtmlExportResult result) async {
    await Share.share(
      result.htmlDocument,
      subject: result.fileName,
    );
  }

  static String _safeFileName(String title) {
    final trimmed = title.trim().isEmpty ? 'devpath-project' : title.trim();
    final cleaned = trimmed.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '-');
    return cleaned.isEmpty ? 'devpath-project' : cleaned.toLowerCase();
  }
}

class HtmlExportTooLargeException implements Exception {
  final int bytes;
  HtmlExportTooLargeException(this.bytes);
  @override
  String toString() => 'Export too large ($bytes bytes)';
}
