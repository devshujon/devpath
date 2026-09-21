import 'package:hive/hive.dart';

import '../../../core/constants/hive_boxes.dart';

part 'unlock_timer.g.dart';

@HiveType(typeId: HiveTypeIds.unlockTimer)
class UnlockTimer extends HiveObject {
  @HiveField(0) String lessonId;
  @HiveField(1) DateTime expiresAt;

  UnlockTimer({required this.lessonId, required this.expiresAt});

  bool get isActive => DateTime.now().isBefore(expiresAt);
  Duration get remaining =>
      isActive ? expiresAt.difference(DateTime.now()) : Duration.zero;
}
