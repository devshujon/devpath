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
import '../utils/workspace_preview_assets.dart';

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
  bool _dirtyNotified = false;
  bool _saveInFlight = false;
  int _autoSaveGeneration = 0;

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

  Future<void> refreshIndex({bool notify = true}) async {
    _files = await _storage.loadIndex();
    if (notify) notifyListeners();
  }

  Future<WorkspaceFile?> createNew(EditorFileKind kind) async {
    final name = FileTemplates.defaultFileName(kind);
    final entry = await _storage.createFile(
      fileName: name,
      kind: kind,
      content: FileTemplates.starter(kind),
    );
    await refreshIndex(notify: false);
    await openWorkspaceFile(entry);
    notifyListeners();
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
    await refreshIndex(notify: false);
    await openWorkspaceFile(entry);
    notifyListeners();
    return (entry, null);
  }

  Future<void> openWorkspaceFile(WorkspaceFile file) async {
    _autoSaveTimer?.cancel();
    final body = await _storage.readContent(file.id);
    _openFile = file;
    _content = body ?? '';
    _savedContent = _content;
    _dirtyNotified = false;
    notifyListeners();
  }

  void updateContent(String value) {
    if (_openFile == null) return;
    _content = value;
    _notifyDirtyTransition();
    if (_settings.autoSave) {
      _autoSaveTimer?.cancel();
      final gen = ++_autoSaveGeneration;
      _autoSaveTimer = Timer(const Duration(milliseconds: 800), () {
        if (gen != _autoSaveGeneration) return;
        // ignore: unawaited_futures
        save(silent: true);
      });
    }
  }

  void _notifyDirtyTransition() {
    final dirty = isDirty;
    if (dirty == _dirtyNotified) return;
    _dirtyNotified = dirty;
    notifyListeners();
  }

  /// Apply latest WebView buffer before save, preview, or navigation.
  void applyEditorBuffer(String value) {
    if (_openFile == null) return;
    _content = value;
    _notifyDirtyTransition();
  }

  Future<bool> save({bool silent = false}) async {
    final file = _openFile;
    if (file == null) return false;
    if (_saveInFlight) return false;
    _saveInFlight = true;
    final contentToWrite = _content;
    try {
      final updated = await _storage.updateFile(
        fileId: file.id,
        content: contentToWrite,
      );
      if (updated != null) {
        _openFile = updated;
        final wasDirtyFlag = _dirtyNotified;
        _savedContent = contentToWrite;
        _dirtyNotified = isDirty;
        if (!silent || wasDirtyFlag != _dirtyNotified) {
          notifyListeners();
        }
        await refreshIndex(notify: !silent);
        return true;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('CodeEditor save failed: $e');
    } finally {
      _saveInFlight = false;
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
      await refreshIndex(notify: false);
      await openWorkspaceFile(entry);
      notifyListeners();
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
      await refreshIndex(notify: true);
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
      await refreshIndex(notify: true);
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
    final file = _openFile;
    final assets = await WorkspacePreviewAssets.load(
      storage: _storage,
      liveFileId: file?.id,
      liveContent: file?.kind.supportsHtmlPreview == true ? _content : null,
    );
    return HtmlPreviewBuilder.build(
      htmlSource: _content,
      workspaceFilesByLowerName: assets.byBasename,
      ambiguousBasenames: assets.ambiguousBasenames,
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
