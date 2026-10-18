import 'dart:io';

import 'package:devpath/features/code_editor/models/editor_file_type.dart';
import 'package:devpath/features/code_editor/providers/code_editor_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    installFakePathProvider();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final dir = Directory('/tmp/devpath_test_docs/code_workspace');
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('create HTML, edit, save, dirty flag, preview document', () async {
    final provider = CodeEditorProvider();
    await provider.load();

    await provider.createNew(EditorFileKind.html);
    expect(provider.hasOpenFile, isTrue);
    expect(provider.isDirty, isFalse);

    provider.updateContent('<html><body>Hello</body></html>');
    expect(provider.isDirty, isTrue);

    expect(await provider.save(), isTrue);
    expect(provider.isDirty, isFalse);

    final preview = await provider.buildPreviewHtml();
    expect(preview, contains('Hello'));
  });

  test('rename and unsaved persistence after save', () async {
    final provider = CodeEditorProvider();
    await provider.load();
    await provider.createNew(EditorFileKind.css);
    provider.updateContent('body { margin: 0; }');
    await provider.save();

    final err = await provider.renameOpenFile('main.css');
    expect(err, isNull);
    expect(provider.openFile?.displayName, 'main.css');
  });
}
