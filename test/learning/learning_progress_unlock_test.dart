import 'package:devpath/features/learning/data/lessons_catalog.dart';
import 'package:devpath/features/learning/models/lesson.dart';
import 'package:devpath/features/learning/providers/learning_progress_provider.dart';
import 'package:devpath/features/learning/services/learning_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
