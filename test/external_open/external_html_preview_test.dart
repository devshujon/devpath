import 'package:devpath/features/external_open/models/external_file_kind.dart';
import 'package:devpath/features/external_open/utils/external_html_preview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('HTML preview adds missing-assets banner', () {
    final doc = buildExternalPreviewDocument(
      kind: ExternalFileKind.html,
      source: '<p>Hi</p>',
    );
    expect(doc, contains('Imported HTML preview'));
    expect(doc, contains('<p>Hi</p>'));
  });

  test('CSS preview explains limitation', () {
    final doc = buildExternalPreviewDocument(
      kind: ExternalFileKind.css,
      source: 'body { color: red; }',
    );
    expect(doc, contains('stylesheet only'));
    expect(doc, contains('color: red'));
  });

  test('JSON preview pretty-prints valid JSON', () {
    final doc = buildExternalPreviewDocument(
      kind: ExternalFileKind.json,
      source: '{"a":1}',
    );
    expect(doc, contains('"a"'));
    expect(doc, contains('1'));
  });
}
