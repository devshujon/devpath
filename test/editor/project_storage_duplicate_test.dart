import 'package:devpath/features/editor/models/user_project.dart';
import 'package:devpath/features/editor/services/project_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('duplicateProject creates independent copy', () async {
    final storage = ProjectStorage.instance;
    final original = UserProject(
      id: 'orig-1',
      title: 'Original',
      htmlCode: '<p>A</p>',
      cssCode: 'p{}',
      jsCode: 'console.log(1)',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2),
    );
    await storage.saveProject(original);
    final copy = await storage.duplicateProject(original, title: 'Copy');

    expect(copy.id, isNot(original.id));
    expect(copy.htmlCode, original.htmlCode);
    expect(copy.title, 'Copy');

    copy.copyWith(htmlCode: '<p>B</p>');
    final reloaded = await storage.getProject(original.id);
    expect(reloaded!.htmlCode, '<p>A</p>');
  });
}
