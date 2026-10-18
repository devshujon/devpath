import 'package:devpath/features/curriculum/widgets/figure_android_fallback.dart';
import 'package:devpath/features/curriculum/widgets/figure_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  test('figureSpecToPlainText decodes basic HTML figure', () {
    const spec =
        '<div>&lt;h1&gt; Page title</div><div>&lt;h2&gt; Section</div>';
    final plain = figureSpecToPlainText(spec);
    expect(plain, contains('<h1>'));
    expect(plain, contains('Page title'));
  });

  testWidgets('Android uses Flutter figure renderer without WebView',
      (tester) async {
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FigureHtmlView(
            spec: '<div>&lt;h1&gt; Title</div>',
            height: 120,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WebViewWidget), findsNothing);
    expect(find.textContaining('Title'), findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
  });
}
