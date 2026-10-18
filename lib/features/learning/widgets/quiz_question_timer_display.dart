import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Countdown chip for the active question (accessibility-friendly, no live region spam).
class QuizQuestionTimerDisplay extends StatelessWidget {
  const QuizQuestionTimerDisplay({
    super.key,
    required this.remaining,
    required this.expired,
    required this.paused,
    required this.adBusy,
  });

  final Duration remaining;
  final bool expired;
  final bool paused;
  final bool adBusy;

  @override
  Widget build(BuildContext context) {
    final seconds = remaining.inSeconds.clamp(0, 9999);
    final warning = !expired && seconds <= 10;
    final label = expired
        ? "Time's up"
        : paused
            ? 'Timer paused'
            : adBusy
                ? 'Loading ad…'
                : '${seconds}s left';

    return Semantics(
      label: expired ? "Time's up" : 'Time remaining $seconds seconds',
      liveRegion: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: expired
              ? AppColors.danger.withValues(alpha: 0.12)
              : warning
                  ? AppColors.warning.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: expired
                ? AppColors.danger
                : warning
                    ? AppColors.warning
                    : AppColors.primary.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: expired
                ? AppColors.danger
                : warning
                    ? AppColors.warning
                    : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
