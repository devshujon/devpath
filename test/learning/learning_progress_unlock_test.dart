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

  test('fresh install: first catalog lesson is unlocked', () {
    final provider = LearningProgressProvider.test(LearningProgressData.empty);
    final first = provider.lessonsByDifficulty(Difficulty.beginner).first;
    expect(first.id, 'h1_heading');
    expect(first.isLocked, isFalse);
    expect(first.isCompleted, isFalse);
    expect(provider.recommendedNextLesson?.id, 'h1_heading');
  });

  test('inserting h1_heading does not lock a completed b01_html', () {
    final provider = LearningProgressProvider.test(
      const LearningProgressData(
        completedLessons: {'b01_html'},
        currentXP: 50,
      ),
    );
    final html = provider.lessonWithProgress(LessonsCatalog.byId('b01_html')!);
    expect(html.isCompleted, isTrue);
    expect(html.isLocked, isFalse);

    final heading =
        provider.lessonWithProgress(LessonsCatalog.byId('h1_heading')!);
    expect(heading.isCompleted, isFalse);
    expect(heading.isLocked, isFalse);
  });

  test('completeLesson does not award XP for a locked incomplete lesson', () async {
    final provider = LearningProgressProvider.test(LearningProgressData.empty);
    final beforeXp = provider.currentXP;
    final result = await provider.completeLesson('b01_html');
    expect(result.xpEarned, 0);
    expect(provider.completedLessons.contains('b01_html'), isFalse);
    expect(provider.currentXP, beforeXp);
  });

  test('completeLesson remains idempotent and does not reset XP', () async {
    final provider = LearningProgressProvider.test(
      const LearningProgressData(
        completedLessons: {'h1_heading'},
        currentXP: 50,
        streakDays: 2,
      ),
    );
    final result = await provider.completeLesson('h1_heading');
    expect(result.xpEarned, 0);
    expect(provider.currentXP, 50);
    expect(provider.streakDays, 2);
    expect(provider.completedLessons, {'h1_heading'});
  });

  test('overallProgress ignores orphan completion ids', () {
    final provider = LearningProgressProvider.test(
      const LearningProgressData(
        completedLessons: {'h1_heading', 'legacy_removed_lesson'},
        currentXP: 50,
      ),
    );
    final expected = 1 / LessonsCatalog.all.length;
    expect(provider.overallProgress(), closeTo(expected, 0.0001));
  });

  test('XP is unchanged when decorating lock state', () {
    final provider = LearningProgressProvider.test(
      const LearningProgressData(
        completedLessons: {'b01_html', 'b02_css'},
        currentXP: 100,
        streakDays: 3,
      ),
    );
    expect(provider.currentXP, 100);
    expect(provider.streakDays, 3);
    expect(provider.completedLessons, {'b01_html', 'b02_css'});
  });
}
