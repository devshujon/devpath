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

    String text;
    try {
      text = utf8.decode(bytes);
    } catch (_) {
      // Tolerate files saved in a non-UTF-8 encoding.
      text = latin1.decode(bytes);
    }

    return HtmlImportResult(fileName: file.name, html: text);
  }
}
