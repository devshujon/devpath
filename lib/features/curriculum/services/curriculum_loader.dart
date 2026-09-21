import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show FlutterError, rootBundle;

import '../../learning/models/lesson.dart';
import '../models/lesson_content.dart';
import 'curriculum_cache.dart';

/// Loads rich lesson content from bundled JSON assets, offline.
///
/// Path convention: assets/curriculum/<track-key>/<lessonId>.json
/// (e.g. assets/curriculum/html/h1_heading.json).
///
/// Returns null when a lesson has no JSON file yet — callers fall back
/// to the existing simple lesson layout. Parsed results (and misses, as
/// null) are stored in a [CurriculumCache], so a lesson parses at most
/// once per session. Only the opened lesson is ever loaded, so this
/// scales to hundreds of lessons. No network is ever touched.
class CurriculumLoader {
  CurriculumLoader._();
  static final CurriculumLoader instance = CurriculumLoader._();

  final CurriculumCache _cache = CurriculumCache();

  @visibleForTesting
  CurriculumCache get cache => _cache;

  Future<LessonContent?> load(Lesson lesson) async {
    if (_cache.contains(lesson.id)) return _cache.get(lesson.id);

    final path = 'assets/curriculum/${lesson.track.key}/${lesson.id}.json';
    try {
      final raw = await rootBundle.loadString(path);
      final result = decodeAndParse(raw);
      if (result == null && kDebugMode) {
        debugPrint('Curriculum: $path parsed empty or invalid — using fallback');
      }
      _cache.put(lesson.id, result);
      return result;
    } on FlutterError catch (e) {
      if (kDebugMode) {
        debugPrint('Curriculum: asset missing for ${lesson.id} ($path): $e');
      }
      _cache.put(lesson.id, null);
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Curriculum: failed to parse ${lesson.id}: $e');
      }
      _cache.put(lesson.id, null);
      return null;
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
