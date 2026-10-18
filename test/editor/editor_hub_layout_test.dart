import 'package:devpath/features/editor/screens/editor_screen.dart';
import 'package:devpath/features/editor/providers/projects_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Editor hub shows playground, import, and templates', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => ProjectsListProvider(),
          child: const EditorScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Code Studio'), findsOneWidget);
    expect(find.text('Playground'), findsOneWidget);
    expect(find.text('Import HTML'), findsOneWidget);
    expect(find.text('Starter templates'), findsOneWidget);
    expect(find.text('Recent projects'), findsOneWidget);
  });
}
