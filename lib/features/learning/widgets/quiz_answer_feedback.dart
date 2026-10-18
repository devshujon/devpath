import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/lesson.dart';

/// Shown after a wrong submission or when an answer was revealed.
class QuizAnswerFeedback extends StatelessWidget {
  const QuizAnswerFeedback({
    super.key,
    required this.question,
    required this.wasIncorrect,
    required this.revealed,
    required this.adBusy,
    required this.adStatusMessage,
    required this.onFreeRestart,
    required this.onRewardedRetry,
    required this.onRewardedReveal,
    required this.onContinue,
    this.showContinue = true,
  });

  final QuizQuestion question;
  final bool wasIncorrect;
  final bool revealed;
  final bool adBusy;
  final String? adStatusMessage;
  final VoidCallback onFreeRestart;
  final VoidCallback onRewardedRetry;
  final VoidCallback onRewardedReveal;
  final VoidCallback onContinue;
  final bool showContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: wasIncorrect
            ? AppColors.danger.withValues(alpha: 0.08)
            : AppColors.accent.withValues(alpha: 0.08),
        border: Border(
          top: BorderSide(
            color: wasIncorrect ? AppColors.danger : AppColors.accent,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  wasIncorrect ? Icons.close_rounded : Icons.check_rounded,
                  color: wasIncorrect ? AppColors.danger : AppColors.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    revealed && !wasIncorrect
                        ? 'Answer revealed'
                        : wasIncorrect
                            ? 'Not quite — try a different approach'
                            : 'Correct!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (revealed) ...[
              const SizedBox(height: 12),
              Text(
                'Correct answer: ${question.options[question.correctIndex]}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              if (question.explanation != null &&
                  question.explanation!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  question.explanation!,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ],
            if (wasIncorrect) ...[
              const SizedBox(height: 16),
              Text(
                'Try Again (free) restarts from question 1. '
                'Watching one short video unlocks another full attempt or reveals the answer — separate rewards.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.lightSubtle,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: adBusy ? null : onFreeRestart,
                icon: const Icon(Icons.restart_alt, size: 18),
                label: const Text('Try Again — free'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: adBusy ? null : onRewardedRetry,
                icon: adBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_circle_outline, size: 18),
                label: const Text('Watch ad for another attempt'),
              ),
              if (!revealed) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: adBusy ? null : onRewardedReveal,
                  icon: const Icon(Icons.lightbulb_outline, size: 18),
                  label: const Text('Reveal answer — watch ad'),
                ),
              ],
            ],
            if (adStatusMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                adStatusMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
            if (showContinue) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: adBusy ? null : onContinue,
                child: Text(wasIncorrect ? 'Continue quiz' : 'Next question'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
