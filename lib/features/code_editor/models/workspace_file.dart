import 'editor_file_type.dart';
import '../utils/file_type_registry.dart';

class WorkspaceFile {
  final String id;
  final String fileName;
  final EditorFileKind kind;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkspaceFile({
    required this.id,
    required this.fileName,
    required this.kind,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => EditorFileTypeRegistry.baseName(fileName);

  WorkspaceFile copyWith({
    String? fileName,
    EditorFileKind? kind,
    DateTime? updatedAt,
  }) {
    return WorkspaceFile(
      id: id,
      fileName: fileName ?? this.fileName,
      kind: kind ?? this.kind,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'kind': kind.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WorkspaceFile.fromJson(Map<String, dynamic> j) {
    return WorkspaceFile(
      id: j['id'] as String,
      fileName: j['fileName'] as String,
      kind: EditorFileKind.values.firstWhere(
        (k) => k.name == j['kind'],
        orElse: () => EditorFileKind.text,
      ),
      createdAt: DateTime.parse(j['createdAt'] as String),
      updatedAt: DateTime.parse(j['updatedAt'] as String),
    );
  }
}
