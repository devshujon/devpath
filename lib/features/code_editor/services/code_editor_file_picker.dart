import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/editor_file_type.dart';
import '../utils/file_type_registry.dart';

class CodeEditorPickResult {
  final String fileName;
  final EditorFileKind kind;
  final String content;

  const CodeEditorPickResult({
    required this.fileName,
    required this.kind,
    required this.content,
  });
}

enum CodeEditorPickFailure {
  cancelled,
  permissionDenied,
  unsupportedExtension,
  emptyFile,
  tooLarge,
  unreadable,
}

class CodeEditorFilePicker {
  CodeEditorFilePicker._();

  static Future<(CodeEditorPickResult?, CodeEditorPickFailure?)> pickAndRead() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: EditorFileTypeRegistry.pickerExtensions,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return (null, CodeEditorPickFailure.cancelled);
      }

      final file = result.files.first;
      final name = file.name;
      final kind = EditorFileTypeRegistry.kindForFileName(name);
      if (kind == null) {
        return (null, CodeEditorPickFailure.unsupportedExtension);
      }

      final bytes = file.bytes;
      if (bytes == null) {
        return (null, CodeEditorPickFailure.unreadable);
      }
      if (bytes.isEmpty) {
        return (null, CodeEditorPickFailure.emptyFile);
      }
      if (bytes.length > EditorFileTypeRegistry.maxImportBytes) {
        return (null, CodeEditorPickFailure.tooLarge);
      }

      String text;
      try {
        text = utf8.decode(bytes);
      } catch (_) {
        text = latin1.decode(bytes);
      }

      if (kDebugMode) {
        debugPrint('CodeEditor: imported $name (${bytes.length} bytes)');
      }

      return (
        CodeEditorPickResult(fileName: name, kind: kind, content: text),
        null,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('CodeEditor: picker error: $e');
      final msg = e.toString().toLowerCase();
      if (msg.contains('permission')) {
        return (null, CodeEditorPickFailure.permissionDenied);
      }
      return (null, CodeEditorPickFailure.unreadable);
    }
  }

  static Future<String?> pickSaveAsName(String suggested) async {
    return FilePicker.platform.saveFile(
      dialogTitle: 'Save file as',
      fileName: suggested,
      type: FileType.custom,
      allowedExtensions: EditorFileTypeRegistry.pickerExtensions,
    );
  }
}
