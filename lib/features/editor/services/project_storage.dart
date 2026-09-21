import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_project.dart';

/// Persistence layer for [UserProject].
///
/// Storage shape:
///   `user_project:<id>`      → JSON string of the project
///   `user_project_index`     → JSON array of all project ids
///
/// Why an index key: SharedPreferences has no prefix-scan; we need a
/// list of ids to iterate. Mutations keep the index in sync.
class ProjectStorage {
  ProjectStorage._();
  static final ProjectStorage instance = ProjectStorage._();

  static const _prefix = 'user_project:';
  static const _indexKey = 'user_project_index';

  SharedPreferences? _prefs;
  Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  // ── Index helpers ──
  Future<List<String>> _ids() async {
    final prefs = await _p;
    return prefs.getStringList(_indexKey) ?? const [];
  }

  Future<void> _writeIds(List<String> ids) async {
    final prefs = await _p;
    await prefs.setStringList(_indexKey, ids);
  }

  // ── CRUD ──

  /// Insert if new, overwrite if existing. Index updated atomically (per call).
  Future<void> saveProject(UserProject project) async {
    final prefs = await _p;
    await prefs.setString('$_prefix${project.id}', project.encode());

    final ids = await _ids();
    if (!ids.contains(project.id)) {
      await _writeIds([...ids, project.id]);
    }
  }

  /// Convenience for "patch existing project" — fails if the id doesn't
  /// exist. Returns the saved record (with updatedAt bumped to now).
  Future<UserProject> updateProject(UserProject project) async {
    final existing = await getProject(project.id);
    if (existing == null) {
      throw StateError('Cannot update missing project: ${project.id}');
    }
    final updated = project.copyWith(updatedAt: DateTime.now());
    await saveProject(updated);
    return updated;
  }

  Future<UserProject?> getProject(String id) async {
    final prefs = await _p;
    final raw = prefs.getString('$_prefix$id');
    if (raw == null) return null;
    try {
      return UserProject.decode(raw);
    } catch (_) {
      // Corrupt entry — drop it from the index and return null
      await deleteProject(id);
      return null;
    }
  }

  /// Returns all saved projects, newest-edited first.
  Future<List<UserProject>> loadProjects() async {
    final ids = await _ids();
    final out = <UserProject>[];
    for (final id in ids) {
      final p = await getProject(id);
      if (p != null) out.add(p);
    }
    out.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return out;
  }

  Future<void> deleteProject(String id) async {
    final prefs = await _p;
    await prefs.remove('$_prefix$id');

    final ids = await _ids();
    if (ids.contains(id)) {
      await _writeIds(ids.where((x) => x != id).toList());
    }
  }

  /// Mark a project as just opened — bumps lastOpened without touching
  /// updatedAt or any code fields.
  Future<void> touchOpened(String id) async {
    final existing = await getProject(id);
    if (existing == null) return;
    await saveProject(existing.copyWith(lastOpened: DateTime.now()));
  }
}
