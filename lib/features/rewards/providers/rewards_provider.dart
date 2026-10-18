import 'package:flutter/foundation.dart';

import '../../certificates/providers/certificates_provider.dart';
import '../../challenges/providers/challenges_provider.dart';
import '../../editor/providers/projects_list_provider.dart';
import '../../learning/providers/learning_progress_provider.dart';
import '../../projects_track/providers/projects_track_provider.dart';
import '../data/achievements_catalog.dart';
import '../models/achievement.dart';
import '../services/achievement_engine.dart';
import '../services/rewards_storage.dart';

/// Owns achievement state and runs the engine reactively. Listens to
/// the three "source" providers (learning, challenges, projects); any
/// notification kicks off an evaluation.
///
/// The evaluator is re-entrant: awarding XP triggers a learning notify,
/// which would re-enter the evaluator — but a flag short-circuits the
/// re-entry. Inside the same call, an inner while-loop catches chain
/// reactions where one unlock's XP reward crosses another unlock's
/// XP-threshold (an XP-total achievement).
class RewardsProvider extends ChangeNotifier {
  static const _engine = AchievementEngine();
  static const int _maxEvaluationIterations = 16;

  final LearningProgressProvider _learning;
  final ChallengesProvider _challenges;
  final ProjectsListProvider _projects;
  final ProjectsTrackProvider _projectsTrack;
  final CertificatesProvider _certificates;

  RewardsStorageData _data = RewardsStorageData.empty;
  bool _loaded = false;
  bool _evaluating = false;
  bool _wiredListeners = false;

  /// Achievements unlocked during this app session that have not yet
  /// been shown via the celebration overlay. Drained one-at-a-time by
  /// [consumeNextCelebration] as the dashboard renders overlays.
  final List<Achievement> _celebrationQueue = [];

  RewardsProvider({
    required LearningProgressProvider learning,
    required ChallengesProvider challenges,
    required ProjectsListProvider projects,
    required ProjectsTrackProvider projectsTrack,
    required CertificatesProvider certificates,
  })  : _learning = learning,
        _challenges = challenges,
        _projects = projects,
        _projectsTrack = projectsTrack,
        _certificates = certificates;

  // ── Lifecycle ──

  Future<void> load() async {
    if (_loaded) return;
    _data = await RewardsStorage.instance.load();
    _loaded = true;

    // Wire listeners only AFTER first load so we don't evaluate on
    // half-initialized state.
    if (!_wiredListeners) {
      _learning.addListener(_onChange);
      _challenges.addListener(_onChange);
      _projects.addListener(_onChange);
      _projectsTrack.addListener(_onChange);
      _certificates.addListener(_onChange);
      _wiredListeners = true;
    }

    // Seed celebration queue with anything unlocked-but-unacknowledged
    // from prior sessions.
    for (final id in _data.unlockedIds) {
      if (_data.acknowledgedIds.contains(id)) continue;
      final ach = AchievementsCatalog.byId(id);
      if (ach != null) _celebrationQueue.add(ach);
    }

    // Run an initial evaluation in case state advanced offline (e.g.
    // user installed a new build that added an achievement they
    // already satisfy).
    await _evaluate();

    notifyListeners();
  }

  @override
  void dispose() {
    if (_wiredListeners) {
      _learning.removeListener(_onChange);
      _challenges.removeListener(_onChange);
      _projects.removeListener(_onChange);
      _projectsTrack.removeListener(_onChange);
      _certificates.removeListener(_onChange);
    }
    super.dispose();
  }

  void _onChange() {
    if (!_loaded) return;
    // Fire and forget — the provider keeps notifying internally as
    // results land.
    _evaluate();
  }

  Future<void> _persist() async {
    await RewardsStorage.instance.save(_data);
  }

  // ── Read accessors ──

  bool get loaded => _loaded;

  /// All catalog entries, decorated with isUnlocked + unlockedAt.
  List<Achievement> get all => AchievementsCatalog.all
      .map((a) => a.copyWith(
            isUnlocked: _data.unlockedIds.contains(a.id),
            unlockedAt: _data.unlockedAt[a.id],
          ))
      .toList();

  int get totalAchievements => AchievementsCatalog.all.length;
  int get unlockedCount => _data.unlockedIds.length;

  /// Achievements that are unlocked but the user hasn't yet seen the
  /// celebration overlay for. Persists across app restarts.
  List<Achievement> get pendingRewards {
    final out = <Achievement>[];
    for (final id in _data.unlockedIds) {
      if (_data.acknowledgedIds.contains(id)) continue;
      final ach = AchievementsCatalog.byId(id);
      if (ach == null) continue;
      out.add(ach.copyWith(
        isUnlocked: true,
        unlockedAt: _data.unlockedAt[id],
      ));
    }
    return out;
  }

