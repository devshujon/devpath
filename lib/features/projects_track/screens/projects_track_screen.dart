import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../models/track_project.dart';
import '../providers/projects_track_provider.dart';
import '../widgets/track_project_card.dart';

class ProjectsTrackScreen extends StatefulWidget {
  const ProjectsTrackScreen({super.key});
  static const route = '/projects-track';

  @override
  State<ProjectsTrackScreen> createState() => _ProjectsTrackScreenState();
}

class _ProjectsTrackScreenState extends State<ProjectsTrackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProjectsTrackProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectsTrackProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Projects'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: provider.totalCount == 0
                ? 0
                : provider.completedCount / provider.totalCount,
            minHeight: 4,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final difficulty in const [
            Difficulty.beginner,
            Difficulty.intermediate,
            Difficulty.advanced,
          ]) ...[
            _DifficultyHeader(
              difficulty: difficulty,
              completed: provider.completedInDifficulty(difficulty),
              total: provider.totalInDifficulty(difficulty),
            ),
            const SizedBox(height: 12),
            _ProjectsGrid(
              projects: provider.all
                  .where((p) => p.difficulty == difficulty)
                  .toList(),
              statusOf: provider.statusOf,
              onOpen: (p) => _open(context, p),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  void _open(BuildContext context, TrackProject p) {
    Navigator.pushNamed(
      context,
      AppRoutes.projectDetail,
      arguments: ProjectDetailArguments(projectId: p.id),
    );
  }
}

class _ProjectsGrid extends StatelessWidget {
  final List<TrackProject> projects;
  final TrackProjectStatus Function(TrackProject) statusOf;
  final void Function(TrackProject) onOpen;

  const _ProjectsGrid({
    required this.projects,
    required this.statusOf,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 600 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: projects.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisExtent: 240,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (_, i) {
            final p = projects[i];
            return TrackProjectCard(
              project: p,
              status: statusOf(p),
              onTap: () => onOpen(p),
            );
          },
        );
      },
    );
  }
}

class _DifficultyHeader extends StatelessWidget {
  final Difficulty difficulty;
  final int completed;
  final int total;

  const _DifficultyHeader({
    required this.difficulty,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 24,
              decoration: BoxDecoration(
                color: difficulty.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              difficulty.label,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              '$completed / $total',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: difficulty.color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(difficulty.color),
          ),
        ),
      ],
    );
  }
}

class ProjectDetailArguments {
  final String projectId;
  const ProjectDetailArguments({required this.projectId});
}
