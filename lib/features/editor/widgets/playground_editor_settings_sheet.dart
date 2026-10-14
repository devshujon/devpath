import 'package:flutter/material.dart';

import '../../code_editor/models/code_editor_settings.dart';

class PlaygroundEditorSettingsSheet extends StatefulWidget {
  final CodeEditorSettings initial;
  final ValueChanged<CodeEditorSettings> onChanged;

  const PlaygroundEditorSettingsSheet({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<PlaygroundEditorSettingsSheet> createState() =>
      _PlaygroundEditorSettingsSheetState();
}

class _PlaygroundEditorSettingsSheetState
    extends State<PlaygroundEditorSettingsSheet> {
  late double _fontSize;
  late bool _wordWrap;
  late bool _lineNumbers;
  late bool _darkEditor;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.initial.fontSize;
    _wordWrap = widget.initial.wordWrap;
    _lineNumbers = widget.initial.showLineNumbers;
    _darkEditor = widget.initial.darkEditorTheme;
  }

  void _emit() {
    widget.onChanged(
      widget.initial.copyWith(
        fontSize: _fontSize,
        wordWrap: _wordWrap,
        showLineNumbers: _lineNumbers,
        darkEditorTheme: _darkEditor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Editor settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text('Font size: ${_fontSize.round()}'),
          Slider(
            min: 11,
            max: 20,
            divisions: 9,
            value: _fontSize,
            label: _fontSize.round().toString(),
            onChanged: (v) {
              setState(() => _fontSize = v);
              _emit();
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Word wrap'),
            value: _wordWrap,
            onChanged: (v) {
              setState(() => _wordWrap = v);
              _emit();
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Line numbers'),
            value: _lineNumbers,
            onChanged: (v) {
              setState(() => _lineNumbers = v);
              _emit();
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dark editor surface'),
            value: _darkEditor,
            onChanged: (v) {
              setState(() => _darkEditor = v);
              _emit();
            },
          ),
        ],
      ),
    );
  }
}
