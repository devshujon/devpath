import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../models/lesson.dart';
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
          _TrackFilterRow(
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

class _TrackFilterRow extends StatelessWidget {
  final LessonTrack? selected;
  final ValueChanged<LessonTrack?> onChanged;

  const _TrackFilterRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'All',
            color: Theme.of(context).colorScheme.primary,
            selected: selected == null,
            onTap: () => onChanged(null),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'HTML',
            color: LessonTrack.html.color,
            selected: selected == LessonTrack.html,
            onTap: () => onChanged(LessonTrack.html),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'CSS',
            color: LessonTrack.css.color,
            selected: selected == LessonTrack.css,
            onTap: () => onChanged(LessonTrack.css),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'JS',
            color: LessonTrack.js.color,
            selected: selected == LessonTrack.js,
            onTap: () => onChanged(LessonTrack.js),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
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
