import 'package:devpath/features/editor/providers/playground_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('togglePaneView switches editor and preview', () {
    final p = PlaygroundProvider();
    expect(p.paneView, PlaygroundPaneView.editor);
    p.togglePaneView();
    expect(p.paneView, PlaygroundPaneView.preview);
    p.setPaneView(PlaygroundPaneView.editor);
    expect(p.paneView, PlaygroundPaneView.editor);
  });

  test('run commits drafts and bumps runVersion', () {
    final p = PlaygroundProvider();
    final v0 = p.runVersion;
    p.updateCurrent('<!-- edited -->');
    p.run();
    expect(p.runVersion, v0 + 1);
    expect(p.htmlCommitted, contains('edited'));
  });
}
