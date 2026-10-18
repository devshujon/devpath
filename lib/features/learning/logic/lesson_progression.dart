import '../models/lesson.dart';

/// Visual state for a lesson node or tile.
///
/// Precedence is deterministic and must stay in this order so inserting
/// new catalog lessons can never hide already-completed work:
///
///   completed > current > unlocked > locked
enum LessonVisualState { completed, current, unlocked, locked }

/// Resolve the UI state for a lesson. [isCompleted] always wins over
/// [isLocked] — a completed lesson is never drawn as locked.
LessonVisualState resolveLessonVisualState({
  required bool isCompleted,
  required bool isLocked,
  bool isCurrent = false,
}) {
  if (isCompleted) return LessonVisualState.completed;
  if (isLocked) return LessonVisualState.locked;
  if (isCurrent) return LessonVisualState.current;
  return LessonVisualState.unlocked;
}

/// Whether a lesson should be treated as locked for navigation.
///
/// Defensive rules:
/// - A completed lesson is NEVER locked. Adding a new catalog entry
///   (e.g. inserting `h1_heading` before `b01_html`) must not hide
///   lessons the user already finished.
/// - Fresh installs: the first lesson in a difficulty is unlocked.
/// - Existing unlock rules are otherwise unchanged:
///     beginner sequential; intermediate gated by ≥50% beginner;
///     advanced gated by ≥50% intermediate; sequential within difficulty.
bool computeLessonLocked({
  required String lessonId,
  required Difficulty difficulty,
  required List<String> sameDifficultyIds,
  required Set<String> completedIds,
  required double beginnerProgress,
  required double intermediateProgress,
}) {
  if (completedIds.contains(lessonId)) return false;

  if (difficulty == Difficulty.intermediate && beginnerProgress < 0.5) {
    return true;
  }
  if (difficulty == Difficulty.advanced && intermediateProgress < 0.5) {
    return true;
  }

  final idx = sameDifficultyIds.indexOf(lessonId);
  if (idx < 0) return true;
  if (idx == 0) return false;
  return !completedIds.contains(sameDifficultyIds[idx - 1]);
}

/// After a completion overlay closes, pop the current route only when
/// the user did not already navigate to the next item.
bool shouldPopAfterCompletionOverlay({required bool navigatedAway}) =>
    !navigatedAway;

/// First unlocked, incomplete lesson after [afterId] in [catalogIds].
/// Falls back to the first unlocked incomplete in the list (catch-up).
String? nextLessonIdAfter({
  required String afterId,
  required List<String> catalogIds,
  required Set<String> completedIds,
  required bool Function(String id) isLocked,
}) {
  final start = catalogIds.indexOf(afterId);
  if (start >= 0) {
    for (var i = start + 1; i < catalogIds.length; i++) {
      final id = catalogIds[i];
      if (!completedIds.contains(id) && !isLocked(id)) return id;
    }
  }
  for (final id in catalogIds) {
    if (!completedIds.contains(id) && !isLocked(id)) return id;
  }
  return null;
}

/// Ratio of completed lessons in [ids] (0..1). Empty list → 0.
double difficultyCompletionRatio({
  required List<String> ids,
  required Set<String> completedIds,
}) {
  if (ids.isEmpty) return 0;
  var done = 0;
  for (final id in ids) {
    if (completedIds.contains(id)) done++;
  }
  return done / ids.length;
}
