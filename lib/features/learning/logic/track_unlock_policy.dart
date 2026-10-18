import '../models/lesson.dart';

/// Tracks that share the original interleaved HTML → CSS → JS unlock path.
bool isWebCoreTrack(LessonTrack track) =>
    track == LessonTrack.html ||
    track == LessonTrack.css ||
    track == LessonTrack.js;

/// Tracks that unlock sequentially within the same track + difficulty only.
bool isIndependentTrack(LessonTrack track) =>
    !isWebCoreTrack(track) && track != LessonTrack.capstone;

/// Catalog order for sequential unlock within a difficulty bucket.
List<String> sequentialUnlockIdsFor({
  required Lesson lesson,
  required List<Lesson> sameDifficulty,
}) {
  if (lesson.track == LessonTrack.capstone) {
    return sameDifficulty
        .where((l) => l.track == LessonTrack.capstone)
        .map((l) => l.id)
        .toList();
  }
  if (isIndependentTrack(lesson.track)) {
    return sameDifficulty
        .where((l) => l.track == lesson.track)
        .map((l) => l.id)
        .toList();
  }
  return sameDifficulty
      .where((l) => isWebCoreTrack(l.track))
      .map((l) => l.id)
      .toList();
}

/// Progress ratio used for intermediate/advanced gates for [lesson].
List<String> difficultyIdsForGate({
  required Lesson lesson,
  required List<Lesson> sameDifficulty,
}) {
  if (lesson.track == LessonTrack.capstone) {
    return sameDifficulty
        .where((l) => isWebCoreTrack(l.track))
        .map((l) => l.id)
        .toList();
  }
  if (isIndependentTrack(lesson.track)) {
    return sameDifficulty
        .where((l) => l.track == lesson.track)
        .map((l) => l.id)
        .toList();
  }
  return sameDifficulty
      .where((l) => isWebCoreTrack(l.track))
      .map((l) => l.id)
      .toList();
}
