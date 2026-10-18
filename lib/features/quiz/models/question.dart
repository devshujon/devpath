import 'package:hive/hive.dart';

import '../../../core/constants/hive_boxes.dart';

part 'question.g.dart';

@HiveType(typeId: HiveTypeIds.question)
class Question extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String subject;     // 'HTML', 'CSS', 'JavaScript', 'PHP'
  @HiveField(2) String level;       // 'beginner', 'intermediate', 'advanced'
  @HiveField(3) String question;
  @HiveField(4) List<String> options;
  @HiveField(5) int correctIndex;
  @HiveField(6) String? explanation;

  Question({
    required this.id,
    required this.subject,
    required this.level,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> j) {
    final opts = List<String>.from(j['options'] as List);
    final correctIndex = j['correctIndex'] as int;

    // Runtime guard: reject malformed questions at parse time.
    final trimmed = opts.map((o) => o.trim().toLowerCase()).toList();
    if (trimmed.toSet().length != trimmed.length) {
      throw FormatException(
        'Question "${j['id']}" has duplicate options: $opts',
      );
    }
    if (correctIndex < 0 || correctIndex >= opts.length) {
      throw FormatException(
        'Question "${j['id']}" correctIndex $correctIndex out of bounds '
        '(${opts.length} options)',
      );
    }

    return Question(
      id: j['id'] as String,
      subject: j['subject'] as String,
      level: j['level'] as String? ?? 'beginner',
      question: j['question'] as String,
      options: opts,
      correctIndex: correctIndex,
      explanation: j['explanation'] as String?,
    );
  }
}
