import 'package:flutter/material.dart';

class EditorFindReplaceSheet extends StatefulWidget {
  final String source;
  final void Function(String updated, int cursor) onApply;

  const EditorFindReplaceSheet({
    super.key,
    required this.source,
    required this.onApply,
  });

  @override
  State<EditorFindReplaceSheet> createState() => _EditorFindReplaceSheetState();
}

class _EditorFindReplaceSheetState extends State<EditorFindReplaceSheet> {
  final _findCtrl = TextEditingController();
  final _replaceCtrl = TextEditingController();
  bool _caseSensitive = false;

  @override
  void dispose() {
    _findCtrl.dispose();
    _replaceCtrl.dispose();
    super.dispose();
  }

  int? _findNext(String haystack, int from) {
    final needle = _findCtrl.text;
    if (needle.isEmpty) return null;
    final idx = _caseSensitive
        ? haystack.indexOf(needle, from)
        : haystack.toLowerCase().indexOf(needle.toLowerCase(), from);
    return idx >= 0 ? idx : null;
  }

  void _replaceOne() {
    final needle = _findCtrl.text;
    if (needle.isEmpty) return;
    final idx = _findNext(widget.source, 0);
    if (idx == null) return;
    final updated = widget.source.replaceRange(
      idx,
      idx + needle.length,
      _replaceCtrl.text,
    );
    widget.onApply(updated, idx + _replaceCtrl.text.length);
    if (mounted) Navigator.pop(context);
  }

  void _replaceAll() {
    final needle = _findCtrl.text;
    if (needle.isEmpty) return;
    final updated = _caseSensitive
        ? widget.source.replaceAll(needle, _replaceCtrl.text)
        : widget.source.replaceAll(
            RegExp(RegExp.escape(needle), caseSensitive: false),
            _replaceCtrl.text,
          );
    widget.onApply(updated, updated.length);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Find & replace',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _findCtrl,
            decoration: const InputDecoration(
              labelText: 'Find',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _replaceCtrl,
            decoration: const InputDecoration(
              labelText: 'Replace with',
              border: OutlineInputBorder(),
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Case sensitive'),
            value: _caseSensitive,
            onChanged: (v) => setState(() => _caseSensitive = v ?? false),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _replaceOne,
                  child: const Text('Replace first'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _replaceAll,
                  child: const Text('Replace all'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
