import 'package:devpath/features/learning/data/lessons_catalog.dart';
import 'package:devpath/features/learning/logic/lesson_quiz_validator.dart';
import 'package:flutter_test/flutter_test.dart';

/// IDs with hand-authored quizzes (see tool/learning_tracks/priority_lesson_overrides.dart).
const priorityLessonIds = {
  // Batch 1
  'php_22',
  'php_23',
  'php_24',
  'php_36',
  'sql_17',
  'sql_18',
  'sql_19',
  'sql_20',
  'sql_36',
  'typescript_09',
  'typescript_10',
  'web_essentials_23',
  'web_essentials_28',
  // Batch 2
  'php_13',
  'php_18',
  'php_25',
  'php_26',
  'php_27',
  'php_28',
  'php_35',
  'php_37',
  'sql_26',
  'sql_27',
  'sql_31',
  'sql_32',
  'typescript_06',
  'typescript_13',
  'typescript_14',
  'python_05',
  'python_09',
  'python_12',
  'web_essentials_22',
  'web_essentials_31',
  'web_essentials_32',
  'web_essentials_43',
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

  test('secure backend content is on php_36 not mis-tagged php_37', () {
    final secure = LessonsCatalog.byId('php_36')!;
    final testing = LessonsCatalog.byId('php_37')!;
    expect(secure.title, 'Secure Backend Architecture');
    expect(testing.title, 'Testing PHP Applications');
    expect(
      secure.quizQuestions.first.question.contains('Defense in depth'),
      isTrue,
    );
    expect(
      testing.quizQuestions.first.question.contains('PHPUnit'),
      isTrue,
    );
  });
}
