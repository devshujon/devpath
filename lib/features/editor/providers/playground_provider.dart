import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../models/user_project.dart';
import '../services/autosave_service.dart';
import '../services/lesson_templates.dart';
import '../services/project_storage.dart';

enum PlaygroundTab { html, css, js }

extension PlaygroundTabLabel on PlaygroundTab {
  String get label => switch (this) {
        PlaygroundTab.html => 'HTML',
        PlaygroundTab.css => 'CSS',
        PlaygroundTab.js => 'JS',
      };

  String get filename => switch (this) {
        PlaygroundTab.html => 'index.html',
        PlaygroundTab.css => 'style.css',
        PlaygroundTab.js => 'script.js',
      };
}

/// Owns playground state: three editor buffers, the currently selected
/// tab, and the persistent identity of the project (if any) being edited.
///
/// Architectural rules:
///   - Draft updates do NOT call notifyListeners. The editor field owns
///     its own TextEditingController; rebuilding it on each keystroke
///     is wasted work.
///   - Tab change, Run, Reset, Save, and Load DO notify.
///   - `isDirty` flips true on any draft update, false on Save / Load /
///     Reset. The toolbar's "Save" button reads this to know whether
///     anything needs persisting.
class PlaygroundProvider extends ChangeNotifier {
  static const String defaultHtml = '''<!DOCTYPE html>
<html>
<body>
<h1>Hello Dev</h1>
<button onclick="showMessage()">Click Me</button>
<div id="output"></div>
</body>
</html>''';

  static const String defaultCss = '''body{
 padding:20px;
 font-family:Arial;
}

h1{
 color:blue;
}

button{
 padding:10px;
 border-radius:8px;
}''';

  static const String defaultJs = '''function showMessage(){
 document.getElementById("output").innerHTML =
 "Welcome to DevPath";
}''';

  // Drafts — silent mutations
  String _htmlDraft = defaultHtml;
  String _cssDraft = defaultCss;
  String _jsDraft = defaultJs;

  // Committed — last Run snapshot, what preview renders
  String _htmlCommitted = defaultHtml;
  String _cssCommitted = defaultCss;
  String _jsCommitted = defaultJs;

  PlaygroundTab _selectedTab = PlaygroundTab.html;
  int _runVersion = 0;

  // Persistent identity
  String? _projectId;    // null until first Save
  String? _projectTitle; // mirrors stored title
  String? _lessonId;     // set when opened from a lesson template
  DateTime? _savedAt;    // last persisted updatedAt

  // Dirty tracking — flips on any draft change, off on Save/Load/Reset
  bool _isDirty = false;

  // ── Getters ──
  String get htmlDraft => _htmlDraft;
  String get cssDraft => _cssDraft;
  String get jsDraft => _jsDraft;
  String get htmlCommitted => _htmlCommitted;
  String get cssCommitted => _cssCommitted;
  String get jsCommitted => _jsCommitted;
  PlaygroundTab get selectedTab => _selectedTab;
  int get runVersion => _runVersion;
  String? get projectId => _projectId;
  String? get projectTitle => _projectTitle;
  String? get lessonId => _lessonId;
  DateTime? get savedAt => _savedAt;
  bool get isDirty => _isDirty;
  bool get isExistingProject => _projectId != null;

  String get currentDraft => switch (_selectedTab) {
        PlaygroundTab.html => _htmlDraft,
        PlaygroundTab.css => _cssDraft,
        PlaygroundTab.js => _jsDraft,
      };

  bool get hasUnsavedChanges =>
      _htmlDraft != _htmlCommitted ||
      _cssDraft != _cssCommitted ||
      _jsDraft != _jsCommitted;

  bool get isDefault =>
      _htmlDraft == defaultHtml &&
      _cssDraft == defaultCss &&
      _jsDraft == defaultJs;

  // ── Draft updates ──
  void updateCurrent(String code) {
    switch (_selectedTab) {
      case PlaygroundTab.html:
        if (_htmlDraft == code) return;
        _htmlDraft = code;
      case PlaygroundTab.css:
        if (_cssDraft == code) return;
        _cssDraft = code;
      case PlaygroundTab.js:
        if (_jsDraft == code) return;
        _jsDraft = code;
    }
    _isDirty = true;
  }

