import 'package:devpath/features/learning/data/lessons_catalog.dart';
import 'package:devpath/features/learning/logic/lesson_quiz_validator.dart';
import 'package:flutter_test/flutter_test.dart';

/// IDs with hand-authored quizzes (see tool/learning_tracks/priority_lesson_overrides.dart).
const priorityLessonIds = {
  'php_22',
  'php_23',
  'php_24',
  'php_37',
  'sql_17',
  'sql_18',
  'sql_19',
  'sql_20',
  'sql_36',
  'typescript_09',
  'typescript_10',
  'web_essentials_23',
  'web_essentials_28',
};

void main() {
  test('priority lessons use topic-specific quizzes', () {
    for (final id in priorityLessonIds) {
      final lesson = LessonsCatalog.byId(id);
      expect(lesson, isNotNull, reason: id);
      final questions = lesson!.quizQuestions.map((q) => q.question).join(' ');
      expect(
        questions.contains('What is the main focus of'),
        isFalse,
        reason: '$id still uses generator template quiz',
      );
      expect(validateLessonQuiz(lesson), isEmpty, reason: id);
      expect(lesson.quizQuestions.length, greaterThanOrEqualTo(3), reason: id);
    }
  });

  test('priority php_24 reinforces prepared statements', () {
    final lesson = LessonsCatalog.byId('php_24')!;
    final blob = lesson.quizQuestions
        .expand((q) => [q.question, ...q.options, q.explanation ?? ''])
        .join(' ');
    expect(blob.contains('Prepared statements'), isTrue);
    expect(blob.toLowerCase().contains('injection'), isTrue);
  });
}
