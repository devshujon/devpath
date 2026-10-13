import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../debug/quiz_diagnostics.dart';

/// Best-effort native WebView teardown before routes that must sit above
/// platform views (lesson quiz on Android).
Future<void> detachWebViewController(WebViewController? controller) async {
  if (controller == null) return;
  if (kIsWeb) return;

  try {
    await controller.loadRequest(Uri.parse('about:blank'));
  } catch (e) {
    if (kDebugMode) {
      QuizDiagnostics.log('detachWebView load about:blank failed: $e');
    }
  }
}