  void switchTab(PlaygroundTab tab) {
    if (tab == _selectedTab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  // ── Run / Reset ──
  void run() {
    _htmlCommitted = _htmlDraft;
    _cssCommitted = _cssDraft;
    _jsCommitted = _jsDraft;
    _runVersion++;
    notifyListeners();
  }

  void reset() {
    _htmlDraft = defaultHtml;
    _cssDraft = defaultCss;
    _jsDraft = defaultJs;
    _htmlCommitted = defaultHtml;
    _cssCommitted = defaultCss;
    _jsCommitted = defaultJs;
    _projectId = null;
    _projectTitle = null;
    _lessonId = null;
    _savedAt = null;
    _isDirty = false;
    _runVersion++;
    notifyListeners();
  }

  Future<String> copyCurrentTab() async {
    await Clipboard.setData(ClipboardData(text: currentDraft));
    return _selectedTab.label;
  }

  // ── Lesson loading ──
  void loadLesson(LessonTemplate template) {
    _htmlDraft = template.html;
    _cssDraft = template.css;
    _jsDraft = template.js;
    _htmlCommitted = template.html;
    _cssCommitted = template.css;
    _jsCommitted = template.js;
    _lessonId = template.id;
    _projectId = null;
    _projectTitle = null;
    _savedAt = null;
    _isDirty = false;
    _runVersion++;
    notifyListeners();
  }

  /// Load raw starter buffers from an external source (e.g. the learning
  /// catalog). Pass [lessonId] when this load was initiated by opening
  /// a specific learning lesson — it's stored so any subsequent Save
  /// associates the project with that lesson.
  void loadStarterCode(
    Map<String, String> starter, {
    String? lessonId,
  }) {
    _htmlDraft = starter['html'] ?? defaultHtml;
    _cssDraft = starter['css'] ?? '';
    _jsDraft = starter['js'] ?? '';
    _htmlCommitted = _htmlDraft;
    _cssCommitted = _cssDraft;
    _jsCommitted = _jsDraft;
    _lessonId = lessonId;
    _projectId = null;
    _projectTitle = null;
    _savedAt = null;
    _isDirty = false;
    _runVersion++;
    notifyListeners();
  }

  // ── Project loading ──
  void loadProject(UserProject project) {
    _htmlDraft = project.htmlCode;
    _cssDraft = project.cssCode;
    _jsDraft = project.jsCode;
    _htmlCommitted = project.htmlCode;
    _cssCommitted = project.cssCode;
    _jsCommitted = project.jsCode;
    _projectId = project.id;
    _projectTitle = project.title;
    _lessonId = project.lessonId;
    _savedAt = project.updatedAt;
    _isDirty = false;
    _runVersion++;
    notifyListeners();
  }

  // ── Persistence ──

  /// First save — caller must collect a title from the user.
  /// Creates a new UserProject and returns it.
  Future<UserProject> saveAsNew({required String title}) async {
    final now = DateTime.now();
    final project = UserProject(
      id: const Uuid().v4(),
      title: title.trim().isEmpty ? 'Untitled' : title.trim(),
      htmlCode: _htmlDraft,
      cssCode: _cssDraft,
      jsCode: _jsDraft,
      createdAt: now,
      updatedAt: now,
      lastOpened: now,
      lessonId: _lessonId,
    );
    await ProjectStorage.instance.saveProject(project);

    _projectId = project.id;
    _projectTitle = project.title;
    _savedAt = project.updatedAt;
    _isDirty = false;
    // No notifyListeners needed for draft fields; but the toolbar
    // watches isDirty + projectTitle so we do notify.
    notifyListeners();

    await AutosaveService.instance.clear();
    return project;
  }

  /// Save updates to the already-persisted project. No-op if there is
  /// no project id (caller should detect via [isExistingProject] and
  /// route to saveAsNew).
  Future<UserProject?> saveUpdate() async {
    final id = _projectId;
    if (id == null) return null;

    final existing = await ProjectStorage.instance.getProject(id);
    if (existing == null) {
      // Project was deleted underneath us — treat as new
      return null;
    }

    final updated = existing.copyWith(
      htmlCode: _htmlDraft,
      cssCode: _cssDraft,
      jsCode: _jsDraft,
      updatedAt: DateTime.now(),
      lessonId: _lessonId,
    );
    await ProjectStorage.instance.saveProject(updated);

    _savedAt = updated.updatedAt;
    _isDirty = false;
    notifyListeners();

    await AutosaveService.instance.clear();
    return updated;
  }

  /// Snapshot for the autosave service. Kept here so the autosave logic
  /// reads from a single source of truth.
  DraftSnapshot snapshot() => DraftSnapshot(
        html: _htmlDraft,
        css: _cssDraft,
        js: _jsDraft,
        projectId: _projectId,
        lessonId: _lessonId,
        savedAt: DateTime.now(),
      );

  /// Restore from an autosave draft. Called once when the playground
  /// opens and the user has accepted the restore prompt.
  void restoreFromDraft(DraftSnapshot draft) {
    _htmlDraft = draft.html;
    _cssDraft = draft.css;
    _jsDraft = draft.js;
    _htmlCommitted = draft.html;
    _cssCommitted = draft.css;
    _jsCommitted = draft.js;
    _projectId = draft.projectId;
    _lessonId = draft.lessonId;
    _isDirty = true;
    _runVersion++;
    notifyListeners();
  }
}
