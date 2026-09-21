import 'dart:convert';
import 'dart:io';

import 'package:devpath/features/curriculum/models/lesson_block.dart';
import 'package:devpath/features/curriculum/models/lesson_content.dart';
import 'package:devpath/features/curriculum/services/curriculum_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LessonContent.fromJson', () {
    test('parses optional fields and accepts blocks alias', () {
      final content = LessonContent.fromJson({
        'schemaVersion': 2,
        'id': 'demo',
        'title': 'Demo',
        'summary': 'A short summary',
        'estimatedMinutes': 8,
        'difficulty': 'beginner',
        'objectives': ['One', 'Two'],
        'blocks': [
          {'type': 'prose', 'md': 'Hello'},
        ],
        'quickRecap': ['Remember this'],
        'exercise': {
          'prompt': 'Try it',
          'starterCode': {'html': '<h1>Hi</h1>', 'css': '', 'js': ''},
          'checks': ['h1'],
        },
        'project': {
          'title': 'Mini',
          'brief': 'Build it',
          'starterCode': {'html': '<p>x</p>'},
        },
      });

      expect(content.id, 'demo');
      expect(content.title, 'Demo');
      expect(content.summary, 'A short summary');
      expect(content.estimatedMinutes, 8);
      expect(content.objectives, ['One', 'Two']);
      expect(content.content, hasLength(1));
      expect(content.content.first, isA<ProseBlock>());
      expect(content.quickRecap, ['Remember this']);
      expect(content.exercise, isNotNull);
      expect(content.projectPrompt?.title, 'Mini');
    });

    test('missing optional fields do not crash', () {
      final content = LessonContent.fromJson({
        'id': 'bare',
        'content': [
          {'type': 'heading', 'text': 'Hi', 'level': 2},
        ],
      });
      expect(content.id, 'bare');
      expect(content.objectives, isEmpty);
      expect(content.quickRecap, isEmpty);
      expect(content.exercise, isNull);
      expect(content.projectPrompt, isNull);
    });

    test('unknown blocks become UnknownBlock and are skipped in coreBlocks', () {
      final content = LessonContent.fromJson({
        'id': 'x',
        'content': [
          {'type': 'prose', 'md': 'Keep me'},
          {'type': 'brandNewFutureBlock', 'foo': 1},
          {'type': 'deepDive', 'title': 'Extra', 'children': []},
        ],
      });
      expect(content.content[1], isA<UnknownBlock>());
      expect((content.content[1] as UnknownBlock).type, 'brandNewFutureBlock');
      expect(content.coreBlocks, hasLength(1));
      expect(content.deepDiveBlocks, hasLength(1));
    });

    test('malformed payload returns null from parse helper', () {
      expect(parseLessonContentJson('not a map'), isNull);
      expect(parseLessonContentJson(['list']), isNull);
      expect(parseLessonContentJson({'id': 'empty', 'content': []}), isNull);
    });

    test('decodeAndParse handles bad JSON', () {
      expect(CurriculumLoader.decodeAndParse('{'), isNull);
      expect(CurriculumLoader.decodeAndParse('[]'), isNull);
    });
  });

  group('bundled curriculum JSON', () {
    final dir = Directory('assets/curriculum');

    test('every JSON file parses with known or unknown-safe blocks', () {
      expect(dir.existsSync(), isTrue);
      final files = dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();
      expect(files, isNotEmpty);

      for (final file in files) {
        final raw = file.readAsStringSync();
        final decoded = jsonDecode(raw);
        expect(decoded, isA<Map>(), reason: file.path);
        final content = LessonContent.fromJson(
          (decoded as Map).cast<String, dynamic>(),
        );
        expect(content.isEmpty, isFalse, reason: file.path);
        for (final block in content.content) {
          expect(block, isA<LessonBlock>(), reason: file.path);
        }
      }
    });

    test('h1_heading gold-standard file loads', () {
      final file = File('assets/curriculum/html/h1_heading.json');
      expect(file.existsSync(), isTrue);
      final content = CurriculumLoader.decodeAndParse(file.readAsStringSync());
      expect(content, isNotNull);
      expect(content!.id, 'h1_heading');
      expect(content.quickRecap, isNotEmpty);
      expect(content.exercise, isNotNull);
      expect(content.deepDiveBlocks, isNotEmpty);
      expect(content.coreBlocks, isNotEmpty);
    });

    test('b01_html fallback-compatible file still parses', () {
      final file = File('assets/curriculum/html/b01_html.json');
      final content = CurriculumLoader.decodeAndParse(file.readAsStringSync());
      expect(content, isNotNull);
      expect(content!.id, 'b01_html');
    });
  });
}
