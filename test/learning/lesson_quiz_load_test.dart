import 'package:devpath/features/learning/data/lessons_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('h1_heading catalog quiz has playable questions', () {
    final lesson = LessonsCatalog.byId('h1_heading');
    expect(lesson, isNotNull);
    expect(lesson!.quizQuestions.length, greaterThanOrEqualTo(3));
    for (final q in lesson.quizQuestions) {
      expect(q.question.trim(), isNotEmpty);
      expect(q.options.length, greaterThanOrEqualTo(2));
      expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
    }
  });

  test('b01_html catalog quiz has playable questions', () {
    final lesson = LessonsCatalog.byId('b01_html');
    expect(lesson, isNotNull);
    expect(lesson!.quizQuestions, isNotEmpty);
  });
}
