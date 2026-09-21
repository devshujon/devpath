import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/editor/models/project.dart';
import '../../features/learn/models/lesson.dart';
import '../../features/learn/models/progress.dart';
import '../../features/quiz/models/question.dart';
import '../../features/quiz/models/quiz_attempt.dart';
import '../../features/quiz/models/unlock_timer.dart';
import '../constants/hive_boxes.dart';
import 'adapters_registry.dart';

/// Singleton wrapping Hive lifecycle. All box access goes through this.
/// Includes safe-open with corruption recovery.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  bool _initialized = false;

  /// True if any box was wiped during init due to corruption.
  /// UI may show a one-time notice using this flag.
  bool didRecoverFromCorruption = false;
  final List<String> recoveredBoxes = [];

  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();
    registerHiveAdapters();

    await Future.wait([
      _safeOpen<Lesson>(HiveBoxes.lessons, 'lessons'),
      _safeOpen<Progress>(HiveBoxes.progress, 'progress'),
      _safeOpen<Project>(HiveBoxes.projects, 'projects'),
      _safeOpen<Question>(HiveBoxes.questions, 'questions'),
      _safeOpen<QuizAttempt>(HiveBoxes.quizAttempts, 'quiz history'),
      _safeOpen<UnlockTimer>(HiveBoxes.unlockTimers, 'unlock timers'),
      _safeOpenUntyped(HiveBoxes.settings, 'settings'),
    ]);

    _initialized = true;
  }

  Future<Box<T>> _safeOpen<T>(String name, String label) async {
    try {
      return await Hive.openBox<T>(name);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('StorageService: "$name" corrupted ($e). Recreating.');
        debugPrint('$st');
      }
      didRecoverFromCorruption = true;
      recoveredBoxes.add(label);
      try {
        if (Hive.isBoxOpen(name)) await Hive.box<T>(name).close();
      } catch (_) {}
      try {
        await Hive.deleteBoxFromDisk(name);
      } catch (e) {
        if (kDebugMode) debugPrint('deleteBoxFromDisk failed for $name: $e');
      }
      return Hive.openBox<T>(name);
    }
  }

  Future<Box<dynamic>> _safeOpenUntyped(String name, String label) async {
    try {
      return await Hive.openBox(name);
    } catch (e) {
      if (kDebugMode) debugPrint('StorageService: "$name" corrupted ($e). Recreating.');
      didRecoverFromCorruption = true;
      recoveredBoxes.add(label);
      try {
        if (Hive.isBoxOpen(name)) await Hive.box(name).close();
      } catch (_) {}
      try {
        await Hive.deleteBoxFromDisk(name);
      } catch (_) {}
      return Hive.openBox(name);
    }
  }

  // ─── Typed accessors ───
  Box<Lesson>      get lessons      => Hive.box<Lesson>(HiveBoxes.lessons);
  Box<Progress>    get progress     => Hive.box<Progress>(HiveBoxes.progress);
  Box<Project>     get projects     => Hive.box<Project>(HiveBoxes.projects);
  Box<Question>    get questions    => Hive.box<Question>(HiveBoxes.questions);
  Box<QuizAttempt> get quizAttempts => Hive.box<QuizAttempt>(HiveBoxes.quizAttempts);
  Box<UnlockTimer> get unlockTimers => Hive.box<UnlockTimer>(HiveBoxes.unlockTimers);
  Box<dynamic>     get settings     => Hive.box(HiveBoxes.settings);

  // ─── Settings helpers ───
  T? getSetting<T>(String key, {T? defaultValue}) =>
      settings.get(key, defaultValue: defaultValue) as T?;

  Future<void> setSetting(String key, dynamic value) =>
      settings.put(key, value);

  Future<void> deleteSetting(String key) => settings.delete(key);
}
