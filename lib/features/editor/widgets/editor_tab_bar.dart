import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/playground_provider.dart';

class EditorTabBar extends StatelessWidget {
  const EditorTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaygroundProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF141820) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF262B35) : const Color(0xFFE4E7EE);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: PlaygroundTab.values.map((tab) {
          final selected = provider.selectedTab == tab;
          return Expanded(
            child: _TabButton(
              tab: tab,
              selected: selected,
              onTap: () => provider.switchTab(tab),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final PlaygroundTab tab;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    final fg = selected
        ? primary
        : (isDark ? const Color(0xFF8A929D) : const Color(0xFF5D6670));

    final indicator = selected
        ? BoxDecoration(
            border: Border(bottom: BorderSide(color: primary, width: 2)),
          )
        : null;

    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: indicator,
        child: Text(
          tab.label,
          style: TextStyle(
            color: fg,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
