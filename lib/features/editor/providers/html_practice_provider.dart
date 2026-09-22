import 'package:flutter/foundation.dart';

/// Owns the practice screen's source code state.
///
/// `committedCode` is what the WebView renders. `draftCode` is what the
/// editor pane is showing. They desync when the user types — and re-sync
/// only when they tap Run. This keeps preview rendering predictable
/// and stops every keystroke from triggering a WebView reload.
class HtmlPracticeProvider extends ChangeNotifier {
  static const String defaultCode = '''<!DOCTYPE html>
<html>
<body>
<h1>Hello Dev</h1>
<p>Welcome to DevPath</p>
</body>
</html>''';

  String _draftCode = defaultCode;
  String _committedCode = defaultCode;
  int _runVersion = 0;

  String get draftCode => _draftCode;
  String get committedCode => _committedCode;

  /// Increments each time Run is pressed. Preview pane watches this
  /// to know when to reload, even if the code text is identical.
  int get runVersion => _runVersion;

  bool get hasUnsavedChanges => _draftCode != _committedCode;

  /// Called on every keystroke in the editor. Does NOT notify listeners —
  /// the editor pane manages its own text field state, so a rebuild
  /// would be wasted work.
  void updateDraft(String code) {
    _draftCode = code;
  }

  /// Commit draft to preview. The only call that should trigger a WebView reload.
  void run() {
    _committedCode = _draftCode;
    _runVersion++;
    notifyListeners();
  }

  void reset() {
    _draftCode = defaultCode;
    _committedCode = defaultCode;
    _runVersion++;
    notifyListeners();
  }

  void clear() {
    _draftCode = '';
    notifyListeners();
  }
}
