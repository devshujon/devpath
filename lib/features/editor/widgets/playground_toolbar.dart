import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_project.dart';
import '../providers/playground_provider.dart';
import '../providers/projects_list_provider.dart';

class PlaygroundToolbar extends StatelessWidget {
  const PlaygroundToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaygroundProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF141820) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF262B35) : const Color(0xFFE4E7EE);

    return Material(
      color: bg,
      elevation: 0,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: Row(
          children: [
            Icon(
              _iconForTab(provider.selectedTab),
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                provider.projectTitle ?? provider.selectedTab.filename,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: provider.projectTitle == null
                          ? 'monospace'
                          : null,
                      fontFamilyFallback: provider.projectTitle == null
                          ? const ['Menlo', 'Courier']
                          : null,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (provider.isDirty) ...[
              const SizedBox(width: 6),
              const _UnsavedDot(),
            ],
            const Spacer(),
            _IconAction(
              tooltip: 'Reset all tabs',
              icon: Icons.refresh,
              onPressed: () => _confirmReset(context, provider),
            ),
            _IconAction(
              tooltip: 'Copy ${provider.selectedTab.label}',
              icon: Icons.copy_outlined,
              onPressed: () => _onCopy(context, provider),
            ),
            _IconAction(
              tooltip: 'Save',
              icon: provider.isExistingProject
                  ? Icons.save_outlined
                  : Icons.save_as_outlined,
              onPressed: () => _onSave(context, provider),
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

  IconData _iconForTab(PlaygroundTab tab) => switch (tab) {
        PlaygroundTab.html => Icons.code,
        PlaygroundTab.css => Icons.brush_outlined,
        PlaygroundTab.js => Icons.bolt_outlined,
      };

  // ── Actions ──

  Future<void> _onCopy(
    BuildContext context,
    PlaygroundProvider provider,
  ) async {
    final label = await provider.copyCurrentTab();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _onSave(
    BuildContext context,
    PlaygroundProvider provider,
  ) async {
    UserProject? saved;
    if (provider.isExistingProject) {
      saved = await provider.saveUpdate();
      // saveUpdate returns null if the underlying record was deleted —
      // fall through to "save as new" in that case.
      if (saved == null) {
        if (!context.mounted) return;
        saved = await _saveAsNewFlow(context, provider);
      }
    } else {
      if (!context.mounted) return;
      saved = await _saveAsNewFlow(context, provider);
    }

    if (saved == null || !context.mounted) return;
    final savedProject = saved;

    // Defer the cross-tree notify + SnackBar to the next frame.
    //
    // Saving from the playground can complete right as a dialog is
    // dismissing. Calling ProjectsListProvider.upsert() (which fires
    // notifyListeners across the whole tree, including the projects
    // list still mounted in the IndexedStack) DURING that teardown
    // window is what trips the framework's
    //   '_dependents.isEmpty': is not true
    // assertion. Running it after the current frame settles avoids
    // mutating provider state while elements are mid-unmount.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      try {
        context.read<ProjectsListProvider>().upsert(savedProject);
      } catch (_) {
        // Provider not in tree — list will refresh on next visit
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  Future<UserProject?> _saveAsNewFlow(
    BuildContext context,
    PlaygroundProvider provider,
  ) async {
    final title = await _promptForTitle(context);
    if (title == null) return null;
    return provider.saveAsNew(title: title);
  }

  Future<String?> _promptForTitle(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Save project'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Project title',
              hintText: 'My first page',
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLength: 60,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter a title';
              return null;
            },
            onFieldSubmitted: (_) {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogCtx, controller.text.trim());
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogCtx, controller.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _confirmReset(
    BuildContext context,
    PlaygroundProvider provider,
  ) async {
    if (provider.isDefault && !provider.isExistingProject) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset playground?'),
        content: const Text(
          'This will replace HTML, CSS, and JS with the starter templates '
          'and detach from the current project.',
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

class _IconAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _IconAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      iconSize: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}

class _UnsavedDot extends StatelessWidget {
  const _UnsavedDot();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Unsaved changes',
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
