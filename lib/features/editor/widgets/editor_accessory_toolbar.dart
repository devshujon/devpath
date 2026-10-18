import 'package:flutter/material.dart';

import '../providers/playground_provider.dart';

class EditorAccessoryToolbar extends StatelessWidget {
  final PlaygroundTab tab;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onSelectAll;
  final Future<void> Function() onCopy;
  final VoidCallback onFindReplace;
  final ValueChanged<String> onInsert;

  const EditorAccessoryToolbar({
    super.key,
    required this.tab,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    required this.onSelectAll,
    required this.onCopy,
    required this.onFindReplace,
    required this.onInsert,
  });

  @override
  Widget build(BuildContext context) {
    final symbols = _symbolsFor(tab);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.4,
          ),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          children: [
            _Btn(icon: Icons.undo, enabled: canUndo, onTap: onUndo),
            _Btn(icon: Icons.redo, enabled: canRedo, onTap: onRedo),
            _Btn(icon: Icons.select_all, onTap: onSelectAll),
            _Btn(icon: Icons.copy_outlined, onTap: () => onCopy()),
            _Btn(icon: Icons.find_replace_outlined, onTap: onFindReplace),
            const VerticalDivider(width: 12, indent: 8, endIndent: 8),
            ...symbols.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => onInsert(s),
                  child: Text(
                    s,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _symbolsFor(PlaygroundTab tab) => switch (tab) {
        PlaygroundTab.html => const ['<', '>', '/', '=', '"', '<!-- -->'],
        PlaygroundTab.css => const ['{', '}', ':', ';', '.', '#'],
        PlaygroundTab.js => const ['(', ')', '{', '}', ';', '=>', 'function'],
      };
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _Btn({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '',
      iconSize: 20,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: enabled ? onTap : null,
      icon: Icon(icon),
    );
  }
}
