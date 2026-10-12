import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/playground_provider.dart';
import '../services/autosave_service.dart';
import '../services/lesson_templates.dart';
import '../services/project_storage.dart';
import '../widgets/code_editor_pane.dart';
import '../widgets/editor_tab_bar.dart';
import '../widgets/playground_toolbar.dart';
import '../widgets/preview_pane.dart';

/// Arguments passed when opening the playground from a project card,
/// a learning lesson, or an editor lesson template.
///
/// Precedence (highest first):
///   1. projectId        — load saved project from storage
///   2. starterCode      — load raw {html, css, js} buffers directly
///                         (used by the new learning system; lessonId
///                         is preserved for completion attribution)
///   3. lessonId         — look up an editor LessonTemplate by id
class PlaygroundArguments {
  final String? projectId;
  final String? lessonId;
  final Map<String, String>? starterCode;
  const PlaygroundArguments({
    this.projectId,
    this.lessonId,
    this.starterCode,
  });
}

class PlaygroundScreen extends StatelessWidget {
  const PlaygroundScreen({super.key, this.args});

  /// Args passed directly via constructor (used by tests). In normal
  /// navigation the args are read from ModalRoute settings.
  final PlaygroundArguments? args;

  static const route = '/playground';

  @override
  Widget build(BuildContext context) {
    final routeArgs = args ??
        (ModalRoute.of(context)?.settings.arguments as PlaygroundArguments?);

    return ChangeNotifierProvider(
      create: (_) => PlaygroundProvider(),
      child: _PlaygroundView(args: routeArgs),
    );
  }
}

class _PlaygroundView extends StatefulWidget {
  final PlaygroundArguments? args;
  const _PlaygroundView({this.args});

  @override
  State<_PlaygroundView> createState() => _PlaygroundViewState();
}

class _PlaygroundViewState extends State<_PlaygroundView>
    with WidgetsBindingObserver {
  bool _initialLoadStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _runInitialLoad();
    });
  }

  Future<void> _runInitialLoad() async {
    if (_initialLoadStarted) return;
    _initialLoadStarted = true;

    final provider = context.read<PlaygroundProvider>();
    final args = widget.args;

    // 1. Explicit project → load it
    if (args?.projectId != null) {
      final project =
          await ProjectStorage.instance.getProject(args!.projectId!);
      if (project != null && mounted) {
        provider.loadProject(project);
      }
      _startAutosave(provider);
      return;
    }

    // 2. Explicit starter code (from learning lesson) → load directly
    if (args?.starterCode != null) {
      if (mounted) {
        provider.loadStarterCode(
          args!.starterCode!,
          lessonId: args.lessonId,
        );
      }
      _startAutosave(provider);
      return;
    }

    // 3. Editor lesson template by id → look up + load
    if (args?.lessonId != null) {
      final lesson = LessonTemplates.byId(args!.lessonId!);
      if (lesson != null && mounted) {
        provider.loadLesson(lesson);
      }
      _startAutosave(provider);
      return;
    }

    // 3. Otherwise: offer to restore last draft if one exists
    final draft = await AutosaveService.instance.restore();
    if (draft != null && mounted) {
      final restore = await _askRestoreDraft(context, draft.savedAt);
      if (restore == true && mounted) {
        provider.restoreFromDraft(draft);
      } else {
        await AutosaveService.instance.clear();
      }
    }
    _startAutosave(provider);
  }

  void _startAutosave(PlaygroundProvider provider) {
    AutosaveService.instance.start(provider.snapshot);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Flush draft on background — covers app kill before next tick
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      AutosaveService.instance.flush();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Final flush before screen tears down
    AutosaveService.instance.flush();
    AutosaveService.instance.stop();
    super.dispose();
  }

  Future<bool?> _askRestoreDraft(BuildContext context, DateTime savedAt) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.history, size: 36),
        title: const Text('Restore your draft?'),
        content: Text(
          'We saved your work from ${_formatRelative(savedAt)}. Restore it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Start fresh'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  String _formatRelative(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minute(s) ago';
    if (diff.inHours < 24) return '${diff.inHours} hour(s) ago';
    return '${diff.inDays} day(s) ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playground'),
        actions: [
          IconButton(
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            return isWide ? const _WideLayout() : const _NarrowLayout();
          },
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
              icon: Icons.tab,
              text: 'Switch between HTML, CSS, and JS tabs.',
            ),
            _HelpItem(
              icon: Icons.play_arrow,
              text: 'Tap Run to render the preview.',
            ),
            _HelpItem(
              icon: Icons.save_outlined,
              text: 'Save to keep your project locally.',
            ),
            _HelpItem(
              icon: Icons.history,
              text: 'Your work auto-saves every 30 seconds.',
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

class _EditorColumn extends StatelessWidget {
  const _EditorColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        EditorTabBar(),
        Expanded(child: _ActiveTabEditor()),
        PlaygroundToolbar(),
      ],
    );
  }
}

