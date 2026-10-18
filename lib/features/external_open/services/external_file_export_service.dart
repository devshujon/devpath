import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../models/external_file_kind.dart';

/// Export opened/edited external files via SAF save or share (never silent overwrite).
class ExternalFileExportService {
  ExternalFileExportService._();

  static const maxExportBytes = 2 * 1024 * 1024;

  static Future<bool> exportViaSaveDialog({
    required String suggestedName,
    required ExternalFileKind kind,
    required String content,
  }) async {
    final ext = kind.defaultExtension;
    final name = suggestedName.contains('.') ? suggestedName : '$suggestedName.$ext';
    final bytes = utf8.encode(content);
    if (bytes.length > maxExportBytes) return false;

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export file',
      fileName: name,
      type: FileType.custom,
      allowedExtensions: [ext],
      bytes: bytes,
    );
    return path != null;
  }

  static Future<void> shareContent({
    required String fileName,
    required String content,
  }) async {
    await Share.share(content, subject: fileName);
  }

  static Future<bool> saveCopy({
    required String fileName,
    required ExternalFileKind kind,
    required String content,
  }) async {
    try {
      return await exportViaSaveDialog(
        suggestedName: fileName,
        kind: kind,
        content: content,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('ExternalFileExportService: $e');
      return false;
    }
  }
}
