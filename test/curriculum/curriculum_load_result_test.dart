import 'package:devpath/features/curriculum/models/curriculum_load_result.dart';
import 'package:devpath/features/curriculum/models/lesson_block.dart';
import 'package:devpath/features/curriculum/models/lesson_content.dart';
import 'package:devpath/features/curriculum/services/curriculum_cache.dart';
import 'package:devpath/features/curriculum/services/curriculum_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurriculumLoadResult', () {
    test('missing files do not show a failure banner', () {
      expect(const CurriculumLoadResult.missing().showFailureBanner, isFalse);
      expect(const CurriculumLoadResult.missing().hasContent, isFalse);
    });

    test('parse failures show a banner and still have no content', () {
      expect(const CurriculumLoadResult.failed().showFailureBanner, isTrue);
      expect(const CurriculumLoadResult.failed().hasContent, isFalse);
    });

    test('a loaded lesson never shows the failure banner', () {
      const content = LessonContent(
        schemaVersion: 1,
        id: 'demo',
        content: [ProseBlock(md: 'Hello')],
      );
          const result = CurriculumLoadResult.loaded(content);
      expect(result.showFailureBanner, isFalse);
      expect(result.hasContent, isTrue);
    });
  });

  test('cache remembers missing vs failed so a lesson is looked up once', () {
    final cache = CurriculumCache();
    cache.put('a', const CurriculumLoadResult.missing());
    cache.put('b', const CurriculumLoadResult.failed());
    expect(cache.get('a')!.kind, CurriculumLoadKind.missing);
    expect(cache.get('b')!.kind, CurriculumLoadKind.failed);
    expect(cache.contains('a'), isTrue);
  });

  test('empty or invalid JSON maps to a failed parse, not a loaded lesson', () {
    expect(CurriculumLoader.decodeAndParse('{}'), isNull);
    expect(CurriculumLoader.decodeAndParse('{"id":"x","content":[]}'), isNull);
    expect(
      CurriculumLoader.decodeAndParse(
        '{"id":"x","content":[{"type":"brandNewFutureBlock"}]}',
      ),
      isNull,
    );
  });
}
