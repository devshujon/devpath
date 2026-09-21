import 'package:devpath/features/learning/logic/lesson_progression.dart';
import 'package:devpath/features/learning/models/lesson.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveLessonVisualState', () {
    test('completed wins over locked', () {
      expect(
        resolveLessonVisualState(isCompleted: true, isLocked: true),
        LessonVisualState.completed,
      );
    });

    test('completed wins over current', () {
      expect(
        resolveLessonVisualState(
          isCompleted: true,
          isLocked: false,
          isCurrent: true,
        ),
        LessonVisualState.completed,
      );
    });

    test('locked when not completed', () {
      expect(
        resolveLessonVisualState(isCompleted: false, isLocked: true),
        LessonVisualState.locked,
      );
    });

    test('current when unlocked and flagged', () {
      expect(
        resolveLessonVisualState(
          isCompleted: false,
          isLocked: false,
          isCurrent: true,
        ),
        LessonVisualState.current,
      );
    });

    test('unlocked otherwise', () {
      expect(
        resolveLessonVisualState(isCompleted: false, isLocked: false),
        LessonVisualState.unlocked,
      );
    });
  });

  group('computeLessonLocked', () {
    const beginnerIds = [
      'h1_heading',
      'b01_html',
      'b02_css',
    ];

    test('first lesson is unlocked on a fresh install', () {
      expect(
        computeLessonLocked(
          lessonId: 'h1_heading',
          difficulty: Difficulty.beginner,
          sameDifficultyIds: beginnerIds,
          completedIds: {},
          beginnerProgress: 0,
          intermediateProgress: 0,
        ),
        isFalse,
      );
    });

    test('completed b01_html stays unlocked after inserting h1_heading', () {
      expect(
        computeLessonLocked(
          lessonId: 'b01_html',
          difficulty: Difficulty.beginner,
          sameDifficultyIds: beginnerIds,
          completedIds: {'b01_html'},
          beginnerProgress: 1 / 3,
          intermediateProgress: 0,
        ),
        isFalse,
      );
    });

    test('incomplete second lesson locks until the first is done', () {
      expect(
        computeLessonLocked(
          lessonId: 'b01_html',
          difficulty: Difficulty.beginner,
          sameDifficultyIds: beginnerIds,
          completedIds: {},
          beginnerProgress: 0,
          intermediateProgress: 0,
        ),
        isTrue,
      );
    });

    test('next lesson unlocks when the previous is complete', () {
      expect(
        computeLessonLocked(
          lessonId: 'b01_html',
          difficulty: Difficulty.beginner,
          sameDifficultyIds: beginnerIds,
          completedIds: {'h1_heading'},
          beginnerProgress: 1 / 3,
          intermediateProgress: 0,
        ),
        isFalse,
      );
    });

    test('intermediate stays gated until 50% beginner complete', () {
      expect(
        computeLessonLocked(
          lessonId: 'i01_flexbox',
          difficulty: Difficulty.intermediate,
          sameDifficultyIds: const ['i01_flexbox'],
          completedIds: {},
          beginnerProgress: 0.4,
          intermediateProgress: 0,
        ),
        isTrue,
      );
      expect(
        computeLessonLocked(
          lessonId: 'i01_flexbox',
          difficulty: Difficulty.intermediate,
          sameDifficultyIds: const ['i01_flexbox'],
          completedIds: {},
          beginnerProgress: 0.5,
          intermediateProgress: 0,
        ),
        isFalse,
      );
    });

    test('completed intermediate is never locked by the 50% gate', () {
      expect(
        computeLessonLocked(
          lessonId: 'i01_flexbox',
          difficulty: Difficulty.intermediate,
          sameDifficultyIds: const ['i01_flexbox'],
          completedIds: {'i01_flexbox'},
          beginnerProgress: 0.0,
          intermediateProgress: 1.0,
        ),
        isFalse,
      );
    });
  });

  group('difficultyCompletionRatio', () {
    test('empty list is 0', () {
      expect(
        difficultyCompletionRatio(ids: const [], completedIds: {'a'}),
        0,
      );
    });

    test('counts only ids in the list', () {
      expect(
        difficultyCompletionRatio(
          ids: const ['a', 'b', 'c'],
          completedIds: {'a', 'z'},
        ),
        closeTo(1 / 3, 0.0001),
      );
    });
  });
}
