import 'package:devpath/features/editor/utils/playground_preview_document.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildPlaygroundPreviewDocument wraps fragments', () {
    final doc = buildPlaygroundPreviewDocument(
      html: '<p>Hi</p>',
      css: 'p{color:red}',
      js: 'console.log(1)',
    );
    expect(doc, contains('<p>Hi</p>'));
    expect(doc, contains('<style>p{color:red}</style>'));
    expect(doc, contains('<script>console.log(1)</script>'));
  });

  test('buildPlaygroundPreviewDocument escapes script close in user js', () {
    final doc = buildPlaygroundPreviewDocument(
      html: '',
      css: '',
      js: "var s='</script>';",
    );
    expect(doc, contains(r'<\/script>'));
  });
}
