import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/html_practice_provider.dart';
import '../widgets/code_editor_pane.dart';
import '../widgets/practice_toolbar.dart';
import '../widgets/preview_pane.dart';

/// Split-screen HTML practice. Provider is scoped to this screen — when
/// the user leaves and comes back, they get a fresh state. If you want
/// state to persist across sessions, lift the ChangeNotifierProvider up
/// in your widget tree (e.g. into MultiProvider in main.dart).
class HtmlPracticeScreen extends StatelessWidget {
  const HtmlPracticeScreen({super.key});

  static const route = '/html-practice';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HtmlPracticeProvider(),
      child: const _PracticeView(),
    );
  }
}

class _PracticeView extends StatelessWidget {
  const _PracticeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTML Practice'),
        actions: [
          IconButton(
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const PracticeToolbar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Landscape / wide tablet → side-by-side
                  // Portrait phone → stacked
                  final isWide = constraints.maxWidth >= 720;
                  return isWide
                      ? const _WideLayout()
                      : const _NarrowLayout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How it works',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            _HelpItem(
              icon: Icons.edit_outlined,
              text: 'Edit HTML in the top pane. Use Tab for indentation.',
            ),
            _HelpItem(
              icon: Icons.play_arrow,
              text: 'Tap Run to render your code in the preview below.',
            ),
            _HelpItem(
              icon: Icons.refresh,
              text: 'Reset returns the editor to the starter template.',
            ),
            _HelpItem(
              icon: Icons.error_outline,
              text: 'JavaScript errors appear in a red banner on the preview.',
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HelpItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// Portrait / phone: editor on top, preview on bottom, divider draggable
/// would be nice but adds complexity — fixed 55/45 split is fine for v1.
class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(flex: 55, child: _SingleHtmlEditor()),
        _PreviewLabel(),
        Expanded(flex: 45, child: _SingleHtmlPreview()),
      ],
    );
  }
}

/// Wide: editor on left, preview on right.
class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _SingleHtmlEditor()),
        SizedBox(
          width: 1,
          child: ColoredBox(color: Color(0x33808080)),
        ),
        Expanded(
          child: Column(
            children: [
              _PreviewLabel(),
              Expanded(child: _SingleHtmlPreview()),
            ],
          ),
        ),
      ],
    );
  }
}

/// Adapter: wires PreviewPane to HtmlPracticeProvider.
class _SingleHtmlPreview extends StatelessWidget {
  const _SingleHtmlPreview();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HtmlPracticeProvider>();
    return PreviewPane(
      htmlDocument: provider.committedCode,
      version: provider.runVersion,
    );
  }
}

/// Adapter: wires the generic CodeEditorPane to HtmlPracticeProvider.
/// The runVersion is used as resetKey so reset() reloads editor content.
class _SingleHtmlEditor extends StatelessWidget {
  const _SingleHtmlEditor();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HtmlPracticeProvider>();
    return CodeEditorPane(
      initialText: provider.draftCode,
      onChanged: provider.updateDraft,
      resetKey: provider.runVersion,
    );
  }
}

class _PreviewLabel extends StatelessWidget {
  const _PreviewLabel();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isDark ? const Color(0xFF141820) : const Color(0xFFF2F4F8),
      child: Row(
        children: [
          Icon(
            Icons.visibility_outlined,
            size: 14,
            color: isDark
                ? const Color(0xFF8A929D)
                : const Color(0xFF5D6670),
          ),
          const SizedBox(width: 6),
          Text(
            'Preview',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? const Color(0xFF8A929D)
                  : const Color(0xFF5D6670),
            ),
          ),
        ],
      ),
    );
  }
}
