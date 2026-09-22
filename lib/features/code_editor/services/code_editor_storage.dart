import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/editor_file_type.dart';
import '../models/workspace_file.dart';
import '../utils/file_type_registry.dart';

/// Offline workspace: file bodies on disk, index in SharedPreferences.
class CodeEditorStorage {
  CodeEditorStorage._();
  static final CodeEditorStorage instance = CodeEditorStorage._();

  static const _indexKey = 'code_editor_workspace_v1';
  static const _uuid = Uuid();

  Future<Directory> _rootDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'code_workspace'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<List<WorkspaceFile>> loadIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_indexKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map>()
          .map((e) => WorkspaceFile.fromJson(e.cast<String, dynamic>()))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveIndex(List<WorkspaceFile> files) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _indexKey,
      jsonEncode(files.map((f) => f.toJson()).toList()),
    );
  }

  Future<String?> readContent(String fileId) async {
    final file = await _bodyFile(fileId);
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  Future<void> writeContent(String fileId, String content) async {
    final file = await _bodyFile(fileId);
    await file.writeAsString(content, flush: true);
  }

  Future<WorkspaceFile> createFile({
    required String fileName,
    required EditorFileKind kind,
    required String content,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final entry = WorkspaceFile(
      id: id,
      fileName: EditorFileTypeRegistry.baseName(fileName),
      kind: kind,
      createdAt: now,
      updatedAt: now,
    );
    await writeContent(id, content);
    final index = await loadIndex();
    await _saveIndex([entry, ...index]);
    return entry;
  }

  Future<WorkspaceFile> importFile({
    required String fileName,
    required EditorFileKind kind,
    required String content,
  }) =>
      createFile(fileName: fileName, kind: kind, content: content);

  Future<WorkspaceFile?> updateFile({
    required String fileId,
    String? fileName,
    String? content,
  }) async {
    final index = await loadIndex();
    final i = index.indexWhere((f) => f.id == fileId);
    if (i < 0) return null;
    if (content != null) await writeContent(fileId, content);
    final kind = fileName != null
        ? EditorFileTypeRegistry.kindForFileName(fileName) ?? index[i].kind
        : index[i].kind;
    final updated = index[i].copyWith(
      fileName: fileName != null
          ? EditorFileTypeRegistry.baseName(fileName)
          : null,
      kind: kind,
      updatedAt: DateTime.now(),
    );
    index[i] = updated;
    await _saveIndex(index);
    return updated;
  }

  Future<bool> deleteFile(String fileId) async {
    final index = await loadIndex();
    final next = index.where((f) => f.id != fileId).toList();
    if (next.length == index.length) return false;
    await _saveIndex(next);
    final file = await _bodyFile(fileId);
    if (await file.exists()) await file.delete();
    return true;
  }

  Future<File> _bodyFile(String fileId) async {
    final dir = await _rootDir();
    return File(p.join(dir.path, '$fileId.txt'));
  }
}
