import 'package:hive/hive.dart';

import '../../../core/constants/hive_boxes.dart';

part 'quiz_attempt.g.dart';

@HiveType(typeId: HiveTypeIds.quizAttempt)
class QuizAttempt extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String subject;
  @HiveField(2) String level;
  @HiveField(3) int correct;
  @HiveField(4) int total;
  @HiveField(5) DateTime takenAt;

  QuizAttempt({
    required this.id,
    required this.subject,
    required this.level,
    required this.correct,
    required this.total,
    required this.takenAt,
  });

  bool get passed => total > 0 && (correct / total) >= 0.70;
  int get percent => total == 0 ? 0 : (100 * correct ~/ total);
}
