import 'lesson_content.dart';

/// Distinguishes "no JSON yet" from "JSON exists but failed to parse".
enum CurriculumLoadKind { loaded, missing, failed }

class CurriculumLoadResult {
  final CurriculumLoadKind kind;
  final LessonContent? content;

  const CurriculumLoadResult._(this.kind, this.content);

  const CurriculumLoadResult.loaded(LessonContent content)
      : this._(CurriculumLoadKind.loaded, content);

  const CurriculumLoadResult.missing()
      : this._(CurriculumLoadKind.missing, null);

  const CurriculumLoadResult.failed()
      : this._(CurriculumLoadKind.failed, null);

  bool get hasContent => content != null;
  bool get showFailureBanner => kind == CurriculumLoadKind.failed;
}
