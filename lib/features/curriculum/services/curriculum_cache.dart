import '../models/lesson_content.dart';

/// In-memory cache of parsed [LessonContent], keyed by lesson id.
///
/// Misses are cached as `null` so a lesson with no JSON file is only
/// looked up on the asset bundle once per session. The cache holds only
/// content for lessons the user has actually opened, so memory stays
/// flat regardless of how large the curriculum grows.
class CurriculumCache {
  final Map<String, LessonContent?> _entries = {};

  bool contains(String lessonId) => _entries.containsKey(lessonId);

  LessonContent? get(String lessonId) => _entries[lessonId];

  void put(String lessonId, LessonContent? content) =>
      _entries[lessonId] = content;

  void clear() => _entries.clear();
}
