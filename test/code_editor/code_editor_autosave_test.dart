import 'package:devpath/features/code_editor/models/editor_file_type.dart';
import 'package:devpath/features/code_editor/providers/code_editor_provider.dart';
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
  });

  test('auto-save debounces disk writes', () async {
    final provider = CodeEditorProvider();
    await provider.load();
    await provider.createNew(EditorFileKind.html);
    final id = provider.openFile!.id;

    var notifyCount = 0;
    provider.addListener(() => notifyCount++);

    provider.updateContent('<html>a</html>');
    provider.updateContent('<html>ab</html>');
    provider.updateContent('<html>abc</html>');

    expect(notifyCount, lessThanOrEqualTo(1));

    await Future<void>.delayed(const Duration(milliseconds: 900));

    final onDisk = await CodeEditorStorage.instance.readContent(id);
    expect(onDisk, '<html>abc</html>');
    expect(provider.isDirty, isFalse);
  });
}
