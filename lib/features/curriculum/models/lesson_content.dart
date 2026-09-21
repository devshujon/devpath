import 'lesson_block.dart';

/// The rich, JSON-authored content for one lesson.
///
/// This is intentionally SEPARATE from the `Lesson` model in
/// features/learning/models/lesson.dart. `Lesson` (and its const
/// catalog) supplies metadata + quiz and is never touched; this is
/// loaded lazily from assets/curriculum/<track>/<id>.json and merged
/// in at the screen level only when a file exists. Lessons without a
/// JSON file simply have no LessonContent and fall back to the
/// existing simple layout.
///
/// Schema is backward compatible:
/// - `content` **or** `blocks` supplies the block list
/// - optional fields (`summary`, `objectives`, `quickRecap`, …)
///   default to empty when missing
/// - unknown block types become [UnknownBlock] and are skipped
class LessonContent {
  final int schemaVersion;
  final String id;
  final String? title;
  final String? summary;
  final int? estimatedMinutes;
  final String? difficulty;
  final List<String> objectives;
  final List<LessonBlock> content;
  final List<String> quickRecap;
  final ExerciseBlock? exercise;
  final ProjectPrompt? projectPrompt;
  final List<Map<String, dynamic>> quizMetadata;

  const LessonContent({
    required this.schemaVersion,
    required this.id,
    this.title,
    this.summary,
    this.estimatedMinutes,
    this.difficulty,
    this.objectives = const [],
    required this.content,
    this.quickRecap = const [],
    this.exercise,
    this.projectPrompt,
    this.quizMetadata = const [],
  });

  factory LessonContent.fromJson(Map<String, dynamic> j) {
    final rawBlocks = j['content'] ?? j['blocks'];
    final blocks = (rawBlocks is List)
        ? rawBlocks
            .whereType<Map>()
            .map((e) => LessonBlock.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <LessonBlock>[];

    ProjectPrompt? project;
    final p = j['projectPrompt'] ?? j['project'];
    if (p is Map) project = ProjectPrompt.fromJson(p.cast<String, dynamic>());

    ExerciseBlock? exercise;
    final e = j['exercise'];
    if (e is Map) {
      final parsed = LessonBlock.fromJson({
        ...e.cast<String, dynamic>(),
        'type': 'exercise',
      });
      if (parsed is ExerciseBlock) exercise = parsed;
    }

    return LessonContent(
      schemaVersion: _asInt(j['schemaVersion'], 1),
      id: j['id'] is String ? j['id'] as String : '',
      title: j['title'] is String ? j['title'] as String : null,
      summary: j['summary'] is String ? j['summary'] as String : null,
      estimatedMinutes: j['estimatedMinutes'] is num
          ? (j['estimatedMinutes'] as num).toInt()
          : null,
      difficulty: j['difficulty'] is String ? j['difficulty'] as String : null,
      objectives: _stringList(j['objectives']),
      content: blocks,
      quickRecap: _stringList(j['quickRecap']),
      exercise: exercise,
      projectPrompt: project,
      quizMetadata: (j['quiz'] is List)
          ? (j['quiz'] as List)
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList()
          : const [],
    );
  }

  bool get isEmpty =>
      content.isEmpty &&
      quickRecap.isEmpty &&
      exercise == null &&
      projectPrompt == null;

  /// Core (always-visible) blocks. Deep-dive wrappers are excluded.
  List<LessonBlock> get coreBlocks => content
      .where((b) => b is! DeepDiveBlock && b is! UnknownBlock && !_isDeepSection(b))
      .toList();

  List<DeepDiveBlock> get deepDiveBlocks => [
        for (final b in content)
          if (b is DeepDiveBlock) b,
        for (final b in content)
          if (b is SectionBlock && b.tier == SectionTier.deep)
            DeepDiveBlock(title: b.title, children: b.children),
      ];

  static bool _isDeepSection(LessonBlock b) =>
      b is SectionBlock && b.tier == SectionTier.deep;

  static List<String> _stringList(Object? v) =>
      v is List ? v.whereType<String>().where((s) => s.isNotEmpty).toList() : const [];

  static int _asInt(Object? v, int fallback) =>
      v is num ? v.toInt() : fallback;
}

class ProjectPrompt {
  final String title;
  final String brief;
  final Map<String, String> starterCode;

  const ProjectPrompt({
    required this.title,
    required this.brief,
    required this.starterCode,
  });

  factory ProjectPrompt.fromJson(Map<String, dynamic> j) => ProjectPrompt(
        title: j['title'] is String ? j['title'] as String : 'Mini project',
        brief: j['brief'] is String ? j['brief'] as String : '',
        starterCode: (j['starterCode'] is Map)
            ? (j['starterCode'] as Map).map(
                (k, v) => MapEntry('$k', v is String ? v : '$v'),
              )
            : const {},
      );
}

/// Parses bundled / test JSON into [LessonContent].
///
/// Returns null when the payload is not a map, or when the parsed
/// lesson has no usable content. Never throws for unknown blocks or
/// missing optional fields.
LessonContent? parseLessonContentJson(Object? decoded) {
  if (decoded is! Map) return null;
  try {
    final content = LessonContent.fromJson(decoded.cast<String, dynamic>());
    return content.isEmpty ? null : content;
  } catch (_) {
    return null;
  }
}