class _ActiveTabEditor extends StatelessWidget {
  const _ActiveTabEditor();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaygroundProvider>();
    return CodeEditorPane(
      initialText: provider.currentDraft,
      onChanged: provider.updateCurrent,
      // Reload editor contents when:
      //  - tab changes (different document)
      //  - runVersion changes (reset/load/restore)
      resetKey: '${provider.selectedTab.name}:${provider.runVersion}',
    );
  }
}

class _CombinedPreview extends StatelessWidget {
  const _CombinedPreview();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaygroundProvider>();
    return PreviewPane(
      htmlDocument: _buildDocument(
        html: provider.htmlCommitted,
        css: provider.cssCommitted,
        js: provider.jsCommitted,
      ),
      version: provider.runVersion,
    );
  }

  static String _buildDocument({
    required String html,
    required String css,
    required String js,
  }) {
    final safeJs = js.replaceAll('</script>', r'<\/script>');
    final cssBlock = css.trim().isEmpty ? '' : '<style>$css</style>';
    final jsBlock = safeJs.trim().isEmpty ? '' : '<script>$safeJs</script>';

    final hasHtmlTag =
        RegExp(r'<html[\s>]', caseSensitive: false).hasMatch(html);
    final hasHead =
        RegExp(r'<head[\s>]', caseSensitive: false).hasMatch(html);
    final hasBodyClose =
        RegExp(r'</body\s*>', caseSensitive: false).hasMatch(html);

    if (hasHtmlTag) {
      var doc = html;
      if (cssBlock.isNotEmpty) {
        if (hasHead) {
          doc = doc.replaceFirstMapped(
            RegExp(r'(<head[^>]*>)', caseSensitive: false),
            (m) => '${m[1]}$cssBlock',
          );
        } else {
          doc = doc.replaceFirstMapped(
            RegExp(r'(<html[^>]*>)', caseSensitive: false),
            (m) => '${m[1]}<head>$cssBlock</head>',
          );
        }
      }
      if (jsBlock.isNotEmpty) {
        if (hasBodyClose) {
          doc = doc.replaceFirstMapped(
            RegExp(r'(</body\s*>)', caseSensitive: false),
            (m) => '$jsBlock${m[1]}',
          );
        } else {
          doc = '$doc\n$jsBlock';
        }
      }
      return doc;
    }

    return '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
$cssBlock
</head>
<body>
$html
$jsBlock
</body>
</html>''';
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(flex: 55, child: _EditorColumn()),
        _PreviewLabel(),
        Expanded(flex: 45, child: _CombinedPreview()),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _EditorColumn()),
        SizedBox(width: 1, child: ColoredBox(color: Color(0x33808080))),
        Expanded(
          child: Column(
            children: [
              _PreviewLabel(),
              Expanded(child: _CombinedPreview()),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewLabel extends StatelessWidget {
  const _PreviewLabel();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? const Color(0xFF8A929D) : const Color(0xFF5D6670);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isDark ? const Color(0xFF141820) : const Color(0xFFF2F4F8),
      child: Row(
        children: [
          Icon(Icons.visibility_outlined, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            'Preview',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
