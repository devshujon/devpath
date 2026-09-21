import 'package:flutter/foundation.dart' show setEquals;

import '../models/quiz_item.dart';

/// Grades a [QuizAnswer] against any [QuizItem].
///
/// Two strategies cover all six types:
///   • SELECTION  — compare the chosen index / set to the correct one
///                  (mcq, outputPrediction, findBug, multiSelect)
///   • TEXT MATCH — normalized comparison against accepted answers
///                  (fillBlank, completeCode)
///
/// Text matching is whitespace- and case-insensitive and accepts any of
/// the author-listed variants, which is more precise and reliable for a
/// quiz than fuzzy code execution. (Free-form code grading via the
/// existing ChallengeValidator is reserved for a future coding-exam mode.)
class QuizGrader {
  const QuizGrader._();

  static bool isCorrect(QuizItem item, QuizAnswer answer) => switch (item) {
        McqItem i => answer.selectedIndex == i.correctIndex,
        OutputPredictionItem i => answer.selectedIndex == i.correctIndex,
        FindBugItem i => answer.selectedIndex == i.correctIndex,
        MultiSelectItem i =>
          answer.selectedSet.isNotEmpty && setEquals(answer.selectedSet, i.correctIndices),
        FillBlankItem i => _matches(answer.text, i.acceptedAnswers),
        CompleteCodeItem i => _matches(answer.text, i.acceptedAnswers),
      };

  static String _normalize(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static bool _matches(String input, List<String> accepted) {
    if (input.trim().isEmpty) return false;
    final norm = _normalize(input);
    return accepted.any((a) => _normalize(a) == norm);
  }
}
