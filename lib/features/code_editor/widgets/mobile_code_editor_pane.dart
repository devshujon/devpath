import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/platform/android_webview_policy.dart';
import '../providers/code_editor_provider.dart';
import '../../editor/widgets/code_editor_pane.dart';
import '../../editor/widgets/codemirror_editor_pane.dart';
import '../models/editor_file_type.dart';

/// Mobile code editor: WebView CodeMirror on iOS/desktop web; plain TextField
/// on Android to avoid platform-view ghost layers over the lesson quiz.
class MobileCodeEditorPane extends StatefulWidget {
  final String documentKey;
  final EditorFileKind fileKind;
  final String initialText;
  final ValueChanged<String> onChanged;
  final double fontSize;
  final bool wordWrap;
  final bool showLineNumbers;
  final bool preferDarkSurface;

  const MobileCodeEditorPane({
    super.key,
    required this.documentKey,
    required this.fileKind,
    required this.initialText,
    required this.onChanged,
    this.fontSize = 13,
    this.wordWrap = false,
    this.showLineNumbers = true,
    this.preferDarkSurface = true,
  });

  @override
  State<MobileCodeEditorPane> createState() => MobileCodeEditorPaneState();
}

class MobileCodeEditorPaneState extends State<MobileCodeEditorPane> {
  final GlobalKey<CodemirrorEditorPaneState> _codemirrorKey =
      GlobalKey<CodemirrorEditorPaneState>();

  Future<String> flushAndGetCode() async {
    if (useCodemirrorWebViewOnAndroid) {
      return _codemirrorKey.currentState?.flushAndGetCode() ??
          widget.initialText;
    }
    return context.read<CodeEditorProvider>().content;
  }

  @override
  Widget build(BuildContext context) {
    if (useCodemirrorWebViewOnAndroid) {
      return CodemirrorEditorPane(
        key: _codemirrorKey,
        documentKey: widget.documentKey,
        fileKind: widget.fileKind,
        initialText: widget.initialText,
        onChanged: widget.onChanged,
        fontSize: widget.fontSize,
        wordWrap: widget.wordWrap,
        showLineNumbers: widget.showLineNumbers,
        preferDarkSurface: widget.preferDarkSurface,
      );
    }
    return CodeEditorPane(
      initialText: widget.initialText,
      onChanged: widget.onChanged,
      resetKey: widget.documentKey,
      fontSize: widget.fontSize,
      wordWrap: widget.wordWrap,
      showLineNumbers: widget.showLineNumbers,
      preferDarkSurface: widget.preferDarkSurface,
    );
  }
}
