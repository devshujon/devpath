import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Snapshot of an in-progress playground session, persisted between
/// app launches so a user who's mid-edit doesn't lose work to a kill.
class DraftSnapshot {
  final String html;
  final String css;
  final String js;
  final String? projectId;   // null when the user hasn't saved as a project yet
  final String? lessonId;
  final DateTime savedAt;

  const DraftSnapshot({
    required this.html,
    required this.css,
    required this.js,
    required this.savedAt,
    this.projectId,
    this.lessonId,
  });

  Map<String, dynamic> toJson() => {
        'html': html,
        'css': css,
        'js': js,
        'savedAt': savedAt.toIso8601String(),
        if (projectId != null) 'projectId': projectId,
        if (lessonId != null) 'lessonId': lessonId,
      };

  factory DraftSnapshot.fromJson(Map<String, dynamic> j) => DraftSnapshot(
        html: j['html'] as String? ?? '',
        css: j['css'] as String? ?? '',
        js: j['js'] as String? ?? '',
        projectId: j['projectId'] as String?,
        lessonId: j['lessonId'] as String?,
        savedAt: DateTime.parse(j['savedAt'] as String),
      );
}

/// Periodic background-save for the active playground session.
///
/// Owned per playground screen instance. Call [start] in initState with
/// a snapshot function that reads from the provider. Call [stop] in
/// dispose. [flush] for explicit save (e.g. when user presses Save or
/// navigates away).
class AutosaveService {
  AutosaveService._();
  static final AutosaveService instance = AutosaveService._();

  static const _draftKey = 'playground_draft_v1';
  static const _tickInterval = Duration(seconds: 30);

  Timer? _timer;
  DraftSnapshot Function()? _snapshotFn;
  String? _lastSavedHash;

  bool get isRunning => _timer != null;

  /// Begin the 30-second tick. Each tick reads a snapshot via
  /// [snapshotFn] and saves it only if the content hash changed.
  ///
  /// Calling start a second time replaces the previous snapshot
  /// function but does not double the timer.
  void start(DraftSnapshot Function() snapshotFn) {
    _snapshotFn = snapshotFn;
    _timer ??= Timer.periodic(_tickInterval, (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _snapshotFn = null;
  }

  Future<void> _tick() async {
    final fn = _snapshotFn;
    if (fn == null) return;
    await _writeIfChanged(fn());
  }

  /// Force a save right now. Called on Save, navigation away, etc.
  Future<void> flush() async {
    final fn = _snapshotFn;
    if (fn == null) return;
    await _writeIfChanged(fn());
  }

  Future<void> _writeIfChanged(DraftSnapshot snap) async {
    final hash = '${snap.html.length}:${snap.css.length}:${snap.js.length}:'
        '${snap.projectId ?? ''}:${snap.lessonId ?? ''}:'
        '${snap.html.hashCode}:${snap.css.hashCode}:${snap.js.hashCode}';
    if (hash == _lastSavedHash) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftKey, jsonEncode(snap.toJson()));
    _lastSavedHash = hash;
  }

  /// Restore the most recent saved draft, or null if none exists.
  Future<DraftSnapshot?> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey);
    if (raw == null) return null;
    try {
      return DraftSnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // corrupt draft — wipe so it doesn't poison future restores
      await clear();
      return null;
    }
  }

  /// Drop the saved draft. Call after the user explicitly saves the work
  /// as a project, or after a successful restore-prompt response.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
    _lastSavedHash = null;
  }
}
