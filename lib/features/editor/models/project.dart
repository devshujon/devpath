import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/hive_boxes.dart';

part 'project.g.dart';

@HiveType(typeId: HiveTypeIds.project)
class Project extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) Map<String, String> files;
  @HiveField(3) DateTime createdAt;
  @HiveField(4) DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.files,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.blank({String name = 'Untitled'}) => Project(
        id: const Uuid().v4(),
        name: name,
        files: {
          'index.html': '<!DOCTYPE html>\n<html>\n<head>\n  <title>$name</title>\n</head>\n<body>\n  <h1>Hello, world</h1>\n</body>\n</html>',
          'style.css': 'body {\n  font-family: system-ui, sans-serif;\n  padding: 24px;\n}',
          'script.js': 'console.log("$name started");',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}
