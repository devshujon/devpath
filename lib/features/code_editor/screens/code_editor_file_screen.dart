import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../editor/widgets/codemirror_editor_pane.dart';
import '../models/editor_file_type.dart';
import '../models/workspace_file.dart';
import '../providers/code_editor_provider.dart';
import '../widgets/editor_settings_sheet.dart';
import '../widgets/unsaved_changes_dialog.dart';

class CodeEditorFileArguments {
  final String fileId;
  const CodeEditorFileArguments({required this.fileId});
}

class CodeEditorFileScreen extends StatefulWidget {
  const CodeEditorFileScreen({super.key});

  @override
  State<CodeEditorFileScreen> createState() => _CodeEditorFileScreenState();
}

class _CodeEditorFileScreenState extends State<CodeEditorFileScreen> {
  final GlobalKey<CodemirrorEditorPaneState> _editorKey =
      GlobalKey<CodemirrorEditorPaneState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as CodeEditorFileArguments?;
    if (args == null) return;
    final editor = context.read<CodeEditorProvider>();
    final match = editor.files.where((f) => f.id == args.fileId).toList();
    if (match.isEmpty) return;
    if (editor.openFile?.id != args.fileId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) editor.openWorkspaceFile(match.first);
      });
    }
  }

  Future<void> _syncFromEditor() async {
    final state = _editorKey.currentState;
    if (state == null) return;
    final text = await state.flushAndGetCode();
    if (!mounted) return;
    context.read<CodeEditorProvider>().applyEditorBuffer(text);
  }

  Future<bool> _onWillPop() async {
    await _syncFromEditor();
    if (!mounted) return false;
    final editor = context.read<CodeEditorProvider>();
    if (!editor.isDirty) return true;
    final action = await showUnsavedChangesDialog(context);
    if (action == UnsavedChangesAction.cancel || action == null) {
      return false;
    }
    if (action == UnsavedChangesAction.discard) return true;
    final ok = await editor.save();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save failed. Try again.')),
      );
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _onWillPop() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Selector<CodeEditorProvider, WorkspaceFile?>(
        selector: (_, p) => p.openFile,
        builder: (context, file, _) {
          if (file == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Editor')),
              body: const Center(child: Text('File not found')),
            );
          }
          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: Selector<CodeEditorProvider, bool>(
                selector: (_, p) => p.isDirty,
                builder: (context, dirty, _) {
                  return Row(
                    children: [
                      Flexible(
                        child: Text(
                          file.displayName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (dirty) ...[
                        const SizedBox(width: 6),
                        Tooltip(
                          message: 'Unsaved changes',
                          child: Icon(
                            Icons.circle,
                            size: 10,
                            semanticLabel: 'Unsaved changes',
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              actions: [
                PopupMenuButton<String>(
                  tooltip: 'File actions',
                  onSelected: (v) => _onMenu(context, v),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'save_as',
                      child: Text('Save as…'),
                    ),
                    const PopupMenuItem(
                      value: 'rename',
                      child: Text('Rename'),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Text('Share / export'),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Text('Editor settings'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _CodemirrorHost(
                    editorKey: _editorKey,
                    fileId: file.id,
                    fileKind: file.kind,
                  ),
                ),
                Material(
                  elevation: 4,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _save(context),
                              child: const Text('Save'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              onPressed: file.kind.supportsHtmlPreview
                                  ? () => _preview(context)
                                  : file.kind.isPhp
                                      ? () => _phpInfo(context)
                                      : null,
                              child: Text(
                                file.kind.supportsHtmlPreview
                                    ? 'Preview'
                                    : file.kind.isPhp
                                        ? 'Run info'
                                        : 'Preview',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    await _syncFromEditor();
    if (!context.mounted) return;
    final ok = await context.read<CodeEditorProvider>().save();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Saved' : 'Save failed')),
    );
  }

  Future<void> _preview(BuildContext context) async {
    await _syncFromEditor();
    if (!context.mounted) return;
    final editor = context.read<CodeEditorProvider>();
    if (editor.isDirty) {
      final ok = await editor.save(silent: true);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Save draft before preview failed')),
        );
      }
    }
    editor.bumpPreview();
    if (!context.mounted) return;
    await Navigator.pushNamed(context, AppRoutes.codeEditorPreview);
  }

  void _phpInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('PHP preview'),
        content: const Text(
          'PHP requires a PHP runtime/server to execute. The editor can edit '
          'and save this file, but Android WebView cannot execute PHP directly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _onMenu(BuildContext context, String value) async {
    await _syncFromEditor();
    if (!context.mounted) return;
    final editor = context.read<CodeEditorProvider>();
    if (value == 'save_as') {
      final (_, err) = await editor.saveAs();
      if (!context.mounted) return;
      if (err != null && err.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err)));
      } else if (err == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved as new file')),
        );
      }
    } else if (value == 'rename') {
      await _rename(context);
    } else if (value == 'share') {
      final err = await editor.shareOpenFile();
      if (!context.mounted) return;
      if (err != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err)));
      }
    } else if (value == 'settings') {
      await showEditorSettingsSheet(context);
    } else if (value == 'delete') {
      await _delete(context);
    }
  }

  Future<void> _rename(BuildContext context) async {
    final editor = context.read<CodeEditorProvider>();
    final file = editor.openFile;
    if (file == null) return;
    final controller = TextEditingController(text: file.displayName);
    final err = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename file'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'File name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final e = await editor.renameOpenFile(controller.text);
              if (ctx.mounted) Navigator.pop(ctx, e);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!context.mounted || err == null) return;
    if (err.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Future<void> _delete(BuildContext context) async {
    final editor = context.read<CodeEditorProvider>();
    final file = editor.openFile;
    if (file == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${file.displayName}?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final err = await editor.deleteFile(file.id);
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      Navigator.of(context).pop();
    }
  }
}

/// Keeps the WebView editor mounted; only settings/file kind refresh the pane.
class _CodemirrorHost extends StatefulWidget {
  final GlobalKey<CodemirrorEditorPaneState> editorKey;
  final String fileId;
  final EditorFileKind fileKind;

  const _CodemirrorHost({
    required this.editorKey,
    required this.fileId,
    required this.fileKind,
  });

  @override
  State<_CodemirrorHost> createState() => _CodemirrorHostState();
}

class _CodemirrorHostState extends State<_CodemirrorHost> {
  late String _bootText;

  @override
  void initState() {
    super.initState();
    _bootText = context.read<CodeEditorProvider>().content;
  }

  @override
  void didUpdateWidget(covariant _CodemirrorHost old) {
    super.didUpdateWidget(old);
    if (old.fileId != widget.fileId) {
      _bootText = context.read<CodeEditorProvider>().content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<CodeEditorProvider, CodeEditorSettingsView>(
      selector: (_, p) => CodeEditorSettingsView(
        fontSize: p.settings.fontSize,
        wordWrap: p.settings.wordWrap,
        showLineNumbers: p.settings.showLineNumbers,
        darkEditorTheme: p.settings.darkEditorTheme,
      ),
      builder: (context, view, _) {
        return CodemirrorEditorPane(
          key: widget.editorKey,
          documentKey: widget.fileId,
          fileKind: widget.fileKind,
          initialText: _bootText,
          onChanged: context.read<CodeEditorProvider>().updateContent,
          fontSize: view.fontSize,
          wordWrap: view.wordWrap,
          showLineNumbers: view.showLineNumbers,
          preferDarkSurface: view.darkEditorTheme,
        );
      },
    );
  }
}

@immutable
class CodeEditorSettingsView {
  final double fontSize;
  final bool wordWrap;
  final bool showLineNumbers;
  final bool darkEditorTheme;

  const CodeEditorSettingsView({
    required this.fontSize,
    required this.wordWrap,
    required this.showLineNumbers,
    required this.darkEditorTheme,
  });

  @override
  bool operator ==(Object other) =>
      other is CodeEditorSettingsView &&
      fontSize == other.fontSize &&
      wordWrap == other.wordWrap &&
      showLineNumbers == other.showLineNumbers &&
      darkEditorTheme == other.darkEditorTheme;

  @override
  int get hashCode => Object.hash(
        fontSize,
        wordWrap,
        showLineNumbers,
        darkEditorTheme,
      );
}
