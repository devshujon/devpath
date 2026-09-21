import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../models/user_project.dart';
import '../providers/projects_list_provider.dart';
import '../services/html_import_service.dart';
import '../services/project_storage.dart';
import '../widgets/project_card.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});
  static const route = '/projects';

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load on first frame so we don't block initial paint
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProjectsListProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectsListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        actions: [
          IconButton(
            tooltip: 'Import HTML file',
            icon: const Icon(Icons.upload_file_outlined),
            onPressed: () => _importHtml(context),
          ),
          IconButton(
            tooltip: 'New project',
            icon: const Icon(Icons.add),
            onPressed: () => _newProject(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchField(
            controller: _searchCtrl,
            onChanged: provider.setQuery,
          ),
          Expanded(child: _buildBody(context, provider)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProjectsListProvider provider) {
    if (provider.loading && provider.totalCount == 0) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.totalCount == 0) {
      return _EmptyState(onCreate: () => _newProject(context));
    }
    if (provider.visible.isEmpty) {
      return _NoMatchesState(query: provider.query);
    }

    return RefreshIndicator(
      onRefresh: () => provider.load(force: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cols = constraints.maxWidth >= 900
              ? 4
              : constraints.maxWidth >= 600
                  ? 3
                  : 2;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              childAspectRatio: 0.78,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.visible.length,
            itemBuilder: (_, i) {
              final p = provider.visible[i];
              return ProjectCard(
                project: p,
                onContinue: () => _openProject(context, p),
                onDelete: () => _confirmDelete(context, provider, p),
              );
            },
          );
        },
      ),
    );
  }

  void _newProject(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.playground).then((_) {
      if (!context.mounted) return;
      unawaited(context.read<ProjectsListProvider>().load(force: true));
    });
  }

  Future<void> _importHtml(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    HtmlImportResult? result;
    try {
      result = await HtmlImportService.pickAndRead();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not read that file.')),
      );
      return;
    }
    if (result == null) return; // user cancelled

    if (!context.mounted) return;
    unawaited(
      Navigator.pushNamed(
        context,
        AppRoutes.playground,
        arguments: PlaygroundArguments(
          starterCode: {'html': result.html, 'css': '', 'js': ''},
        ),
      ).then((_) {
        if (!context.mounted) return;
        unawaited(context.read<ProjectsListProvider>().load(force: true));
      }),
    );
  }

  Future<void> _openProject(BuildContext context, UserProject project) async {
    // Bump lastOpened in storage (non-blocking)
    unawaited(ProjectStorage.instance.touchOpened(project.id));

    await Navigator.pushNamed(
      context,
      AppRoutes.playground,
      arguments: PlaygroundArguments(projectId: project.id),
    );
    if (!context.mounted) return;
    // Refresh list — user may have saved updates
    unawaited(context.read<ProjectsListProvider>().load(force: true));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProjectsListProvider provider,
    UserProject project,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text(
          '"${project.title}" will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await provider.deleteProject(project.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${project.title}" deleted')),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search projects',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          isDense: true,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open,
                size: 44,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No projects yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a playground session and tap Save to keep your work.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? const Color(0xFF8A929D)
                        : const Color(0xFF5D6670),
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create your first project'),
              onPressed: onCreate,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMatchesState extends StatelessWidget {
  final String query;
  const _NoMatchesState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 56),
            const SizedBox(height: 12),
            Text('No projects match "$query"'),
          ],
        ),
      ),
    );
  }
}
