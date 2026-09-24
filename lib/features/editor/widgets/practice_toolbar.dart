import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/html_practice_provider.dart';

class PracticeToolbar extends StatelessWidget {
  const PracticeToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HtmlPracticeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF141820) : Colors.white;

    return Material(
      color: bg,
      elevation: 0,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? const Color(0xFF262B35)
                  : const Color(0xFFE4E7EE),
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.code, size: 18),
            const SizedBox(width: 8),
            Text(
              'index.html',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontFamilyFallback: const ['Menlo', 'Courier'],
                  ),
            ),
            if (provider.hasUnsavedChanges) ...[
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            const Spacer(),
            IconButton(
              tooltip: 'Copy code',
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(Icons.copy_outlined),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: provider.draftCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Reset to starter',
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(Icons.refresh),
              onPressed: () => _confirmReset(context, provider),
            ),
            const SizedBox(width: 4),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Run'),
              onPressed: provider.run,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    HtmlPracticeProvider provider,
  ) async {
    if (!provider.hasUnsavedChanges &&
        provider.draftCode == HtmlPracticeProvider.defaultCode) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset code?'),
        content: const Text(
          'This will replace your code with the starter template.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      provider.reset();
    }
  }
}
