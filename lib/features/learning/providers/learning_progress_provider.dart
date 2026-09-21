import 'package:flutter/foundation.dart';

import '../data/lessons_catalog.dart';
import '../logic/lesson_progression.dart';
import '../models/badge.dart';
import '../models/learner_level.dart';
import '../models/lesson.dart';
import '../services/learning_storage.dart';

/// Result returned from [completeLesson]. The UI inspects this to decide
/// whether to show celebration overlays and which badges to surface.
class CompletionResult {
  final int xpEarned;
  final bool levelUp;
  final LearnerLevelInfo newLevel;
  final List<LearnerBadge> newlyEarnedBadges;
  final Lesson? nextLesson;

  const CompletionResult({
    required this.xpEarned,
    required this.levelUp,
    required this.newLevel,
    required this.newlyEarnedBadges,
    required this.nextLesson,
  });
}

/// Single source of truth for learner state. Backed by [LearningStorage].
class LearningProgressProvider extends ChangeNotifier {
  LearningProgressData _data = LearningProgressData.empty;
  bool _loaded = false;
  bool _saving = false;

  LearningProgressProvider();

  /// Test-only constructor. Does not touch SharedPreferences.
  @visibleForTesting
  LearningProgressProvider.test(LearningProgressData data)
      : _data = data,
        _loaded = true;

  bool get loaded => _loaded;

  // ── Read accessors ──
  Set<String> get completedLessons => _data.completedLessons;
  int get currentXP => _data.currentXP;
  int get streakDays => _data.streakDays;
  int get longestStreak => _data.longestStreak;
  int get totalMinutesLearned => _data.totalMinutesLearned;
  Set<String> get earnedBadges => _data.earnedBadges;
  DateTime? get lastActiveDate => _data.lastActiveDate;

  LearnerLevelInfo get currentLevel => learnerLevelFor(currentXP);
  LearnerLevelInfo? get nextLevel => nextLearnerLevelFor(currentXP);

  /// Progress toward the next level as a 0..1 ratio. Returns 1.0 if at max.
  double get progressToNextLevel {
    final next = nextLevel;
    if (next == null) return 1.0;
    final cur = currentLevel.xpThreshold;
    final span = next.xpThreshold - cur;
    if (span <= 0) return 1.0;
    return ((currentXP - cur) / span).clamp(0.0, 1.0);
  }

  /// XP needed to reach the next level. Null if at max.
  int? get xpToNextLevel {
    final next = nextLevel;
    if (next == null) return null;
    return next.xpThreshold - currentXP;
  }

  // ── Lifecycle ──
  Future<void> load() async {
    if (_loaded) return;
    _data = await LearningStorage.instance.load();
    _loaded = true;
    // Reconcile streak on load: if the user opened the app today but
    // didn't complete a lesson, we leave the streak alone. If they
    // missed yesterday entirely, the next completeLesson() resets it.
    notifyListeners();
  }

  Future<void> _persist({bool notify = true}) async {
    if (_saving) return;
    _saving = true;
    try {
      await LearningStorage.instance.save(_data);
    } finally {
      _saving = false;
    }
    if (notify) notifyListeners();
  }

  // ── Lesson decoration ──

  /// Returns the lesson with [isLocked]/[isCompleted] populated from
  /// current progress. Use this everywhere the UI displays lessons.
  Lesson lessonWithProgress(Lesson lesson) {
    return lesson.copyWith(
      isLocked: _isLocked(lesson),
      isCompleted: completedLessons.contains(lesson.id),
    );
  }

  List<Lesson> allLessonsDecorated() =>
      LessonsCatalog.all.map(lessonWithProgress).toList();

  /// Lessons of a given difficulty, decorated.
  List<Lesson> lessonsByDifficulty(Difficulty d) =>
      LessonsCatalog.byDifficulty(d).map(lessonWithProgress).toList();

  // ── Locking ──

  /// Lock rules (see [computeLessonLocked]):
  ///   - Completed lessons are NEVER locked (catalog inserts cannot
  ///     hide already-earned progress).
  ///   - Beginner: first lesson always unlocked; later lessons unlock
  ///     when the previous lesson in the catalog is completed.
  ///   - Intermediate: locked until ≥50% of beginner is complete.
  ///   - Advanced: locked until ≥50% of intermediate is complete.
  ///   - Within a difficulty, lessons unlock sequentially in catalog order.
  bool _isLocked(Lesson lesson) {
    return computeLessonLocked(
      lessonId: lesson.id,
      difficulty: lesson.difficulty,
      sameDifficultyIds:
          LessonsCatalog.byDifficulty(lesson.difficulty).map((l) => l.id).toList(),
      completedIds: completedLessons,
      beginnerProgress: _difficultyProgress(Difficulty.beginner),
      intermediateProgress: _difficultyProgress(Difficulty.intermediate),
    );
  }

  double _difficultyProgress(Difficulty d) {
    return difficultyCompletionRatio(
      ids: LessonsCatalog.byDifficulty(d).map((l) => l.id).toList(),
      completedIds: completedLessons,
    );
  }

  double overallProgress() {
    final total = LessonsCatalog.all.length;
    if (total == 0) return 0;
    return completedLessons.length / total;
  }

