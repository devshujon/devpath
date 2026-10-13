import 'package:devpath/features/learning/data/lessons_catalog.dart';
import 'package:devpath/features/learning/logic/lesson_quiz_validator.dart';
import 'package:devpath/features/learning/models/lesson.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every catalog lesson with a quiz passes validation', () {
    for (final lesson in LessonsCatalog.all) {
      if (lesson.quizQuestions.isEmpty) continue;
      final errors = validateLessonQuiz(lesson);
      expect(
        errors,
        isEmpty,
        reason: '${lesson.id}: ${errors.join('; ')}',
      );
    }
  });

  test('h1_heading has five validated questions with h1 option', () {
    final lesson = LessonsCatalog.byId('h1_heading')!;
    expect(lesson.quizQuestions.length, 5);
    expect(validateLessonQuiz(lesson), isEmpty);
    expect(
      lesson.quizQuestions.first.options,
      contains('<h1>'),
    );
    expect(lesson.quizQuestions.first.correctIndex, 0);
  });

  test('validateLessonQuiz rejects malformed question', () {
    final base = LessonsCatalog.byId('h1_heading')!;
    final bad = Lesson(
      id: base.id,
      title: base.title,
      description: base.description,
      module: base.module,
      difficulty: base.difficulty,
      track: base.track,
      estimatedMinutes: base.estimatedMinutes,
      xpReward: base.xpReward,
      starterCode: base.starterCode,
      quizQuestions: const [
        QuizQuestion(
          question: 'Bad',
          options: ['a', 'b'],
          correctIndex: 5,
        ),
      ],
    );
    expect(validateLessonQuiz(bad), isNotEmpty);
  });

  test('b01_html has three validated questions', () {
    final lesson = LessonsCatalog.byId('b01_html')!;
    expect(lesson.quizQuestions.length, 3);
    expect(validateLessonQuiz(lesson), isEmpty);
  });
}
