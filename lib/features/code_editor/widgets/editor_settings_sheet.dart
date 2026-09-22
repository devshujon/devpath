import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/code_editor_provider.dart';

Future<void> showEditorSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => const _EditorSettingsBody(),
  );
}

class _EditorSettingsBody extends StatelessWidget {
  const _EditorSettingsBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<CodeEditorProvider>(
      builder: (context, editor, _) {
        final s = editor.settings;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Editor settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                Text('Font size: ${s.fontSize.round()}'),
                Slider(
                  value: s.fontSize.clamp(11, 22),
                  min: 11,
                  max: 22,
                  divisions: 11,
                  label: s.fontSize.round().toString(),
                  onChanged: (v) => editor.updateSettings(
                    s.copyWith(fontSize: v),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Word wrap'),
                  value: s.wordWrap,
                  onChanged: (v) =>
                      editor.updateSettings(s.copyWith(wordWrap: v)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Line numbers'),
                  value: s.showLineNumbers,
                  onChanged: (v) =>
                      editor.updateSettings(s.copyWith(showLineNumbers: v)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto-save draft'),
                  value: s.autoSave,
                  onChanged: (v) =>
                      editor.updateSettings(s.copyWith(autoSave: v)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark editor theme'),
                  value: s.darkEditorTheme,
                  onChanged: (v) =>
                      editor.updateSettings(s.copyWith(darkEditorTheme: v)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
