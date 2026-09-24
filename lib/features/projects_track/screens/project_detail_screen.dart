import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../learning/data/lessons_catalog.dart';
import '../../learning/providers/learning_progress_provider.dart';
import '../data/projects_track_catalog.dart';
import '../models/track_project.dart';
import '../providers/projects_track_provider.dart';
import '../widgets/project_preview.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key});
  static const route = '/project-detail';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments
        as ProjectDetailArguments?;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Open a project from the list.')),
      );
    }
    final project = ProjectsTrackCatalog.byId(args.projectId);
    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Project not found: ${args.projectId}')),
      );
    }
    return _DetailView(project: project);
  }
}

class _DetailView extends StatelessWidget {
  final TrackProject project;
  const _DetailView({required this.project});

  @override
  Widget build(BuildContext context) {
    final tracks = context.watch<ProjectsTrackProvider>();
    final learning = context.watch<LearningProgressProvider>();
    final status = tracks.statusOf(project);
    final isLocked = status == TrackProjectStatus.locked;
    final isCompleted = status == TrackProjectStatus.completed;

    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProjectPreview(project: project, height: 160),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: project.difficulty.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  project.difficulty.label,
                  style: TextStyle(
                    color: project.difficulty.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star_outline,
                  size: 14, color: Color(0xFF6C5CE7)),
              const SizedBox(width: 3),
              Text(
                '+${project.xpReward} XP',
                style: const TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (isCompleted)
                const _DoneChip()
              else if (status == TrackProjectStatus.inProgress)
                const _InProgressChip(),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            project.description,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 22),
          Text(
            'What to build',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...project.instructions.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: project.difficulty.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${e.key + 1}',
                          style: TextStyle(
                            color: project.difficulty.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e.value,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (project.requiredLessons.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text(
              'Required lessons',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...project.requiredLessons.map((id) {
              final lesson = LessonsCatalog.byId(id);
              final done = learning.completedLessons.contains(id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: done
                          ? const Color(0xFF00B894)
                          : Theme.of(context).disabledColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lesson?.title ?? id,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: done
                                  ? Theme.of(context).disabledColor
                                  : null,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Open in Playground'),
                  onPressed:
                      isLocked ? null : () => _openInPlayground(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                  ),
                  icon: Icon(isCompleted ? Icons.check : Icons.flag),
                  label: Text(isCompleted ? 'Completed' : 'Mark Complete'),
                  onPressed: (isLocked || isCompleted)
                      ? null
                      : () => _confirmComplete(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openInPlayground(BuildContext context) async {
    await context.read<ProjectsTrackProvider>().markOpened(project.id);
    if (!context.mounted) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.playground,
      arguments: PlaygroundArguments(
        starterCode: {
          'html': project.starterHtml,
          'css': project.starterCss,
          'js': project.starterJs,
        },
      ),
    );
  }

  Future<void> _confirmComplete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mark project complete?'),
        content: Text(
          "You'll earn +${project.xpReward} XP. Only mark complete "
          "once you've actually built it — you can always come back to polish.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark complete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final tracks = context.read<ProjectsTrackProvider>();
    final marked = await tracks.markCompleted(project.id);
    if (!context.mounted || !marked) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Project complete! +${project.xpReward} XP awarded.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _DoneChip extends StatelessWidget {
  const _DoneChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF00B894),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, color: Colors.white, size: 12),
          SizedBox(width: 3),
          Text(
            'Completed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InProgressChip extends StatelessWidget {
  const _InProgressChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB020),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'In progress',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
