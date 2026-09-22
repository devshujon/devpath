import '../models/curriculum_load_result.dart';

/// In-memory cache of [CurriculumLoadResult], keyed by lesson id.
///
/// Missing and failed results are cached so a lesson is only looked up
/// on the asset bundle once per session. The cache holds only lessons
/// the user has actually opened.
class CurriculumCache {
  final Map<String, CurriculumLoadResult> _entries = {};

  bool contains(String lessonId) => _entries.containsKey(lessonId);

  CurriculumLoadResult? get(String lessonId) => _entries[lessonId];

  void put(String lessonId, CurriculumLoadResult result) =>
      _entries[lessonId] = result;

  void clear() => _entries.clear();
}
