import 'package:devpath/features/editor/logic/playground_preview_launcher.dart';
import 'package:devpath/features/editor/providers/playground_provider.dart';
import 'package:devpath/features/editor/utils/playground_preview_document.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preview document includes committed js/css/html after run', () {
    final p = PlaygroundProvider();
    p.updateCurrent('<p>Run me</p>');
    p.switchTab(PlaygroundTab.css);
    p.updateCurrent('p{color:green}');
    p.switchTab(PlaygroundTab.js);
    p.updateCurrent('document.title="ok"');
    p.switchTab(PlaygroundTab.html);
    p.run();

    final doc = PlaygroundPreviewLauncher.documentFor(p);
    expect(doc, contains('<p>Run me</p>'));
    expect(doc, contains('color:green'));
    expect(doc, contains('document.title'));
  });

  test('buildPlaygroundPreviewDocument escapes script injection', () {
    final doc = buildPlaygroundPreviewDocument(
      html: '',
      css: '',
      js: "bad='</script><script>alert(1)</script>';",
    );
    expect(doc, contains(r'<\/script>'));
  });
}
