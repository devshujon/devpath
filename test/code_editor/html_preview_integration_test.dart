import 'package:devpath/features/code_editor/models/editor_file_type.dart';
import 'package:devpath/features/code_editor/services/code_editor_storage.dart';
import 'package:devpath/features/code_editor/utils/html_preview_builder.dart';
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

  test('index.html + style.css + script.js preview inlines workspace files', () async {
    final storage = CodeEditorStorage.instance;
    await storage.createFile(
      fileName: 'style.css',
      kind: EditorFileKind.css,
      content: 'h1 { color: green; }',
    );
    await storage.createFile(
      fileName: 'script.js',
      kind: EditorFileKind.javascript,
      content: 'document.body.dataset.ok = "1";',
    );
    final htmlFile = await storage.createFile(
      fileName: 'index.html',
      kind: EditorFileKind.html,
      content: '''<!DOCTYPE html>
<html><head>
<link rel="stylesheet" href="style.css">
</head><body>
<h1>Hi</h1>
<script src="script.js"></script>
</body></html>''',
    );

    const edited = '''<!DOCTYPE html>
<html><head>
<link rel="stylesheet" href="style.css">
</head><body>
<h1>Edited</h1>
<script src="script.js"></script>
</body></html>''';

    final assets = await WorkspacePreviewAssets.load(
      storage: storage,
      liveFileId: htmlFile.id,
      liveContent: edited,
    );

    final preview = HtmlPreviewBuilder.build(
      htmlSource: edited,
      workspaceFilesByLowerName: assets.byBasename,
      ambiguousBasenames: assets.ambiguousBasenames,
    );

    expect(preview, contains('color: green'));
    expect(preview, contains('dataset.ok'));
    expect(preview, contains('Edited'));
    expect(preview, isNot(contains('https://')));
  });
}
