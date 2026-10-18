import 'package:devpath/features/learning/data/lessons_catalog.dart';
import 'package:devpath/features/learning/data/python_lessons.dart';
import 'package:devpath/features/learning/logic/lesson_progression.dart';
import 'package:devpath/features/learning/models/lesson.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Python track catalog', () {
    test('has 14 beginner Python lessons with unique ids', () {
      expect(pythonLessons.length, 14);
      final ids = pythonLessons.map((l) => l.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final l in pythonLessons) {
        expect(l.track, LessonTrack.python);
        expect(l.difficulty, Difficulty.beginner);
        expect(l.quizQuestions.length, greaterThanOrEqualTo(3));
        expect(l.starterCode['python'], isNotEmpty);
      }
    });

    test('byTrack returns only Python lessons', () {
      final py = LessonsCatalog.byTrack(LessonTrack.python);
      expect(py.length, 14);
      expect(py.every((l) => l.track == LessonTrack.python), isTrue);
    });

    test('catalog ids remain globally unique', () {
      final ids = LessonsCatalog.all.map((l) => l.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('existing HTML track lessons remain in catalog', () {
      final htmlIds = LessonsCatalog.byTrack(LessonTrack.html).map((l) => l.id);
      expect(htmlIds, contains('h1_heading'));
      expect(htmlIds, contains('b01_html'));
      expect(LessonsCatalog.byTrack(LessonTrack.html).length, greaterThan(10));
    });
  });

  group('Python sequential unlock isolation', () {
    test('first Python lesson unlocked with empty progress', () {
      final ids = pythonLessons.map((l) => l.id).toList();
      expect(
        computeLessonLocked(
          lessonId: ids.first,
          difficulty: Difficulty.beginner,
          sameDifficultyIds: ids,
          completedIds: const {},
          beginnerProgress: 0,
          intermediateProgress: 0,
        ),
        isFalse,
      );
    });

    test('second Python lesson locked until first completes', () {
      final ids = pythonLessons.map((l) => l.id).toList();
      expect(
        computeLessonLocked(
          lessonId: ids[1],
          difficulty: Difficulty.beginner,
          sameDifficultyIds: ids,
          completedIds: const {},
          beginnerProgress: 0,
          intermediateProgress: 0,
        ),
        isTrue,
      );
      expect(
        computeLessonLocked(
          lessonId: ids[1],
          difficulty: Difficulty.beginner,
          sameDifficultyIds: ids,
          completedIds: {ids.first},
          beginnerProgress: 0,
          intermediateProgress: 0,
        ),
        isFalse,
      );
    });
  });
}
