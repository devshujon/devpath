import 'package:flutter/material.dart';

import '../../learning/logic/lesson_progression.dart';
import '../../learning/models/lesson.dart';

/// One node on the lesson path. Visually communicates four states:
///   completed  — solid track-colored circle with a checkmark
///   current    — solid + pulsing ring (the next lesson to tackle)
///   available  — solid + dimmed (unlocked but not next-up)
///   locked     — outlined gray with a lock glyph
///
/// Sized at 64dp by default. Tap fires `onTap` only when unlocked.
class LessonPathNode extends StatefulWidget {
  final Lesson lesson;
  final bool isCurrent;
  final VoidCallback? onTap;
  final double size;

  const LessonPathNode({
    super.key,
    required this.lesson,
    required this.isCurrent,
    this.onTap,
    this.size = 64,
  });

  @override
  State<LessonPathNode> createState() => _LessonPathNodeState();
}

class _LessonPathNodeState extends State<LessonPathNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final accent = lesson.track.color;
    final size = widget.size;
    final visual = resolveLessonVisualState(
      isCompleted: lesson.isCompleted,
      isLocked: lesson.isLocked,
      isCurrent: widget.isCurrent,
    );
    final isLocked = visual == LessonVisualState.locked;
    final isCompleted = visual == LessonVisualState.completed;

    // completed > current/unlocked > locked — never draw a finished
    // lesson as locked, even if a catalog insert would lock it.
    final Color fill;
    final Color iconColor;
    final IconData iconData;
    double opacity = 1.0;

    switch (visual) {
      case LessonVisualState.locked:
        fill = Colors.transparent;
        iconColor = Theme.of(context).disabledColor;
        iconData = Icons.lock_outline;
        opacity = 0.55;
      case LessonVisualState.completed:
        fill = accent;
        iconColor = Colors.white;
        iconData = Icons.check;
      case LessonVisualState.current:
        fill = accent;
        iconColor = Colors.white;
        iconData = _iconForTrack(lesson.track);
      case LessonVisualState.unlocked:
        fill = accent;
        iconColor = Colors.white;
        iconData = _iconForTrack(lesson.track);
        opacity = 0.75;
    }

    final semanticLabel = switch (visual) {
      LessonVisualState.completed => '${lesson.title}, completed',
      LessonVisualState.current => '${lesson.title}, current lesson',
      LessonVisualState.unlocked => '${lesson.title}, available',
      LessonVisualState.locked => '${lesson.title}, locked',
    };

    return Opacity(
      opacity: opacity,
      child: Semantics(
        button: !isLocked || isCompleted,
        enabled: !isLocked || isCompleted,
        label: semanticLabel,
        child: GestureDetector(
        onTap: isLocked && !isCompleted ? null : widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            // Pulse ring only renders for the "current" node — it's the
            // affordance that draws the user's eye to "do this next".
            final pulseT = widget.isCurrent && !isLocked && !isCompleted
                ? _pulse.value
                : 0.0;

            return SizedBox(
              width: size + 24,
              height: size + 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (pulseT > 0)
                    Container(
                      width: size + (pulseT * 20),
                      height: size + (pulseT * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.18 * (1 - pulseT)),
                      ),
                    ),
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: fill,
                      border: Border.all(
                        color: isLocked
                            ? Theme.of(context)
                                .disabledColor
                                .withValues(alpha: 0.4)
                            : accent,
                        width: isLocked ? 2 : 3,
                      ),
                      boxShadow: isLocked || !widget.isCurrent
                          ? null
                          : [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.35),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                    ),
                    child: Icon(
                      iconData,
                      color: iconColor,
                      size: size * 0.45,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      ),
    );
  }

  IconData _iconForTrack(LessonTrack t) {
    return switch (t) {
      LessonTrack.html => Icons.code,
      LessonTrack.css => Icons.palette_outlined,
      LessonTrack.js => Icons.bolt_outlined,
      LessonTrack.capstone => Icons.workspace_premium_outlined,
    };
  }
}
