import 'package:flutter/foundation.dart';

import '../../learning/providers/learning_progress_provider.dart';
import '../data/projects_track_catalog.dart';
import '../models/track_project.dart';
import '../services/projects_track_storage.dart';

/// Owns mini-projects state. Locking is computed against
/// LearningProgressProvider.completedLessons. Awards XP through
/// learning.addXP on completion so downstream listeners (RewardsProvider)
/// pick up the change for chained achievement evaluation.
class ProjectsTrackProvider extends ChangeNotifier {
  final LearningProgressProvider _learning;

  ProjectsTrackStorageData _data = ProjectsTrackStorageData.empty;
  bool _loaded = false;

  ProjectsTrackProvider(this._learning) {
    _learning.addListener(_onLearningChanged);
  }

  @override
  void dispose() {
    _learning.removeListener(_onLearningChanged);
    super.dispose();
  }

  void _onLearningChanged() {
    if (!_loaded) return;
    // Locking depends on completed lessons — rebroadcast.
    notifyListeners();
  }

  // ── Lifecycle ──

  Future<void> load() async {
    if (_loaded) return;
    _data = await ProjectsTrackStorage.instance.load();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    await ProjectsTrackStorage.instance.save(_data);
    notifyListeners();
  }

  // ── Read accessors ──

  bool get loaded => _loaded;
  List<TrackProject> get all => ProjectsTrackCatalog.all;
  int get totalCount => ProjectsTrackCatalog.all.length;
  int get completedCount => _data.completedIds.length;
  int get inProgressCount => _data.inProgressIds.length;

  bool isCompleted(String id) => _data.completedIds.contains(id);
  bool isInProgress(String id) => _data.inProgressIds.contains(id);

  /// Locked when any required lesson is not yet completed.
  bool isLocked(TrackProject p) {
    if (p.requiredLessons.isEmpty) return false;
    final done = _learning.completedLessons;
    return !p.requiredLessons.every(done.contains);
  }

  TrackProjectStatus statusOf(TrackProject p) {
    if (_data.completedIds.contains(p.id)) return TrackProjectStatus.completed;
    if (isLocked(p)) return TrackProjectStatus.locked;
    if (_data.inProgressIds.contains(p.id)) {
      return TrackProjectStatus.inProgress;
    }
    return TrackProjectStatus.notStarted;
  }

  int completedInDifficulty(Difficulty d) => ProjectsTrackCatalog.all
      .where((p) => p.difficulty == d && _data.completedIds.contains(p.id))
      .length;

  int totalInDifficulty(Difficulty d) =>
      ProjectsTrackCatalog.byDifficulty(d).length;

  /// Most-recently-opened in-progress project. Drives the dashboard
  /// "Continue project" card. Returns null when nothing's in progress.
  TrackProject? continueCandidate() {
    if (_data.inProgressIds.isEmpty) return null;
    final ids = _data.inProgressIds.toList()
      ..sort((a, b) {
        final ta = _data.openedAt[a];
        final tb = _data.openedAt[b];
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        return tb.compareTo(ta);
      });
    for (final id in ids) {
      final p = ProjectsTrackCatalog.byId(id);
      if (p != null) return p;
    }
    return null;
  }

  List<TrackProject> recentlyCompleted({int limit = 5}) {
    final ids = _data.completedIds.toList()
      ..sort((a, b) {
        final ta = _data.completedAt[a];
        final tb = _data.completedAt[b];
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        return tb.compareTo(ta);
      });
    return ids
        .take(limit)
        .map(ProjectsTrackCatalog.byId)
        .whereType<TrackProject>()
        .toList();
  }

  // ── Mutations ──

  /// Mark as opened — sets in-progress and records timestamp. Idempotent.
  Future<void> markOpened(String id) async {
    if (_data.completedIds.contains(id)) return;
    final now = DateTime.now();
    _data = _data.copyWith(
      inProgressIds: {..._data.inProgressIds, id},
      openedAt: {..._data.openedAt, id: now},
    );
    await _persist();
  }

  /// Mark complete. Awards xpReward through learning.addXP so the
  /// downstream rewards/achievement chain sees the change. Returns
  /// true on a fresh transition.
  Future<bool> markCompleted(String id) async {
    if (_data.completedIds.contains(id)) return false;
    final project = ProjectsTrackCatalog.byId(id);
    if (project == null) return false;
    final now = DateTime.now();
    final updatedInProgress = {..._data.inProgressIds}..remove(id);
    _data = _data.copyWith(
      inProgressIds: updatedInProgress,
      completedIds: {..._data.completedIds, id},
      completedAt: {..._data.completedAt, id: now},
    );
    await _persist();
    if (project.xpReward > 0) {
      await _learning.addXP(project.xpReward);
    }
    return true;
  }

  Future<void> resetAll() async {
    _data = ProjectsTrackStorageData.empty;
    await ProjectsTrackStorage.instance.clear();
    notifyListeners();
  }
}
