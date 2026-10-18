import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../logic/quiz_question_timer_config.dart';

class QuizTimeExpiredPanel extends StatelessWidget {
  const QuizTimeExpiredPanel({
    super.key,
    required this.adBusy,
    required this.adStatusMessage,
    required this.onWatchAdRetry,
    required this.onFreeRestart,
    required this.onExitQuiz,
  });

  final bool adBusy;
  final String? adStatusMessage;
  final VoidCallback onWatchAdRetry;
  final VoidCallback onFreeRestart;
  final VoidCallback onExitQuiz;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        border: Border(
          top: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Time's Up!",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You can watch one short rewarded video to get another '
              '${QuizQuestionTimerConfig.perQuestionDuration.inSeconds} seconds on this question, restart the quiz for free, or exit.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: adBusy ? null : onWatchAdRetry,
              icon: adBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_circle_outline, size: 20),
              label: const Text('Watch ad to retry'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: adBusy ? null : onFreeRestart,
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Restart quiz — free'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: adBusy ? null : onExitQuiz,
              child: const Text('Exit quiz'),
            ),
            if (adStatusMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                adStatusMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

}
