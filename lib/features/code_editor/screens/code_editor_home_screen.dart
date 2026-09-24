import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../models/editor_file_type.dart';
import '../models/workspace_file.dart';
import '../screens/code_editor_file_screen.dart';
import '../providers/code_editor_provider.dart';
import '../widgets/new_file_sheet.dart';

class CodeEditorHomeScreen extends StatefulWidget {
  const CodeEditorHomeScreen({super.key});

  @override
  State<CodeEditorHomeScreen> createState() => _CodeEditorHomeScreenState();
}

class _CodeEditorHomeScreenState extends State<CodeEditorHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final editor = context.read<CodeEditorProvider>();
      if (!editor.isLoaded) editor.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Editor'),
        actions: [
          IconButton(
            tooltip: 'Open file',
            onPressed: () => _openFile(context),
            icon: const Icon(Icons.folder_open_outlined),
          ),
        ],
      ),
      body: Consumer<CodeEditorProvider>(
        builder: (context, editor, _) {
          if (!editor.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (editor.loadError != null) {
            return Center(child: Text(editor.loadError!));
          }
          final files = editor.files;
          if (files.isEmpty) {
            return _EmptyWorkspace(
              onNew: () => _newFile(context),
              onOpen: () => _openFile(context),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  Text(
                    'Recent files',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _newFile(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...files.expand((f) => [
                    _FileRow(
                      file: f,
                      onTap: () => _openExisting(context, f),
                      onDelete: () => _confirmDelete(context, f),
                    ),
                    const SizedBox(height: 8),
                  ]),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newFile(context),
        icon: const Icon(Icons.add),
        label: const Text('New file'),
      ),
    );
  }

  Future<void> _newFile(BuildContext context) async {
    final kind = await showNewFileSheet(context);
    if (kind == null || !context.mounted) return;
    final editor = context.read<CodeEditorProvider>();
    await editor.createNew(kind);
    if (!context.mounted) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.codeEditorFile,
      arguments: CodeEditorFileArguments(fileId: editor.openFile!.id),
    );
    await editor.refreshIndex();
  }

  Future<void> _openFile(BuildContext context) async {
    final editor = context.read<CodeEditorProvider>();
    final (_, err) = await editor.importFromPicker();
    if (!context.mounted) return;
    if (err != null && err.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    if (editor.openFile == null) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.codeEditorFile,
      arguments: CodeEditorFileArguments(fileId: editor.openFile!.id),
    );
    await editor.refreshIndex();
  }

  Future<void> _openExisting(BuildContext context, WorkspaceFile file) async {
    final editor = context.read<CodeEditorProvider>();
    await editor.openWorkspaceFile(file);
    if (!context.mounted) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.codeEditorFile,
      arguments: CodeEditorFileArguments(fileId: file.id),
    );
    await editor.refreshIndex();
  }

  Future<void> _confirmDelete(BuildContext context, WorkspaceFile file) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${file.displayName}?'),
        content: const Text('This removes the file from your local workspace.'),
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
    final err = await context.read<CodeEditorProvider>().deleteFile(file.id);
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }
}

class _EmptyWorkspace extends StatelessWidget {
  final VoidCallback onNew;
  final VoidCallback onOpen;

  const _EmptyWorkspace({required this.onNew, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.terminal, size: 56, color: primary),
            const SizedBox(height: 16),
            Text(
              'Your Code Workspace',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create or import a file to start coding.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onNew,
              icon: const Icon(Icons.add),
              label: const Text('New file'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Open file'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  final WorkspaceFile file;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FileRow({
    required this.file,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.MMMd().add_jm();
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.35,
          ),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(_iconForKind(file.kind), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${file.kind.label} · ${fmt.format(file.updatedAt.toLocal())}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete ${file.displayName}',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconForKind(EditorFileKind kind) => switch (kind) {
      EditorFileKind.html => Icons.language_outlined,
      EditorFileKind.css => Icons.palette_outlined,
      EditorFileKind.javascript => Icons.javascript_outlined,
      EditorFileKind.php => Icons.code_outlined,
      _ => Icons.description_outlined,
    };
