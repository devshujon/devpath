import 'package:devpath/features/code_editor/models/editor_file_type.dart';
import 'package:devpath/features/code_editor/services/code_editor_storage.dart';
import 'package:devpath/features/code_editor/utils/workspace_preview_assets.dart';
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
  });

  test('duplicate basenames pick most recently updated', () async {
    final storage = CodeEditorStorage.instance;
    final older = await storage.createFile(
      fileName: 'style.css',
      kind: EditorFileKind.css,
      content: 'body { color: red; }',
    );
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await storage.createFile(
      fileName: 'style.css',
      kind: EditorFileKind.css,
      content: 'body { color: blue; }',
    );

    final assets = await WorkspacePreviewAssets.load(storage: storage);
    expect(assets.ambiguousBasenames, contains('style.css'));
    expect(assets.byBasename['style.css'], contains('blue'));
    expect(assets.byBasename['style.css'], isNot(contains('red')));

    // Ensure older file still exists independently.
    expect(await storage.readContent(older.id), isNotNull);
  });
}
