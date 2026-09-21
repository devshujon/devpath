import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Generic code editor pane. Driven by [initialText] + [onChanged] so it
/// can be reused for any provider/screen combination.
///
/// To change the displayed text from outside (e.g. when the parent
/// switches tabs), bump [resetKey] — the widget will reinitialize its
/// internal controller from the new initialText.
class CodeEditorPane extends StatefulWidget {
  final String initialText;
  final ValueChanged<String> onChanged;

  /// When this value changes, the editor reloads [initialText] into its
  /// controller (replacing whatever was being typed). Use a value that
  /// identifies the "current document" — e.g. the active tab enum or
  /// a generation counter.
  final Object resetKey;

  const CodeEditorPane({
    super.key,
    required this.initialText,
    required this.onChanged,
    required this.resetKey,
  });

  @override
  State<CodeEditorPane> createState() => _CodeEditorPaneState();
}

class _CodeEditorPaneState extends State<CodeEditorPane> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant CodeEditorPane old) {
    super.didUpdateWidget(old);
    // Parent signaled "the document changed" (e.g. tab switch).
    // Replace the controller's text so the editor shows the new tab.
    if (old.resetKey != widget.resetKey) {
      _controller.text = widget.initialText;
      _controller.selection = TextSelection.collapsed(
        offset: widget.initialText.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F8FA);
    final fg = isDark ? const Color(0xFFE6E6E6) : const Color(0xFF1A1A1A);
    final gutterBg = isDark ? const Color(0xFF252526) : const Color(0xFFEDEFF2);
    final gutterFg = isDark ? const Color(0xFF6E7681) : const Color(0xFF8A929D);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFE4E7EE),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LineNumbers(
            controller: _controller,
            background: gutterBg,
            foreground: gutterFg,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              textAlignVertical: TextAlignVertical.top,
              autocorrect: false,
              enableSuggestions: false,
              smartDashesType: SmartDashesType.disabled,
              smartQuotesType: SmartQuotesType.disabled,
              style: TextStyle(
                color: fg,
                fontFamily: 'monospace',
                fontFamilyFallback: const ['Menlo', 'Courier'],
                fontSize: 13,
                height: 1.5,
              ),
              cursorColor: Theme.of(context).colorScheme.primary,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(8, 12, 12, 12),
                border: InputBorder.none,
                isCollapsed: true,
              ),
              inputFormatters: const [_TabIndentFormatter()],
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineNumbers extends StatefulWidget {
  final TextEditingController controller;
  final Color background;
  final Color foreground;

  const _LineNumbers({
    required this.controller,
    required this.background,
    required this.foreground,
  });

  @override
  State<_LineNumbers> createState() => _LineNumbersState();
}

class _LineNumbersState extends State<_LineNumbers> {
  int _lineCount = 1;

  @override
  void initState() {
    super.initState();
    _lineCount = _countLines(widget.controller.text);
    widget.controller.addListener(_onChange);
  }

  @override
  void didUpdateWidget(covariant _LineNumbers old) {
    super.didUpdateWidget(old);
    if (!identical(old.controller, widget.controller)) {
      old.controller.removeListener(_onChange);
      widget.controller.addListener(_onChange);
      _lineCount = _countLines(widget.controller.text);
    }
  }

  void _onChange() {
    final n = _countLines(widget.controller.text);
    if (n != _lineCount) {
      setState(() => _lineCount = n);
    }
  }

  int _countLines(String s) => '\n'.allMatches(s).length + 1;

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      padding: const EdgeInsets.fromLTRB(0, 12, 6, 12),
      color: widget.background,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            _lineCount,
            (i) => Text(
              '${i + 1}',
              style: TextStyle(
                color: widget.foreground,
                fontFamily: 'monospace',
                fontFamilyFallback: const ['Menlo', 'Courier'],
                fontSize: 12,
                height: 1.625,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Converts Tab key to 2 spaces.
class _TabIndentFormatter extends TextInputFormatter {
  const _TabIndentFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.text.contains('\t')) return newValue;
    final replaced = newValue.text.replaceAll('\t', '  ');
    final offset = newValue.selection.baseOffset +
        (replaced.length - newValue.text.length);
    return newValue.copyWith(
      text: replaced,
      selection:
          TextSelection.collapsed(offset: offset.clamp(0, replaced.length)),
    );
  }
}
