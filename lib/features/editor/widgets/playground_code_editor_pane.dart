import 'package:flutter/material.dart';

import '../../../core/platform/android_webview_policy.dart';
import '../../code_editor/models/editor_file_type.dart';
import '../providers/playground_provider.dart';
import 'codemirror_editor_pane.dart';
import 'syntax_highlighted_editor.dart';

/// Playground editor: CodeMirror WebView on iOS/desktop; [SyntaxHighlightedEditor] on Android.
class PlaygroundCodeEditorPane extends StatelessWidget {
  final PlaygroundTab tab;
  final String initialText;
  final ValueChanged<String> onChanged;
  final Object resetKey;
  final double fontSize;
  final bool wordWrap;
  final bool showLineNumbers;
  final bool preferDarkSurface;

  const PlaygroundCodeEditorPane({
    super.key,
    required this.tab,
    required this.initialText,
    required this.onChanged,
    required this.resetKey,
    this.fontSize = 13,
    this.wordWrap = false,
    this.showLineNumbers = true,
    this.preferDarkSurface = true,
  });

  EditorFileKind get _kind => switch (tab) {
        PlaygroundTab.html => EditorFileKind.html,
        PlaygroundTab.css => EditorFileKind.css,
        PlaygroundTab.js => EditorFileKind.javascript,
      };

  @override
  Widget build(BuildContext context) {
    if (useCodemirrorWebViewOnAndroid) {
      return CodemirrorEditorPane(
        documentKey: resetKey.toString(),
        fileKind: _kind,
        initialText: initialText,
        onChanged: onChanged,
        fontSize: fontSize,
        wordWrap: wordWrap,
        showLineNumbers: showLineNumbers,
        preferDarkSurface: preferDarkSurface,
      );
    }
    return SyntaxHighlightedEditor(
      initialText: initialText,
      onChanged: onChanged,
      resetKey: resetKey,
      tab: tab,
      fontSize: fontSize,
      wordWrap: wordWrap,
      showLineNumbers: showLineNumbers,
      preferDarkSurface: preferDarkSurface,
    );
  }
}
