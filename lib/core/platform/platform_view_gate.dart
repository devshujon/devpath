import 'package:flutter/foundation.dart';

/// Globally suspends Flutter [WebViewWidget] / platform views on Android
/// while full-screen routes (e.g. lesson quiz) are open.
class PlatformViewGate extends ChangeNotifier {
  PlatformViewGate._();
  static final PlatformViewGate instance = PlatformViewGate._();

  int _depth = 0;

  bool get isSuspended => _depth > 0;

  void suspend() {
    _depth++;
    notifyListeners();
  }

  void resume() {
    if (_depth <= 0) return;
    _depth--;
    notifyListeners();
  }

  /// Runs [action] while platform views are suspended.
  Future<T> runSuspended<T>(Future<T> Function() action) async {
    suspend();
    try {
      return await action();
    } finally {
      resume();
    }
  }
}
