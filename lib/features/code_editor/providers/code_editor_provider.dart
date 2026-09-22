import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../models/code_editor_settings.dart';
import '../models/editor_file_type.dart';
import '../models/workspace_file.dart';
import '../services/code_editor_file_picker.dart';
import '../services/code_editor_settings_storage.dart';
import '../services/code_editor_storage.dart';
import '../utils/file_templates.dart';
import '../utils/file_type_registry.dart';
import '../utils/html_preview_builder.dart';

class CodeEditorProvider extends ChangeNotifier {
  final CodeEditorStorage _storage = CodeEditorStorage.instance;
  final CodeEditorSettingsStorage _settingsStorage =
      CodeEditorSettingsStorage.instance;

  List<WorkspaceFile> _files = [];
  CodeEditorSettings _settings = const CodeEditorSettings();
  bool _loaded = false;
  String? _loadError;

  WorkspaceFile? _openFile;
  String _content = '';
  String _savedContent = '';
  Timer? _autoSaveTimer;
  int _previewVersion = 0;

  List<WorkspaceFile> get files => List.unmodifiable(_files);
  CodeEditorSettings get settings => _settings;
  bool get isLoaded => _loaded;
  String? get loadError => _loadError;

  WorkspaceFile? get openFile => _openFile;
  String get content => _content;
  bool get hasOpenFile => _openFile != null;
  bool get isDirty => _openFile != null && _content != _savedContent;
  int get previewVersion => _previewVersion;

  Future<void> load() async {
    try {
      final results = await Future.wait([
        _storage.loadIndex(),
        _settingsStorage.load(),
      ]);
      _files = results[0] as List<WorkspaceFile>;
      _settings = results[1] as CodeEditorSettings;
      _loadError = null;
    } catch (e) {
      _loadError = 'Could not load workspace: $e';
      if (kDebugMode) debugPrint('CodeEditorProvider.load: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> refreshIndex() async {
    _files = await _storage.loadIndex();
    notifyListeners();
  }

  Future<WorkspaceFile?> createNew(EditorFileKind kind) async {
    final name = FileTemplates.defaultFileName(kind);
    final entry = await _storage.createFile(
      fileName: name,
      kind: kind,
      content: FileTemplates.starter(kind),
    );
    await refreshIndex();
    await openWorkspaceFile(entry);
    return entry;
  }

  Future<(WorkspaceFile?, String?)> importFromPicker() async {
    final (result, failure) = await CodeEditorFilePicker.pickAndRead();
    if (failure != null) {
      return (null, _pickFailureMessage(failure));
    }
    final pick = result!;
    final entry = await _storage.importFile(
      fileName: pick.fileName,
      kind: pick.kind,
      content: pick.content,
    );
    await refreshIndex();
    await openWorkspaceFile(entry);
    return (entry, null);
  }

  Future<void> openWorkspaceFile(WorkspaceFile file) async {
    final body = await _storage.readContent(file.id);
    _openFile = file;
    _content = body ?? '';
    _savedContent = _content;
    notifyListeners();
  }

  void updateContent(String value) {
    if (_openFile == null) return;
    _content = value;
    notifyListeners();
    if (_settings.autoSave) {
      _autoSaveTimer?.cancel();
      _autoSaveTimer = Timer(const Duration(milliseconds: 800), () {
        // ignore: unawaited_futures
        save(silent: true);
      });
    }
  }

  Future<bool> save({bool silent = false}) async {
    final file = _openFile;
    if (file == null) return false;
    try {
      final updated = await _storage.updateFile(
        fileId: file.id,
        content: _content,
      );
      if (updated != null) {
        _openFile = updated;
        _savedContent = _content;
        await refreshIndex();
        if (!silent) notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('CodeEditor save failed: $e');
    }
    return false;
  }

  Future<(WorkspaceFile?, String?)> saveAs() async {
    final file = _openFile;
    if (file == null) return (null, 'No file open');
    final suggested = file.displayName;
    final picked = await CodeEditorFilePicker.pickSaveAsName(suggested);
    if (picked == null) return (null, null);
    final name = EditorFileTypeRegistry.baseName(picked);
    final kind = EditorFileTypeRegistry.kindForFileName(name);
    if (kind == null) {
      return (null, 'Unsupported file type');
    }
    try {
      final entry = await _storage.createFile(
        fileName: name,
        kind: kind,
        content: _content,
      );
      await refreshIndex();
      await openWorkspaceFile(entry);
      return (entry, null);
    } catch (e) {
      return (null, 'Save failed: $e');
    }
  }

  Future<String?> renameOpenFile(String newName) async {
    final file = _openFile;
    if (file == null) return 'No file open';
    final base = EditorFileTypeRegistry.baseName(newName.trim());
    if (base.isEmpty) return 'Enter a file name';
    final kind = EditorFileTypeRegistry.kindForFileName(base);
    if (kind == null) return 'Unsupported file extension';
    try {
      final updated = await _storage.updateFile(
        fileId: file.id,
        fileName: base,
      );
      if (updated == null) return 'File not found';
      _openFile = updated;
      await refreshIndex();
      notifyListeners();
      return null;
    } catch (e) {
      return 'Rename failed: $e';
    }
  }

  Future<String?> deleteFile(String fileId) async {
    try {
      final ok = await _storage.deleteFile(fileId);
      if (!ok) return 'File not found';
      if (_openFile?.id == fileId) {
        _openFile = null;
        _content = '';
        _savedContent = '';
      }
      await refreshIndex();
      notifyListeners();
      return null;
    } catch (e) {
      return 'Delete failed: $e';
    }
  }

  Future<String?> shareOpenFile() async {
    final file = _openFile;
    if (file == null) return 'No file open';
    try {
      await Share.share(_content, subject: file.displayName);
      return null;
    } catch (e) {
      return 'Share failed: $e';
    }
  }

  Future<String> buildPreviewHtml() async {
    final map = await _storage.allBodiesByBaseName();
    // Ensure unsaved buffer is reflected for the active HTML file.
    final file = _openFile;
    if (file != null) {
      map[file.displayName.toLowerCase()] = _content;
    }
    return HtmlPreviewBuilder.build(
      htmlSource: _content,
      workspaceFilesByLowerName: map,
    );
  }

  void bumpPreview() {
    _previewVersion++;
    notifyListeners();
  }

  Future<void> updateSettings(CodeEditorSettings next) async {
    _settings = next;
    await _settingsStorage.save(next);
    notifyListeners();
  }

  void closeDocument() {
    _autoSaveTimer?.cancel();
    _openFile = null;
    _content = '';
    _savedContent = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  static String _pickFailureMessage(CodeEditorPickFailure f) => switch (f) {
        CodeEditorPickFailure.cancelled => '',
        CodeEditorPickFailure.permissionDenied =>
          'Storage permission denied. Enable file access in Settings.',
        CodeEditorPickFailure.unsupportedExtension =>
          'Unsupported file type. Choose HTML, CSS, JS, JSON, XML, PHP, TXT, or MD.',
        CodeEditorPickFailure.emptyFile => 'That file is empty.',
        CodeEditorPickFailure.tooLarge =>
          'File is too large (max ${EditorFileTypeRegistry.maxImportBytes ~/ (1024 * 1024)} MB).',
        CodeEditorPickFailure.unreadable =>
          'Could not read that file. Try another copy.',
      };
}
