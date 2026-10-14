import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/playground_provider.dart';
import '../services/autosave_service.dart';
import '../services/lesson_templates.dart';
import '../services/project_storage.dart';
import '../../code_editor/models/code_editor_settings.dart';
import '../../code_editor/services/code_editor_settings_storage.dart';
import '../widgets/editor_tab_bar.dart';
import '../widgets/playground_code_editor_pane.dart';
import '../widgets/playground_editor_settings_sheet.dart';
import '../widgets/playground_toolbar.dart';
import '../widgets/preview_pane.dart';
import '../logic/playground_preview_launcher.dart';
import '../services/html_export_service.dart';
import '../providers/projects_list_provider.dart';
import '../utils/playground_preview_document.dart';
import 'playground_live_preview_screen.dart';

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
  CodeEditorSettings _editorSettings = const CodeEditorSettings();
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _runInitialLoad();
    });
    _loadEditorSettings();
  }

  Future<void> _loadEditorSettings() async {
    final s = await CodeEditorSettingsStorage.instance.load();
    if (!mounted) return;
    setState(() {
      _editorSettings = s;
      _settingsLoaded = true;
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
    final provider = context.watch<PlaygroundProvider>();
    final title = provider.projectTitle ?? 'Playground';
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (provider.isDirty)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Center(
                child: Tooltip(
                  message: 'Unsaved changes',
                  child: Icon(Icons.circle, size: 8, color: Colors.orange),
                ),
              ),
            ),
          PopupMenuButton<String>(
            tooltip: 'Project actions',
            onSelected: (v) => _onProjectMenu(context, v, provider),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'export', child: Text('Export HTML')),
              if (provider.isExistingProject) ...[
                const PopupMenuItem(value: 'rename', child: Text('Rename')),
                const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete project'),
                ),
              ],
            ],
          ),
          IconButton(
            tooltip: 'Editor settings',
            icon: const Icon(Icons.tune),
            onPressed: _settingsLoaded ? () => _openSettings(context) : null,
          ),
          IconButton(
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: SafeArea(
        child: _settingsLoaded
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 720;
                  return isWide
                      ? _WideLayout(editorSettings: _editorSettings)
                      : _NarrowLayout(editorSettings: _editorSettings);
                },
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _onProjectMenu(
    BuildContext context,
    String action,
    PlaygroundProvider provider,
  ) async {
    switch (action) {
      case 'export':
        await _exportHtml(context, provider);
      case 'rename':
        await _renameProject(context, provider);
      case 'duplicate':
        await _duplicateProject(context, provider);
      case 'delete':
        await _deleteProject(context, provider);
    }
  }

  Future<void> _exportHtml(
    BuildContext context,
    PlaygroundProvider provider,
  ) async {
    try {
      final result = HtmlExportService.buildExport(
        title: provider.projectTitle ?? 'playground',
        html: provider.htmlDraft,
        css: provider.cssDraft,
        js: provider.jsDraft,
      );
      await HtmlExportService.shareExport(result);
    } on HtmlExportTooLargeException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export failed: file is too large.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export failed.')),
      );
    }
  }

  Future<void> _renameProject(
    BuildContext context,
    PlaygroundProvider provider,
  ) async {
    final controller = TextEditingController(text: provider.projectTitle ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename project'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || !context.mounted) return;
    final saved = await provider.renameCurrentProject(name);
    if (saved != null && context.mounted) {
      context.read<ProjectsListProvider>().upsert(saved);
    }
  }

  Future<void> _duplicateProject(
    BuildContext context,
    PlaygroundProvider provider,
  ) async {
    final base = provider.projectTitle ?? 'Project';
    final controller = TextEditingController(text: '$base copy');
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Duplicate project'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Create copy'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || !context.mounted) return;
    final copy = await provider.duplicateAsNewProject(title: name);
    if (!context.mounted) return;
    context.read<ProjectsListProvider>().upsert(copy);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Created "${copy.title}"')),
    );
  }

  Future<void> _deleteProject(
    BuildContext context,
    PlaygroundProvider provider,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete project?'),
        content: const Text('This removes the saved project from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final id = provider.projectId;
    await provider.deleteCurrentProject();
    if (id != null && context.mounted) {
      await context.read<ProjectsListProvider>().deleteProject(id);
    }
  }

  Future<void> _openSettings(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => PlaygroundEditorSettingsSheet(
        initial: _editorSettings,
        onChanged: (s) async {
          setState(() => _editorSettings = s);
          await CodeEditorSettingsStorage.instance.save(s);
        },
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
  final CodeEditorSettings editorSettings;
  const _EditorColumn({required this.editorSettings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const EditorTabBar(),
        Expanded(child: _ActiveTabEditor(editorSettings: editorSettings)),
        const PlaygroundToolbar(),
      ],
    );
  }
}

class _ActiveTabEditor extends StatelessWidget {
  final CodeEditorSettings editorSettings;
  const _ActiveTabEditor({required this.editorSettings});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaygroundProvider>();
    return PlaygroundCodeEditorPane(
      tab: provider.selectedTab,
      initialText: provider.currentDraft,
      onChanged: provider.updateCurrent,
      resetKey: '${provider.selectedTab.name}:${provider.runVersion}',
      fontSize: editorSettings.fontSize,
      wordWrap: editorSettings.wordWrap,
      showLineNumbers: editorSettings.showLineNumbers,
      preferDarkSurface: editorSettings.darkEditorTheme,
    );
  }
}

