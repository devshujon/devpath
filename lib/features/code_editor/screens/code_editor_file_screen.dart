import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../editor/widgets/code_editor_pane.dart';
import '../models/editor_file_type.dart';
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
        editor.openWorkspaceFile(match.first);
      });
    }
  }

  Future<bool> _onWillPop() async {
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
      child: Consumer<CodeEditorProvider>(
        builder: (context, editor, _) {
          final file = editor.openFile;
          if (file == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Editor')),
              body: const Center(child: Text('File not found')),
            );
          }
          final settings = editor.settings;
          final canPreview = file.kind.supportsHtmlPreview;

          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      file.displayName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (editor.isDirty) ...[
                    const SizedBox(width: 6),
                    Tooltip(
                      message: 'Unsaved changes',
                      child: Icon(
                        Icons.circle,
                        size: 10,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
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
                  child: CodeEditorPane(
                    key: ValueKey('${file.id}-${file.updatedAt.millisecondsSinceEpoch}'),
                    resetKey: '${file.id}-${file.updatedAt.millisecondsSinceEpoch}',
                    initialText: editor.content,
                    onChanged: editor.updateContent,
                    fontSize: settings.fontSize,
                    wordWrap: settings.wordWrap,
                    showLineNumbers: settings.showLineNumbers,
                    preferDarkSurface: settings.darkEditorTheme,
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
                              onPressed: canPreview
                                  ? () => _preview(context)
                                  : file.kind.isPhp
                                      ? () => _phpInfo(context)
                                      : null,
                              child: Text(
                                canPreview
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
    final ok = await context.read<CodeEditorProvider>().save();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Saved' : 'Save failed'),
      ),
    );
  }

  Future<void> _preview(BuildContext context) async {
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
