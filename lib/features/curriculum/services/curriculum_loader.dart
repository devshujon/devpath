import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../learning/models/lesson.dart';
import '../models/curriculum_load_result.dart';
import '../models/lesson_content.dart';
import 'curriculum_cache.dart';

/// Loads rich lesson content from bundled JSON assets, offline.
///
/// Path convention: `assets/curriculum/<track-key>/<lessonId>.json`
/// (e.g. `assets/curriculum/html/h1_heading.json`).
///
/// [loadResult] distinguishes a missing file (expected fallback) from
/// a parse failure (show a banner, still fall back). Results are cached
/// so a lesson parses at most once per session.
class CurriculumLoader {
  CurriculumLoader._();
  static final CurriculumLoader instance = CurriculumLoader._();

  final CurriculumCache _cache = CurriculumCache();

  @visibleForTesting
  CurriculumCache get cache => _cache;

  Future<LessonContent?> load(Lesson lesson) async {
    return (await loadResult(lesson)).content;
  }

  Future<CurriculumLoadResult> loadResult(Lesson lesson) async {
    final cached = _cache.get(lesson.id);
    if (cached != null) return cached;

    final path = 'assets/curriculum/${lesson.track.key}/${lesson.id}.json';
    try {
      final raw = await rootBundle.loadString(path);
      final parsed = decodeAndParse(raw);
      final result = parsed == null
          ? const CurriculumLoadResult.failed()
          : CurriculumLoadResult.loaded(parsed);
      if (parsed == null && kDebugMode) {
        debugPrint('Curriculum: $path parsed empty or invalid — using fallback');
      }
      _cache.put(lesson.id, result);
      return result;
    } on FlutterError catch (e) {
      if (kDebugMode) {
        debugPrint('Curriculum: asset missing for ${lesson.id} ($path): $e');
      }
      const result = CurriculumLoadResult.missing();
      _cache.put(lesson.id, result);
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Curriculum: failed to parse ${lesson.id}: $e');
      }
      const result = CurriculumLoadResult.failed();
      _cache.put(lesson.id, result);
      return result;
    }
  }

  /// Decode a JSON string into [LessonContent]. Safe for tests and
  /// the asset path. Returns null on malformed / empty payloads.
  static LessonContent? decodeAndParse(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return parseLessonContentJson(decoded);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Curriculum: JSON decode failed: $e');
      }
      return null;
    }
  }
}
