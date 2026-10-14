import 'package:webview_flutter/webview_flutter.dart';

import '../debug/quiz_diagnostics.dart';
import 'webview_detach.dart';

/// Tracks every [WebViewController] created in the app so quiz open can
/// detach native surfaces even after the owning widget was disposed.
class ActiveWebViewTracker {
  ActiveWebViewTracker._();
  static final ActiveWebViewTracker instance = ActiveWebViewTracker._();

  final Set<WebViewController> _controllers = {};

  void track(WebViewController controller) {
    _controllers.add(controller);
  }

  void untrack(WebViewController controller) {
    _controllers.remove(controller);
  }

  Future<void> detachAll() async {
    if (_controllers.isEmpty) return;
    QuizDiagnostics.log(
      'ActiveWebViewTracker detachAll count=${_controllers.length}',
    );
    final copy = _controllers.toList(growable: false);
    for (final controller in copy) {
      await detachWebViewController(controller);
      _controllers.remove(controller);
    }
  }
}
