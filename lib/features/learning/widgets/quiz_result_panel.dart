import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/lesson.dart';

/// Polished quiz result layout (pass / fail).
class QuizResultPanel extends StatefulWidget {
  const QuizResultPanel({
    super.key,
    required this.lesson,
    required this.correct,
    required this.total,
    required this.passed,
    required this.xpReward,
    required this.xpClaimed,
    required this.claimInProgress,
    required this.onClaimXp,
    required this.onClose,
    required this.onRetry,
  });

  final Lesson lesson;
  final int correct;
  final int total;
  final bool passed;
  final int xpReward;
  final bool xpClaimed;
  final bool claimInProgress;
  final VoidCallback onClaimXp;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  @override
  State<QuizResultPanel> createState() => _QuizResultPanelState();
}

class _QuizResultPanelState extends State<QuizResultPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;

  bool _startedAnimation = false;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scoreAnimation = CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_startedAnimation) return;
    _startedAnimation = true;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _scoreController.value = 1;
    } else {
      _scoreController.forward();
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  double get _percent =>
      widget.total == 0 ? 0 : (widget.correct / widget.total) * 100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final subtle = isDark ? AppColors.darkSubtle : AppColors.lightSubtle;
    final passed = widget.passed;
    final perfect = widget.correct == widget.total && widget.total > 0;

    final headline = passed
        ? (perfect ? 'Excellent Work!' : 'Quiz Completed!')
        : 'Keep Practicing!';
    final subtitle = passed
        ? 'Great job mastering this lesson.'
        : 'Review the lesson and try again — you need 70% to pass.';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.lesson.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Semantics(
                      label: passed ? 'Quiz passed' : 'Quiz not passed',
                      child: Icon(
                        passed
                            ? (perfect
                                ? Icons.emoji_events_rounded
                                : Icons.celebration_rounded)
                            : Icons.psychology_alt_outlined,
                        size: 72,
                        color: passed ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      headline,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: subtle,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _ScoreCard(
                      surface: surface,
                      text: text,
                      subtle: subtle,
                      correct: widget.correct,
                      total: widget.total,
                      percent: _percent,
                      passed: passed,
                      xpLabel: passed
                          ? (widget.xpClaimed
                              ? '+${widget.xpReward} XP claimed'
                              : '+${widget.xpReward} XP')
                          : null,
                      animation: _scoreAnimation,
                    ),
                    if (perfect && passed) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Perfect score!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    if (passed) ...[
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: widget.claimInProgress || widget.xpClaimed
                            ? null
                            : widget.onClaimXp,
                        icon: widget.claimInProgress
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                widget.xpClaimed
                                    ? Icons.check_circle
                                    : Icons.stars_rounded,
                                size: 20,
                              ),
                        label: Text(
                          widget.claimInProgress
                              ? 'Claiming…'
                              : widget.xpClaimed
                                  ? 'XP claimed'
                                  : 'Claim ${widget.xpReward} XP',
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: widget.onClose,
                        child: const Text('Close'),
                      ),
                    ] else ...[
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: widget.onRetry,
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text('Retake quiz'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: widget.onClose,
                        child: const Text('Back to lesson'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.surface,
    required this.text,
    required this.subtle,
    required this.correct,
    required this.total,
    required this.percent,
    required this.passed,
    required this.xpLabel,
    required this.animation,
  });

  final Color surface;
  final Color text;
  final Color subtle;
  final int correct;
  final int total;
  final double percent;
  final bool passed;
  final String? xpLabel;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: passed
              ? AppColors.accent.withValues(alpha: 0.35)
              : Colors.black12,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final t = animation.value;
                return SizedBox(
                  width: 88,
                  height: 88,
                  child: CustomPaint(
                    painter: _RingPainter(
                      progress: (percent / 100) * t,
                      color: passed ? AppColors.accent : AppColors.warning,
                      trackColor: subtle.withValues(alpha: 0.25),
                    ),
                    child: Center(
                      child: Text(
                        '${(percent * t).round()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: text,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$correct / $total correct',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${percent.round()}% accuracy',
                    style: TextStyle(color: subtle, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        passed ? Icons.check_circle : Icons.info_outline,
                        size: 18,
                        color: passed ? AppColors.accent : AppColors.warning,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        passed ? 'Passed' : 'Not passed',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: passed ? AppColors.accent : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  if (xpLabel != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      xpLabel!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 8.0;
    final rect = Offset.zero & size;
    final start = -math.pi / 2;
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect.deflate(stroke / 2),
      0,
      2 * math.pi,
      false,
      track,
    );
    if (progress > 0) {
      canvas.drawArc(rect.deflate(stroke / 2), start, sweep, false, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
