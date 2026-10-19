import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../models/lesson.dart';
import '../widgets/track_filter_row.dart';
import '../providers/learning_progress_provider.dart';
import '../widgets/lesson_tile.dart';

/// Roadmap with optional track filter. With 37 lessons across 4 tracks,
/// rendering everything in one scroll is dense; the filter chip row lets
/// users focus on one language at a time. Filter state is screen-local —
/// it's a UX affordance, not part of the persistent progress model.
class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});
  static const route = '/roadmap';

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  /// null = "All tracks"
  LessonTrack? _filter;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Learning Roadmap')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TrackFilterRow(
            selected: _filter,
            onChanged: (t) => setState(() => _filter = t),
          ),
          const SizedBox(height: 16),
          for (final difficulty in Difficulty.values) ...[
            ..._sectionFor(progress, difficulty),
          ],
        ],
      ),
    );
  }

  List<Widget> _sectionFor(
    LearningProgressProvider progress,
    Difficulty difficulty,
  ) {
    final all = progress.lessonsByDifficulty(difficulty);
    final filtered = _filter == null
        ? all
        : all.where((l) => l.track == _filter).toList();
    if (filtered.isEmpty) return const [];

    final completed = filtered.where((l) => l.isCompleted).length;

    return [
      _DifficultyHeader(
        difficulty: difficulty,
        completed: completed,
        total: filtered.length,
      ),
      const SizedBox(height: 10),
      ...filtered.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LessonTile(
                lesson: e.value,
                index: e.key,
                onTap: () => _openLesson(context, e.value),
              ),
            ),
          ),
      const SizedBox(height: 20),
    ];
  }

  void _openLesson(BuildContext context, Lesson lesson) {
    Navigator.pushNamed(
      context,
      AppRoutes.lessonDetail,
      arguments: LessonDetailArguments(lessonId: lesson.id),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Text(
                '$completed / $total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
      ),
    );
  }
}
