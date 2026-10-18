import 'package:devpath/features/editor/utils/python_readonly_preview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('python preview documents are non-executable and escape HTML', () {
    final html = pythonReadonlyPreviewHtml("print('<script>')\n");
    expect(html, contains('read-only'));
    expect(html, contains('JavaScript only'));
    expect(html, contains('&lt;script&gt;'));
    expect(html, contains("print('&lt;script&gt;')"));
  });
}
