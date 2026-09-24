import 'package:hive/hive.dart';

import '../../../core/constants/hive_boxes.dart';

part 'lesson.g.dart';

@HiveType(typeId: HiveTypeIds.lesson)
class Lesson extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String module;          // 'HTML', 'CSS', 'JavaScript', 'PHP'
  @HiveField(2) String level;           // 'beginner', 'intermediate', 'advanced'
  @HiveField(3) int order;
  @HiveField(4) String title;
  @HiveField(5) String summary;
  @HiveField(6) String explanation;
  @HiveField(7) String codeExample;
  @HiveField(8) List<String> keyPoints;
  @HiveField(9) Map<String, String> starterFiles;

  Lesson({
    required this.id,
    required this.module,
    required this.level,
    required this.order,
    required this.title,
    required this.summary,
    required this.explanation,
    required this.codeExample,
    required this.keyPoints,
    required this.starterFiles,
  });

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
        id: j['id'] as String,
        module: j['module'] as String,
        level: j['level'] as String? ?? 'beginner',
        order: j['order'] as int,
        title: j['title'] as String,
        summary: j['summary'] as String? ?? '',
        explanation: j['explanation'] as String? ?? '',
        codeExample: j['codeExample'] as String? ?? '',
        keyPoints: List<String>.from(j['keyPoints'] as List? ?? []),
        starterFiles: Map<String, String>.from(j['starterFiles'] as Map? ?? {}),
      );
}
