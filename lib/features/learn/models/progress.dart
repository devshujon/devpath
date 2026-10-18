import 'package:hive/hive.dart';

import '../../../core/constants/hive_boxes.dart';

part 'progress.g.dart';

@HiveType(typeId: HiveTypeIds.progress)
class Progress extends HiveObject {
  @HiveField(0) String lessonId;
  @HiveField(1) bool completed;
  @HiveField(2) DateTime? completedAt;
  @HiveField(3) int timesOpened;
  @HiveField(4) int? quizScore;
  @HiveField(5) bool unlockedByReward;

  Progress({
    required this.lessonId,
    this.completed = false,
    this.completedAt,
    this.timesOpened = 0,
    this.quizScore,
    this.unlockedByReward = false,
  });
}
