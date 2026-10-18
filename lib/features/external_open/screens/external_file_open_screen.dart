import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/routing/app_routes.dart';
import '../../code_editor/models/editor_file_type.dart';
import '../../code_editor/providers/code_editor_provider.dart';
import '../../code_editor/screens/code_editor_file_screen.dart';
import '../../editor/services/project_storage.dart';
import '../../editor/models/user_project.dart';
import '../models/external_file_kind.dart';
import '../models/external_open_payload.dart';
import '../services/external_file_export_service.dart';
import '../utils/external_html_preview.dart';
import 'external_file_preview_screen.dart';

export '../../code_editor/screens/code_editor_file_screen.dart'
    show CodeEditorFileArguments;

/// Shown when Android delivers a supported file via Open with / Send.
class ExternalFileOpenScreen extends StatelessWidget {
  const ExternalFileOpenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final payload =
        ModalRoute.of(context)?.settings.arguments as ExternalOpenPayload?;
    if (payload == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Open file')),
        body: const Center(child: Text('No file to open.')),
      );
    }

    final kind = payload.kind;
    final sizeLabel = _formatSize(payload.sizeBytes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open file'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(
            _iconFor(kind),
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            payload.displayName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('Type: ${kind.label}'),
          if (sizeLabel != null) Text('Size: $sizeLabel'),
          if (payload.mimeType != null && payload.mimeType!.isNotEmpty)
            Text('MIME: ${payload.mimeType}'),
          const SizedBox(height: 8),
          Text(
            'The original file on your device is not modified unless you explicitly export and choose to overwrite it elsewhere.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          if (kind == ExternalFileKind.unsupported) ...[
            const Text(
              'This file type is not supported. DevPath can open HTML, CSS, JavaScript, JSON, and XML.',
            ),
          ] else ...[
            FilledButton.icon(
              onPressed: () => _openPreview(context, payload),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Preview'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => _openEdit(context, payload),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _saveAsProject(context, payload),
              icon: const Icon(Icons.folder_outlined),
              label: const Text('Save as DevPath project'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _export(context, payload),
              icon: const Icon(Icons.upload_file),
              label: const Text('Export as new file'),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static String? _formatSize(int? bytes) {
    if (bytes == null) return null;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static IconData _iconFor(ExternalFileKind kind) => switch (kind) {
        ExternalFileKind.html => Icons.language,
        ExternalFileKind.css => Icons.palette_outlined,
        ExternalFileKind.javascript => Icons.bolt_outlined,
        ExternalFileKind.json => Icons.data_object,
        ExternalFileKind.xml => Icons.code,
        ExternalFileKind.unsupported => Icons.block,
      };

  void _openPreview(BuildContext context, ExternalOpenPayload payload) {
    final doc = buildExternalPreviewDocument(
      kind: payload.kind,
      source: payload.content,
    );
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ExternalFilePreviewScreen(
          title: payload.displayName,
          htmlDocument: doc,
          payload: payload,
        ),
      ),
    );
  }

  Future<void> _openEdit(BuildContext context, ExternalOpenPayload payload) async {
    switch (payload.kind) {
      case ExternalFileKind.html:
      case ExternalFileKind.css:
      case ExternalFileKind.javascript:
        await _openPlaygroundEdit(context, payload);
      case ExternalFileKind.json:
      case ExternalFileKind.xml:
        await _openCodeEditorEdit(context, payload);
      case ExternalFileKind.unsupported:
        break;
    }
  }

  Future<void> _openPlaygroundEdit(
    BuildContext context,
    ExternalOpenPayload payload,
  ) async {
    final starter = switch (payload.kind) {
      ExternalFileKind.html => {
          'html': payload.content,
          'css': '',
          'js': '',
        },
      ExternalFileKind.css => {
          'html': '<!-- Linked CSS -->\n<p>Preview after Run</p>',
          'css': payload.content,
          'js': '',
        },
      ExternalFileKind.javascript => {
          'html': '<!-- Linked JS -->\n<p>Check preview console</p>',
          'css': '',
          'js': payload.content,
        },
      _ => {'html': payload.content, 'css': '', 'js': ''},
    };

    if (!context.mounted) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.playground,
      arguments: PlaygroundArguments(starterCode: starter),
    );
  }

  Future<void> _openCodeEditorEdit(
    BuildContext context,
    ExternalOpenPayload payload,
  ) async {
    final kind = payload.kind == ExternalFileKind.json
        ? EditorFileKind.json
        : EditorFileKind.xml;
    final editor = context.read<CodeEditorProvider>();
    final (file, error) = await editor.importExternal(
      fileName: payload.displayName,
      kind: kind,
      content: payload.content,
    );
    if (!context.mounted) return;
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Could not import file')),
      );
      return;
    }
    await Navigator.pushNamed(
      context,
      AppRoutes.codeEditorFile,
      arguments: CodeEditorFileArguments(fileId: file.id),
    );
  }

  Future<void> _saveAsProject(
    BuildContext context,
    ExternalOpenPayload payload,
  ) async {
    // Read latest buffers from a ephemeral provider if user edited — for
    // simplicity re-save from payload; playground edits need export from UI.
    final title = payload.displayName.replaceAll(RegExp(r'\.[^.]+$'), '');
    final project = UserProject(
      id: const Uuid().v4(),
      title: title.isEmpty ? 'Imported file' : title,
      htmlCode: payload.kind == ExternalFileKind.html ? payload.content : '',
      cssCode: payload.kind == ExternalFileKind.css ? payload.content : '',
      jsCode: payload.kind == ExternalFileKind.javascript ? payload.content : '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await ProjectStorage.instance.saveProject(project);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved as DevPath project')),
    );
  }

  Future<void> _export(
    BuildContext context,
    ExternalOpenPayload payload,
  ) async {
    final ok = await ExternalFileExportService.saveCopy(
      fileName: payload.displayName,
      kind: payload.kind,
      content: payload.content,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Export saved' : 'Export cancelled or failed'),
      ),
    );
  }
}