  /// First lesson in catalog order that is unlocked AND not yet completed.
  Lesson? get recommendedNextLesson {
    for (final l in LessonsCatalog.all) {
      final decorated = lessonWithProgress(l);
      if (!decorated.isLocked && !decorated.isCompleted) return decorated;
    }
    return null; // user finished everything
  }

  // ── Streak ──

  /// Update streak for a learner-active event (lesson complete).
  /// Idempotent within a single day.
  void _bumpStreakOnce() {
    final today = _today();
    final last = _data.lastActiveDate == null
        ? null
        : _dateOnly(_data.lastActiveDate!);

    int newStreak;
    if (last == null) {
      newStreak = 1;
    } else if (_sameDay(last, today)) {
      // already counted today
      return;
    } else if (_sameDay(last, today.subtract(const Duration(days: 1)))) {
      newStreak = _data.streakDays + 1;
    } else {
      // gap — reset
      newStreak = 1;
    }

    _data = _data.copyWith(
      streakDays: newStreak,
      longestStreak: newStreak > _data.longestStreak
          ? newStreak
          : _data.longestStreak,
      lastActiveDate: today,
    );
  }

  /// External hook for marking the user "active today" without completing
  /// a lesson. Useful if you want to count app opens. Currently unused.
  Future<void> updateStreak() async {
    _bumpStreakOnce();
    await _persist();
  }

  // ── XP ──

  /// Add XP to the current total. Returns whether the user crossed a level.
  bool _addXpInternal(int amount) {
    if (amount <= 0) return false;
    final before = currentLevel.level;
    _data = _data.copyWith(currentXP: _data.currentXP + amount);
    final after = currentLevel.level;
    return after.index > before.index;
  }

  /// External hook to award XP outside of a lesson (e.g. side challenges).
  Future<void> addXP(int amount) async {
    _addXpInternal(amount);
    await _persist();
  }

  // ── Lesson completion ──

  /// Mark [lessonId] as completed. Idempotent — second call is a no-op.
  /// Returns a [CompletionResult] describing what happened so the UI
  /// can celebrate appropriately.
  Future<CompletionResult> completeLesson(String lessonId) async {
    final lesson = LessonsCatalog.byId(lessonId);
    if (lesson == null) {
      throw ArgumentError('No lesson with id: $lessonId');
    }

    // Already done? Return a no-op result so the UI handles gracefully.
    if (completedLessons.contains(lessonId)) {
      return CompletionResult(
        xpEarned: 0,
        levelUp: false,
        newLevel: currentLevel,
        newlyEarnedBadges: const [],
        nextLesson: recommendedNextLesson,
      );
    }

    // 1. Mark complete
    final updatedCompleted = {..._data.completedLessons, lessonId};
    _data = _data.copyWith(
      completedLessons: updatedCompleted,
      totalMinutesLearned:
          _data.totalMinutesLearned + lesson.estimatedMinutes,
    );

    // 2. Award XP + check level up
    final leveled = _addXpInternal(lesson.xpReward);

    // 3. Update streak
    _bumpStreakOnce();

    // 4. Evaluate badges
    final newlyEarned = _evaluateBadges(savedProjectsCount: 0);
    if (newlyEarned.isNotEmpty) {
      _data = _data.copyWith(
        earnedBadges: {
          ..._data.earnedBadges,
          ...newlyEarned.map((b) => b.id),
        },
      );
    }

    await _persist();

    return CompletionResult(
      xpEarned: lesson.xpReward,
      levelUp: leveled,
      newLevel: currentLevel,
      newlyEarnedBadges: newlyEarned,
      nextLesson: recommendedNextLesson,
    );
  }

  /// Re-evaluate badges given an external count (e.g. projects). Called
  /// after non-lesson events that might trigger a badge.
  Future<List<LearnerBadge>> evaluateBadges({
    required int savedProjectsCount,
  }) async {
    final newly = _evaluateBadges(savedProjectsCount: savedProjectsCount);
    if (newly.isEmpty) return const [];

    _data = _data.copyWith(
      earnedBadges: {
        ..._data.earnedBadges,
        ...newly.map((b) => b.id),
      },
    );
    await _persist();
    return newly;
  }

  List<LearnerBadge> _evaluateBadges({required int savedProjectsCount}) {
    final ctx = BadgeContext(
      completedLessonsCount: _data.completedLessons.length,
      streakDays: _data.streakDays,
      savedProjectsCount: savedProjectsCount,
      completedLessonIds: _data.completedLessons,
      allLessons: LessonsCatalog.all,
    );
    final out = <LearnerBadge>[];
    for (final b in kBadges) {
      if (_data.earnedBadges.contains(b.id)) continue;
      if (b.earned(ctx)) out.add(b);
    }
    return out;
  }

  /// Lazy compatibility shim with the user's named method. The locking
  /// model is derived, not stored — this just persists current state.
  Future<void> unlockNextLesson() async {
    await _persist(notify: false);
  }

  // ── Dev/test only ──
  Future<void> resetAll() async {
    _data = LearningProgressData.empty;
    await LearningStorage.instance.clear();
    notifyListeners();
  }

  // ── Date helpers (local time) ──
  DateTime _today() => _dateOnly(DateTime.now());

  DateTime _dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
