import 'package:devpath/features/code_editor/utils/html_preview_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HtmlPreviewBuilder', () {
    test('inlines local CSS and JS by basename', () {
      const html = '''
<!DOCTYPE html>
<html><head>
<link rel="stylesheet" href="./style.css">
</head><body>
<h1>Hi</h1>
<script src="script.js"></script>
</body></html>''';

      final out = HtmlPreviewBuilder.build(
        htmlSource: html,
        workspaceFilesByLowerName: {
          'style.css': 'body { color: red; }',
          'script.js': 'document.title = "ok";',
        },
      );

      expect(out, contains('<style data-inlined-from="style.css">'));
      expect(out, contains('color: red'));
      expect(out, contains('<script data-inlined-from="script.js">'));
      expect(out, contains('document.title'));
      expect(out, isNot(contains('href="./style.css"')));
    });

    test('documents ambiguous basename inlining', () {
      const html =
          '<html><head><link rel="stylesheet" href="style.css"></head><body></body></html>';
      final out = HtmlPreviewBuilder.build(
        htmlSource: html,
        workspaceFilesByLowerName: {'style.css': 'body{color:blue}'},
        ambiguousBasenames: {'style.css'},
      );
      expect(out, contains('multiple files named style.css'));
    });

    test('skips remote assets with comment', () {
      const html =
          '<html><head><link rel="stylesheet" href="https://cdn/x.css"></head><body></body></html>';
      final out = HtmlPreviewBuilder.build(
        htmlSource: html,
        workspaceFilesByLowerName: {},
      );
      expect(out, contains('skipped remote CSS'));
    });

    test('wraps fragment in document shell', () {
      final out = HtmlPreviewBuilder.build(
        htmlSource: '<p>Hello</p>',
        workspaceFilesByLowerName: {},
      );
      expect(out.toLowerCase(), contains('<html'));
      expect(out, contains('<p>Hello</p>'));
    });
  });
}
