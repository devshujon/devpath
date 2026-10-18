// Advanced quiz engine — data model.
//
// A QuizSet is an ordered list of QuizItems. QuizItem is a sealed type
// with six concrete forms. The six reduce to two grading strategies
// (see quiz_grader.dart): SELECTION (mcq, multiSelect, outputPrediction,
// findBug) and TEXT MATCH (fillBlank, completeCode). Explanations are
// always present and always shown for free after answering.

enum QuizDifficulty { beginner, intermediate, advanced, expert }

QuizDifficulty _difficulty(String? s) => switch (s) {
      'intermediate' => QuizDifficulty.intermediate,
      'advanced' => QuizDifficulty.advanced,
      'expert' => QuizDifficulty.expert,
      _ => QuizDifficulty.beginner,
    };

extension QuizDifficultyLabel on QuizDifficulty {
  String get label => switch (this) {
        QuizDifficulty.beginner => 'Beginner',
        QuizDifficulty.intermediate => 'Intermediate',
        QuizDifficulty.advanced => 'Advanced',
        QuizDifficulty.expert => 'Expert',
      };
}

/// The post-answer explanation. Always free, always shown.
class Explanation {
  final String whyCorrect;
  final List<String> whyOthersWrong;
  final String? bestPractice;

  const Explanation({
    required this.whyCorrect,
    this.whyOthersWrong = const [],
    this.bestPractice,
  });

  factory Explanation.fromJson(Map<String, dynamic> j) => Explanation(
        whyCorrect: _str(j['whyCorrect']),
        whyOthersWrong: _strList(j['whyOthersWrong']),
        bestPractice: _strOrNull(j['bestPractice']),
      );
}

sealed class QuizItem {
  final String id;
  final String prompt;
  final QuizDifficulty difficulty;
  final Explanation explanation;

  const QuizItem({
    required this.id,
    required this.prompt,
    required this.difficulty,
    required this.explanation,
  });

  /// Parses one item, or null for an unknown/forward-compat type.
  static QuizItem? tryParse(Map<String, dynamic> j) {
    final type = j['type'] as String? ?? '';
    final id = _str(j['id']);
    final prompt = _str(j['prompt']);
    final diff = _difficulty(j['difficulty'] as String?);
    final exp = Explanation.fromJson(
      (j['explanation'] as Map?)?.cast<String, dynamic>() ?? const {},
    );

    switch (type) {
      case 'mcq':
        return McqItem(
          id: id, prompt: prompt, difficulty: diff, explanation: exp,
          options: _strList(j['options']),
          correctIndex: _int(j['correctIndex'], 0),
        );
      case 'multiSelect':
        return MultiSelectItem(
          id: id, prompt: prompt, difficulty: diff, explanation: exp,
          options: _strList(j['options']),
          correctIndices: _intList(j['correctIndices']).toSet(),
        );
      case 'outputPrediction':
        return OutputPredictionItem(
          id: id, prompt: prompt, difficulty: diff, explanation: exp,
          code: _str(j['code']), lang: _str(j['lang'], 'html'),
          options: _strList(j['options']),
          correctIndex: _int(j['correctIndex'], 0),
        );
      case 'findBug':
        return FindBugItem(
          id: id, prompt: prompt, difficulty: diff, explanation: exp,
          code: _str(j['code']), lang: _str(j['lang'], 'html'),
          options: _strList(j['options']),
          correctIndex: _int(j['correctIndex'], 0),
        );
      case 'fillBlank':
        return FillBlankItem(
          id: id, prompt: prompt, difficulty: diff, explanation: exp,
          acceptedAnswers: _strList(j['acceptedAnswers']),
          hint: _strOrNull(j['hint']),
        );
      case 'completeCode':
        return CompleteCodeItem(
          id: id, prompt: prompt, difficulty: diff, explanation: exp,
          stub: _str(j['stub']), lang: _str(j['lang'], 'html'),
          acceptedAnswers: _strList(j['acceptedAnswers']),
        );
      default:
        return null;
    }
  }
}

// ── Selection-graded types ──
class McqItem extends QuizItem {
  final List<String> options;
  final int correctIndex;
  const McqItem({
    required super.id, required super.prompt, required super.difficulty,
    required super.explanation, required this.options, required this.correctIndex,
  });
}

class MultiSelectItem extends QuizItem {
  final List<String> options;
  final Set<int> correctIndices;
  const MultiSelectItem({
    required super.id, required super.prompt, required super.difficulty,
    required super.explanation, required this.options, required this.correctIndices,
  });
}

class OutputPredictionItem extends QuizItem {
  final String code;
  final String lang;
  final List<String> options;
  final int correctIndex;
  const OutputPredictionItem({
    required super.id, required super.prompt, required super.difficulty,
    required super.explanation, required this.code, required this.lang,
    required this.options, required this.correctIndex,
  });
}

class FindBugItem extends QuizItem {
  final String code;
  final String lang;
  final List<String> options;
  final int correctIndex;
  const FindBugItem({
    required super.id, required super.prompt, required super.difficulty,
    required super.explanation, required this.code, required this.lang,
    required this.options, required this.correctIndex,
  });
}

// ── Text-graded types ──
class FillBlankItem extends QuizItem {
  final List<String> acceptedAnswers;
  final String? hint;
  const FillBlankItem({
    required super.id, required super.prompt, required super.difficulty,
    required super.explanation, required this.acceptedAnswers, this.hint,
  });
}

class CompleteCodeItem extends QuizItem {
  final String stub;
  final String lang;
  final List<String> acceptedAnswers;
  const CompleteCodeItem({
    required super.id, required super.prompt, required super.difficulty,
    required super.explanation, required this.stub, required this.lang,
    required this.acceptedAnswers,
  });
}

/// An ordered set of quiz items with a title.
class QuizSet {
  final String title;
  final List<QuizItem> items;
  const QuizSet({required this.title, required this.items});

  factory QuizSet.fromJson(Map<String, dynamic> j) => QuizSet(
        title: _str(j['title'], 'Practice quiz'),
        items: (j['items'] is List)
            ? (j['items'] as List)
                .whereType<Map>()
                .map((e) => QuizItem.tryParse(e.cast<String, dynamic>()))
                .whereType<QuizItem>()
                .toList()
            : const [],
      );

  bool get isEmpty => items.isEmpty;
}

/// A user's in-progress answer to the current item.
class QuizAnswer {
  int? selectedIndex; // selection (single)
  Set<int> selectedSet = {}; // selection (multi)
  String text = ''; // text types

  bool get isEmpty =>
      selectedIndex == null && selectedSet.isEmpty && text.trim().isEmpty;
}

// ── null-safe coercers ──
String _str(Object? v, [String fallback = '']) => v is String ? v : fallback;
String? _strOrNull(Object? v) => v is String && v.isNotEmpty ? v : null;
int _int(Object? v, int fallback) => v is int ? v : fallback;
List<String> _strList(Object? v) =>
    v is List ? v.whereType<String>().toList() : const [];
List<int> _intList(Object? v) =>
    v is List ? v.whereType<int>().toList() : const [];
