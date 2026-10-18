import 'dart:convert';

import 'package:file_picker/file_picker.dart';

/// Result of a successful HTML import.
class HtmlImportResult {
  final String fileName;
  final String html;
  const HtmlImportResult({required this.fileName, required this.html});
}

/// Imports an HTML file from the device, fully offline.
///
/// Uses the platform file picker (Android's Storage Access Framework on
/// Android — no storage permission required for user-picked files) and
/// is restricted to `.html` / `.htm`. The file's bytes are read in
/// memory and decoded as text; nothing is uploaded anywhere.
class HtmlImportService {
  const HtmlImportService._();

  /// Maximum picked file size (bytes).
  static const int maxImportBytes = 1024 * 1024;

  /// Opens the picker and reads the chosen file.
  ///
  /// Returns null if the user cancels or the file can't be read.
  static Future<HtmlImportResult?> pickAndRead() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['html', 'htm'],
      withData: true, // load bytes directly — avoids path/SAF issues
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) return null;
    final text = decodeBytes(bytes);

    return HtmlImportResult(fileName: file.name, html: text);
  }

  /// Decode picked file bytes (UTF-8, else ISO-8859-1). Throws if over size cap.
  static String decodeBytes(List<int> bytes) {
    if (bytes.isEmpty) {
      throw const FormatException('empty file');
    }
    if (bytes.length > maxImportBytes) {
      throw HtmlImportTooLargeException(bytes.length);
    }
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return latin1.decode(bytes);
    }
  }
}

class HtmlImportTooLargeException implements Exception {
  final int bytes;
  HtmlImportTooLargeException(this.bytes);
  @override
  String toString() => 'Import too large ($bytes bytes)';
}
