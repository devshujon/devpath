import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/xml.dart';

import '../providers/playground_provider.dart';
import '../utils/editor_undo_stack.dart';
import '../utils/playground_code_themes.dart';
import 'editor_accessory_toolbar.dart';
import 'editor_find_replace_sheet.dart';

/// Mobile-safe code editor (no WebView) with highlight via [CodeField].
class SyntaxHighlightedEditor extends StatefulWidget {
  final String initialText;
  final ValueChanged<String> onChanged;
  final Object resetKey;
  final PlaygroundTab tab;
  final double fontSize;
  final bool wordWrap;
  final bool showLineNumbers;
  final bool preferDarkSurface;

  const SyntaxHighlightedEditor({
    super.key,
    required this.initialText,
    required this.onChanged,
    required this.resetKey,
    required this.tab,
    this.fontSize = 13,
    this.wordWrap = false,
    this.showLineNumbers = true,
    this.preferDarkSurface = true,
  });

  @override
  State<SyntaxHighlightedEditor> createState() =>
      _SyntaxHighlightedEditorState();
}

class _SyntaxHighlightedEditorState extends State<SyntaxHighlightedEditor> {
  late CodeController _controller;
  final EditorUndoStack _undo = EditorUndoStack();
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _controller = _buildController(widget.initialText);
    _undo.reset(widget.initialText);
    _controller.addListener(_onTextChanged);
  }

  CodeController _buildController(String text) {
    return CodeController(
      text: text,
      language: _languageFor(widget.tab),
    );
  }

  Mode _languageFor(PlaygroundTab tab) => switch (tab) {
        PlaygroundTab.html => xml,
        PlaygroundTab.css => css,
        PlaygroundTab.js => javascript,
      };

  void _onTextChanged() {
    if (_syncing) return;
    _undo.record(_controller.text);
    widget.onChanged(_controller.text);
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant SyntaxHighlightedEditor old) {
    super.didUpdateWidget(old);
    if (old.resetKey != widget.resetKey || old.tab != widget.tab) {
      _controller.removeListener(_onTextChanged);
      _controller.dispose();
      _controller = _buildController(widget.initialText);
      _undo.reset(widget.initialText);
      _controller.addListener(_onTextChanged);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _applyText(String text, {int? cursor}) {
    _syncing = true;
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(
      offset: cursor ?? text.length,
    );
    _syncing = false;
    _undo.record(text, forceCheckpoint: true);
    widget.onChanged(text);
    setState(() {});
  }

  void _undoAction() {
    final prev = _undo.undo();
    if (prev != null) _applyText(prev);
  }

  void _redoAction() {
    final next = _undo.redo();
    if (next != null) _applyText(next);
  }

  void _selectAll() {
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  Future<void> _copyAll() async {
    await Clipboard.setData(ClipboardData(text: _controller.text));
  }

  void _insertSymbol(String symbol) {
    final sel = _controller.selection;
    final text = _controller.text;
    final next = text.replaceRange(sel.start, sel.end, symbol);
    _applyText(next, cursor: sel.start + symbol.length);
  }

  Future<void> _openFindReplace() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => EditorFindReplaceSheet(
        source: _controller.text,
        onApply: (updated, cursor) => _applyText(updated, cursor: cursor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.preferDarkSurface ||
        Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F8FA);

    final baseStyle = TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Menlo', 'Courier'],
      fontSize: widget.fontSize,
      height: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditorAccessoryToolbar(
          tab: widget.tab,
          canUndo: _undo.canUndo,
          canRedo: _undo.canRedo,
          onUndo: _undoAction,
          onRedo: _redoAction,
          onSelectAll: _selectAll,
          onCopy: _copyAll,
          onFindReplace: _openFindReplace,
          onInsert: _insertSymbol,
        ),
        Expanded(
          child: Container(
            color: bg,
            child: CodeTheme(
              data: playgroundCodeTheme(isDark: isDark),
              child: CodeField(
                controller: _controller,
                expands: true,
                wrap: widget.wordWrap,
                lineNumberStyle: widget.showLineNumbers
                    ? LineNumberStyle(
                        textStyle: baseStyle.copyWith(
                          color: isDark
                              ? const Color(0xFF6E7681)
                              : const Color(0xFF8A929D),
                          fontSize: widget.fontSize - 1,
                        ),
                        width: 40,
                      )
                    : const LineNumberStyle(width: 0),
                textStyle: baseStyle,
                cursorColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
