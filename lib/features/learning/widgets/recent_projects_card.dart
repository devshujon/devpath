import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../editor/models/user_project.dart';
import '../../editor/providers/projects_list_provider.dart';

class RecentProjectsCard extends StatelessWidget {
  const RecentProjectsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectsListProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recent = projects.visible.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.folder_outlined, size: 18),
            const SizedBox(width: 8),
            Text(
              'Recent projects',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
            ),
            const Spacer(),
            if (projects.totalCount > 0)
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.projects),
                child: const Text('See all'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          _EmptyRow(isDark: isDark)
        else
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: recent.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _MiniProjectCard(
                project: recent[i],
                isDark: isDark,
                onTap: () => _openProject(context, recent[i]),
              ),
            ),
          ),
      ],
    );
  }

  void _openProject(BuildContext context, UserProject project) {
    Navigator.pushNamed(
      context,
      AppRoutes.playground,
      arguments: PlaygroundArguments(projectId: project.id),
    );
  }
}

class _MiniProjectCard extends StatelessWidget {
  final UserProject project;
  final bool isDark;
  final VoidCallback onTap;

  const _MiniProjectCard({
    required this.project,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Material(
        color: isDark ? const Color(0xFF141820) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF262B35)
                    : const Color(0xFFE4E7EE),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.code,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatRelative(project.updatedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? const Color(0xFF8A929D)
                            : const Color(0xFF5D6670),
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatRelative(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

class _EmptyRow extends StatelessWidget {
  final bool isDark;
  const _EmptyRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141820) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              isDark ? const Color(0xFF262B35) : const Color(0xFFE4E7EE),
        ),
      ),
      child: Center(
        child: Text(
          'No saved projects yet. Open the Playground to start.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? const Color(0xFF8A929D)
                    : const Color(0xFF5D6670),
              ),
        ),
      ),
    );
  }
}
