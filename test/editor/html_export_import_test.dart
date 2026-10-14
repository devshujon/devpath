import 'package:devpath/features/editor/services/html_export_service.dart';
import 'package:devpath/features/editor/services/html_import_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('export builds combined html document', () {
    final r = HtmlExportService.buildExport(
      title: 'My Page',
      html: '<p>Hi</p>',
      css: 'p{color:red}',
      js: 'alert(1)',
    );
    expect(r.fileName, 'my-page.html');
    expect(r.htmlDocument, contains('<p>Hi</p>'));
    expect(r.htmlDocument, contains('<style>'));
    expect(r.htmlDocument, contains('<script>'));
  });

  test('export rejects oversized documents', () {
    expect(
      () => HtmlExportService.buildExport(
        title: 'big',
        html: 'x' * (HtmlExportService.maxExportBytes + 100),
        css: '',
        js: '',
      ),
      throwsA(isA<HtmlExportTooLargeException>()),
    );
  });

  test('import max size constant is documented', () {
    expect(HtmlImportService.maxImportBytes, greaterThan(0));
  });
}
