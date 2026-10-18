import 'package:flutter/foundation.dart';

import '../models/user_project.dart';
import '../services/project_storage.dart';

/// Owns the list-of-saved-projects view. Backed by [ProjectStorage].
class ProjectsListProvider extends ChangeNotifier {
  final ProjectStorage _storage = ProjectStorage.instance;

  List<UserProject> _all = const [];
  String _query = '';
  bool _loading = false;
  bool _initialized = false;

  bool get loading => _loading;
  String get query => _query;
  int get totalCount => _all.length;

  /// All projects, sorted by updatedAt desc, filtered by search query.
  List<UserProject> get visible {
    if (_query.trim().isEmpty) return _all;
    final q = _query.toLowerCase().trim();
    return _all.where((p) {
      return p.title.toLowerCase().contains(q) ||
          p.htmlCode.toLowerCase().contains(q) ||
          p.cssCode.toLowerCase().contains(q) ||
          p.jsCode.toLowerCase().contains(q);
    }).toList();
  }

  /// First call performs initial load. Subsequent calls force a reload
  /// (used after coming back from playground saves).
  Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (_initialized && !force) return;
    _loading = true;
    if (_initialized) notifyListeners();
    try {
      _all = await _storage.loadProjects();
      _initialized = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setQuery(String q) {
    if (q == _query) return;
    _query = q;
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    // Optimistic removal — UI reacts immediately
    _all = _all.where((p) => p.id != id).toList();
    notifyListeners();
    try {
      await _storage.deleteProject(id);
    } catch (_) {
      // On failure, reload truth from storage
      await load(force: true);
    }
  }

  /// Merge a freshly saved or updated project into the list.
  /// Called from the playground after save so the user sees their
  /// new project without forcing a full reload.
  void upsert(UserProject project) {
    final existing = _all.indexWhere((p) => p.id == project.id);
    if (existing == -1) {
      _all = [project, ..._all];
    } else {
      _all = [..._all]..[existing] = project;
      _all.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    notifyListeners();
  }
}
