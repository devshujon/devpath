import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/quiz_item.dart';

/// Loads an advanced [QuizSet] for a lesson from bundled assets, offline.
///
/// Path convention: `assets/quizzes/advanced/<lessonId>.json`
/// Returns null when a lesson has no advanced quiz yet — callers simply
/// don't show the advanced-practice entry point. Results (and misses, as
/// null) are cached so a set parses at most once per session.
class QuizSetLoader {
  QuizSetLoader._();
  static final QuizSetLoader instance = QuizSetLoader._();

  final Map<String, QuizSet?> _cache = {};

  Future<QuizSet?> load(String lessonId) async {
    if (_cache.containsKey(lessonId)) return _cache[lessonId];

    final path = 'assets/quizzes/advanced/$lessonId.json';
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        _cache[lessonId] = null;
        return null;
      }
      final set = QuizSet.fromJson(decoded.cast<String, dynamic>());
      final result = set.isEmpty ? null : set;
      _cache[lessonId] = result;
      return result;
    } catch (_) {
      _cache[lessonId] = null;
      return null;
    }
  }
}
