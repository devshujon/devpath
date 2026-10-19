import 'dart:convert';

import 'package:devpath/features/learning/data/lessons_catalog.dart';
import 'package:devpath/features/learning/models/lesson.dart';
import 'package:devpath/features/learning/providers/learning_progress_provider.dart';
import 'package:devpath/features/learning/services/learning_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('legacy learning_progress_v1 JSON loads without migration key', () async {
    final legacy = {
      'completedLessons': ['h1_heading', 'b01_html'],
      'currentXP': 120,
      'streakDays': 3,
      'longestStreak': 5,
      'totalMinutesLearned': 40,
      'earnedBadges': ['html_starter'],
    };
    SharedPreferences.setMockInitialValues({
      'learning_progress_v1': jsonEncode(legacy),
    });
    final loaded = await LearningStorage.instance.load();
    expect(loaded.completedLessons, {'h1_heading', 'b01_html'});
    expect(loaded.currentXP, 120);
    expect(loaded.streakDays, 3);
  });

  test('completeLesson twice does not duplicate XP', () async {
    final provider = LearningProgressProvider.test(LearningProgressData.empty);
    final first = await provider.completeLesson('h1_heading');
    expect(first.xpEarned, greaterThan(0));
    final xpAfter = provider.currentXP;
    final second = await provider.completeLesson('h1_heading');
    expect(second.xpEarned, 0);
    expect(provider.currentXP, xpAfter);
  });

  test('adding php catalog does not lock completed html intermediate', () async {
    final completed = <String>{
      for (final l in LessonsCatalog.byDifficulty(Difficulty.beginner))
        if (l.track == LessonTrack.html ||
            l.track == LessonTrack.css ||
            l.track == LessonTrack.js)
          l.id,
    };
    final provider = LearningProgressProvider.test(
      LearningProgressData(completedLessons: completed, currentXP: 800),
    );
    final semantic = provider.lessonWithProgress(
      LessonsCatalog.byId('html_semantic')!,
    );
    expect(semantic.isLocked, isFalse);
  });
}