  /// Recently-unlocked achievements, most recent first. Limited to
  /// [limit] entries. Driven by [unlockedAt] timestamps.
  List<Achievement> recentUnlocks({int limit = 5}) {
    final entries = _data.unlockedIds.toList()
      ..sort((a, b) {
        final ta = _data.unlockedAt[a];
        final tb = _data.unlockedAt[b];
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        return tb.compareTo(ta);
      });
    return entries
        .take(limit)
        .map(AchievementsCatalog.byId)
        .whereType<Achievement>()
        .map((a) => a.copyWith(
              isUnlocked: true,
              unlockedAt: _data.unlockedAt[a.id],
            ))
        .toList();
  }

  /// Current context derived from source providers — used by the engine
  /// and exposed for progress widgets that want raw counters.
  AchievementContext snapshotContext() => AchievementContext(
        lessonsCompleted: _learning.completedLessons.length,
        challengesCompleted: _challenges.completedCount,
        projectsCreated: _projects.totalCount,
        streakDays: _learning.streakDays,
        xpTotal: _learning.currentXP,
        dailyChallengesCompleted: _challenges.dailyDates.length,
        miniProjectsCompleted: _projectsTrack.completedCount,
        certificatesEarned: _certificates.earnedCount,
      );

  // ── Engine pass-throughs ──

  Map<String, double> evaluateProgress() =>
      _engine.evaluateProgress(snapshotContext());

  /// Force an evaluation pass (no-op outside debug — the provider
  /// already auto-evaluates on every dependency change).
  Future<void> refresh() => _evaluate();

  // ── Celebration queue ──

  bool get hasPendingCelebrations => _celebrationQueue.isNotEmpty;

  /// Pop the next celebration target. Marks it acknowledged + persists.
  /// Caller (typically the dashboard) feeds the returned achievement
  /// into [AchievementUnlockOverlay.show].
  Achievement? consumeNextCelebration() {
    if (_celebrationQueue.isEmpty) return null;
    final next = _celebrationQueue.removeAt(0);
    _data = _data.copyWith(
      acknowledgedIds: {..._data.acknowledgedIds, next.id},
    );
    _persist();
    notifyListeners();
    return next;
  }

  /// Mark all pending achievements as acknowledged without showing them.
  /// Used as a "dismiss all" affordance.
  Future<void> acknowledgeAll() async {
    if (_data.unlockedIds.every(_data.acknowledgedIds.contains)) return;
    _data = _data.copyWith(
      acknowledgedIds: {..._data.unlockedIds},
    );
    _celebrationQueue.clear();
    await _persist();
    notifyListeners();
  }

  // ── Evaluation ──

  Future<void> _evaluate() async {
    if (_evaluating) return;
    _evaluating = true;
    final newlyThisCall = <Achievement>[];
    try {
      var iter = 0;
      while (iter < _maxEvaluationIterations) {
        iter++;
        final ctx = snapshotContext();
        final newly = _engine.checkUnlocks(ctx, _data.unlockedIds);
        if (newly.isEmpty) break;

        final now = DateTime.now();
        final updatedUnlocked = {..._data.unlockedIds};
        final updatedTimes = {..._data.unlockedAt};
        for (final ach in newly) {
          updatedUnlocked.add(ach.id);
          updatedTimes[ach.id] = now;
          newlyThisCall.add(ach);
          _celebrationQueue.add(ach);
        }
        _data = _data.copyWith(
          unlockedIds: updatedUnlocked,
          unlockedAt: updatedTimes,
        );

        // Award XP — bundled into one addXP call per iteration. This
        // re-enters via the learning listener but is short-circuited
        // by the _evaluating flag. After the await, the next loop
        // iteration re-snapshots and catches xp_total threshold
        // crossings caused by the very rewards we just awarded.
        final totalXp = _engine.awardRewards(newly);
        if (totalXp > 0) {
          await _learning.addXP(totalXp);
        }
      }
    } finally {
      _evaluating = false;
    }

    if (newlyThisCall.isNotEmpty) {
      await _persist();
      notifyListeners();
    }
  }

  // ── Dev/test ──

  Future<void> resetAll() async {
    _data = RewardsStorageData.empty;
    _celebrationQueue.clear();
    await RewardsStorage.instance.clear();
    notifyListeners();
  }
}
