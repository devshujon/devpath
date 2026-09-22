import 'dart:io';

import 'package:devpath/features/code_editor/models/editor_file_type.dart';
import 'package:devpath/features/code_editor/services/code_editor_storage.dart';
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

  test('create, read, update, delete workspace file', () async {
    final storage = CodeEditorStorage.instance;
    final entry = await storage.createFile(
      fileName: 'index.html',
      kind: EditorFileKind.html,
      content: '<html></html>',
    );

    expect(entry.displayName, 'index.html');

    final body = await storage.readContent(entry.id);
    expect(body, '<html></html>');

    final updated = await storage.updateFile(
      fileId: entry.id,
      content: '<html><body>v2</body></html>',
      fileName: 'page.html',
    );
    expect(updated?.displayName, 'page.html');

    final index = await storage.loadIndex();
    expect(index.length, 1);
    expect(index.first.displayName, 'page.html');

    final map = await storage.allBodiesByBaseName();
    expect(map['page.html'], contains('v2'));

    expect(await storage.deleteFile(entry.id), isTrue);
    expect((await storage.loadIndex()).isEmpty, isTrue);
    expect(await storage.readContent(entry.id), isNull);
  });
}
