import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../learning/widgets/recent_projects_card.dart';
import '../providers/projects_list_provider.dart';
import '../services/html_import_service.dart';
import '../services/lesson_templates.dart';
/// Mobile-first IDE hub: playground, templates, projects, import, recents.
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<ProjectsListProvider>().load());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Studio'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'Build pages on your phone',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'HTML, CSS, and JavaScript with run preview and local projects.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            _HubCard(
              icon: Icons.play_circle_filled,
              title: 'Playground',
              subtitle: 'Multi-file sandbox · Run · Save',
              onTap: () => Navigator.pushNamed(context, AppRoutes.playground),
              primary: true,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _QuickTile(
                    icon: Icons.add_circle_outline,
                    label: 'New project',
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.playground,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickTile(
                    icon: Icons.upload_file_outlined,
                    label: 'Import HTML',
                    onTap: () => _importHtml(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const RecentProjectsCard(),
            const SizedBox(height: 20),
            Text(
              'Library',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            _HubCard(
              icon: Icons.dashboard_customize_outlined,
              title: 'Starter templates',
              subtitle:
                  '${LessonTemplates.all.length} lessons — portfolio, forms, JS',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.lessons),
            ),
            const SizedBox(height: 10),
            _HubCard(
              icon: Icons.folder_open_outlined,
              title: 'My projects',
              subtitle: 'Saved playground work on this device',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.projects),
            ),
            const SizedBox(height: 10),
            _HubCard(
              icon: Icons.terminal,
              title: 'File workspace',
              subtitle: 'Single-file editor with import (advanced)',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.codeEditor),
            ),
            if (isDark) const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _importHtml(BuildContext context) async {
    HtmlImportResult? result;
    try {
      result = await HtmlImportService.pickAndRead();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read that file.')),
      );
      return;
    }
    if (result == null || !context.mounted) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.playground,
      arguments: PlaygroundArguments(
        starterCode: {'html': result.html, 'css': '', 'js': ''},
      ),
    );
    if (!context.mounted) return;
    unawaited(context.read<ProjectsListProvider>().load(force: true));
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool primary;

  const _HubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: primary
          ? primaryColor.withValues(alpha: isDark ? 0.18 : 0.08)
          : (isDark ? const Color(0xFF141820) : Colors.white),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: primary
                  ? primaryColor.withValues(alpha: 0.35)
                  : (isDark
                      ? const Color(0xFF262B35)
                      : const Color(0xFFE4E7EE)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.45,
          ),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Column(
            children: [
              Icon(icon, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
