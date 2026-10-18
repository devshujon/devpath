import '../models/lesson.dart';

/// Validates in-app lesson quiz definitions before rendering.
List<String> validateLessonQuiz(Lesson lesson) {
  final errors = <String>[];
  if (lesson.quizQuestions.isEmpty) {
    errors.add('No quiz questions defined.');
    return errors;
  }
  for (var i = 0; i < lesson.quizQuestions.length; i++) {
    final q = lesson.quizQuestions[i];
    final label = 'Q${i + 1}';
    if (q.question.trim().isEmpty) {
      errors.add('$label: empty question text.');
    }
    if (q.options.length < 2) {
      errors.add('$label: needs at least 2 options.');
    }
    for (var o = 0; o < q.options.length; o++) {
      if (q.options[o].trim().isEmpty) {
        errors.add('$label: option ${o + 1} is empty.');
      }
    }
    if (q.correctIndex < 0 || q.correctIndex >= q.options.length) {
      errors.add(
        '$label: correctIndex ${q.correctIndex} out of range '
        '0..${q.options.length - 1}.',
      );
    }
  }
  return errors;
}
