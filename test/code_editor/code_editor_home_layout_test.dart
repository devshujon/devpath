import 'package:devpath/features/code_editor/providers/code_editor_provider.dart';
import 'package:devpath/features/code_editor/screens/code_editor_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('empty workspace at 360dp width', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final provider = CodeEditorProvider();
    await provider.load();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: provider,
          child: const CodeEditorHomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Code Workspace'), findsOneWidget);
    expect(find.text('New file'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
