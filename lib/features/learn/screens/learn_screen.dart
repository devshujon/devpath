import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../learning/models/lesson.dart';
import '../../learning/providers/learning_progress_provider.dart';
import '../widgets/lesson_path_node.dart';
import '../widgets/lesson_start_sheet.dart';

/// Sololearn-style path view. Renders every lesson in [LessonsCatalog]
/// as a node on a snaking vertical path, grouped into difficulty
/// sections, filterable by track. Replaces the legacy Hive-backed
/// LearnScreen placeholder that depended on a never-implemented
/// LessonLoader.
///
/// Locking, completion, and "current" detection come from
/// [LearningProgressProvider]. This widget is purely presentational —
/// no state mutations happen here.
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  /// null = "All tracks"
  LessonTrack? _filter;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        actions: [
          // Compact streak indicator — mirrors the dashboard
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _StreakChip(days: progress.streakDays),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Track filter chips
          _TrackFilterRow(
            selected: _filter,
            onChanged: (t) => setState(() => _filter = t),
          ),
          const SizedBox(height: 16),

          // Difficulty sections — beginner → intermediate → advanced
          for (final difficulty in Difficulty.values)
            ..._sectionFor(progress, difficulty),
        ],
      ),
    );
  }

  List<Widget> _sectionFor(
    LearningProgressProvider progress,
    Difficulty difficulty,
  ) {
    final all = progress.lessonsByDifficulty(difficulty);
    final lessons = _filter == null
        ? all
        : all.where((l) => l.track == _filter).toList();
    if (lessons.isEmpty) return const [];

    // One global "current" lesson — the recommended next — so only one
    // node pulses even when multiple difficulties are unlocked.
    final currentId = progress.recommendedNextLesson?.id;

    final completedCount = lessons.where((l) => l.isCompleted).length;

    return [
      _DifficultyHeader(
        difficulty: difficulty,
        completed: completedCount,
        total: lessons.length,
      ),
      const SizedBox(height: 8),
      ..._pathNodes(lessons, currentId),
      const SizedBox(height: 24),
    ];
  }

  /// Build the snaking column of nodes. Horizontal offset follows a
  /// sine wave so the path feels alive instead of stuck on the y-axis.
  /// Spacing between nodes is constant; horizontal sway is ±0.55 of
  /// the available width.
  List<Widget> _pathNodes(List<Lesson> lessons, String? currentId) {
    final out = <Widget>[];
    for (var i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];
      // sin gives smooth -1..1; scale to -0.55..0.55 so nodes stay
      // well inside the screen even on narrow phones.
      final t = lessons.length == 1
          ? 0.0
          : i / (lessons.length - 1);
      final dx = math.sin(t * math.pi * 2.4) * 0.55;

      out.add(
        Align(
          alignment: Alignment(dx, 0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: LessonPathNode(
              lesson: lesson,
              isCurrent: lesson.id == currentId,
              onTap: () => LessonStartSheet.show(context, lesson),
            ),
          ),
        ),
      );
    }
    return out;
  }
}

// ─────────────────────────────────────────────────────────────────────
//  Header for each difficulty section — colored bar + progress fraction
// ─────────────────────────────────────────────────────────────────────

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
    final color = difficulty.color;
    final ratio = total == 0 ? 0.0 : completed / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 22,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                difficulty.label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Text(
                '$completed / $total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 3,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  Track filter chip row
// ─────────────────────────────────────────────────────────────────────

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
      color: selected ? color : color.withValues(alpha: 0.12),
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

// ─────────────────────────────────────────────────────────────────────
//  Compact streak chip in AppBar
// ─────────────────────────────────────────────────────────────────────

class _StreakChip extends StatelessWidget {
  final int days;

  const _StreakChip({required this.days});

  @override
  Widget build(BuildContext context) {
    final hot = days > 0;
    final color = hot ? const Color(0xFFFF6B35) : Theme.of(context).disabledColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          hot
              ? Icons.local_fire_department
              : Icons.local_fire_department_outlined,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '$days',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