class _CombinedPreview extends StatelessWidget {
  const _CombinedPreview();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaygroundProvider>();
    return PreviewPane(
      htmlDocument: buildPlaygroundPreviewDocument(
        html: provider.htmlCommitted,
        css: provider.cssCommitted,
        js: provider.jsCommitted,
      ),
      version: provider.runVersion,
      onOpenLivePreview: PlaygroundPreviewLauncher.embeddedPreviewIsStaticOnly
          ? () => PlaygroundPreviewLauncher.commitAndOpenLive(
                context,
                provider,
                runFirst: true,
              )
          : null,
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final CodeEditorSettings editorSettings;
  const _NarrowLayout({required this.editorSettings});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaygroundProvider>();
    return Column(
      children: [
        _MobileViewSwitcher(
          view: provider.paneView,
          onChanged: provider.setPaneView,
          onLivePreview: () => _openLivePreview(context, provider),
        ),
        Expanded(
          child: provider.paneView == PlaygroundPaneView.editor
              ? _EditorColumn(editorSettings: editorSettings)
              : const Column(
                  children: [
                    _PreviewLabel(),
                    Expanded(child: _CombinedPreview()),
                  ],
                ),
        ),
      ],
    );
  }

  static void _openLivePreview(
    BuildContext context,
    PlaygroundProvider provider,
  ) {
    PlaygroundPreviewLauncher.commitAndOpenLive(context, provider);
  }
}

class _WideLayout extends StatelessWidget {
  final CodeEditorSettings editorSettings;
  const _WideLayout({required this.editorSettings});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _EditorColumn(editorSettings: editorSettings)),
        const SizedBox(width: 1, child: ColoredBox(color: Color(0x33808080))),
        Expanded(
          child: Column(
            children: [
              const _PreviewLabel(),
              if (PlaygroundPreviewLauncher.embeddedPreviewIsStaticOnly)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Builder(
                    builder: (context) {
                      return FilledButton.tonalIcon(
                        onPressed: () {
                          final p = context.read<PlaygroundProvider>();
                          PlaygroundPreviewLauncher.commitAndOpenLive(context, p);
                        },
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('Live preview'),
                      );
                    },
                  ),
                ),
              const Expanded(child: _CombinedPreview()),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileViewSwitcher extends StatelessWidget {
  final PlaygroundPaneView view;
  final ValueChanged<PlaygroundPaneView> onChanged;
  final VoidCallback onLivePreview;

  const _MobileViewSwitcher({
    required this.view,
    required this.onChanged,
    required this.onLivePreview,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<PlaygroundPaneView>(
              segments: const [
                ButtonSegment(
                  value: PlaygroundPaneView.editor,
                  icon: Icon(Icons.code, size: 18),
                  label: Text('Editor'),
                ),
                ButtonSegment(
                  value: PlaygroundPaneView.preview,
                  icon: Icon(Icons.visibility_outlined, size: 18),
                  label: Text('Preview'),
                ),
              ],
              selected: {view},
              onSelectionChanged: (s) => onChanged(s.first),
            ),
          ),
          IconButton(
            tooltip: 'Live preview (full screen)',
            onPressed: onLivePreview,
            icon: const Icon(Icons.open_in_full),
          ),
        ],
      ),
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
