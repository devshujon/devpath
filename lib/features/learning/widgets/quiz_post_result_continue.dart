import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../logic/quiz_post_result_flow.dart';
import '../models/lesson.dart';

/// Shown after the result screen closes: optional rewarded ad, then continue.
class QuizPostResultContinuePanel extends StatelessWidget {
  const QuizPostResultContinuePanel({
    super.key,
    required this.phase,
    required this.nextLesson,
    required this.adStatusMessage,
    required this.onNext,
    required this.navigateInProgress,
  });

  final QuizPostResultPhase phase;
  final Lesson? nextLesson;
  final String? adStatusMessage;
  final VoidCallback? onNext;
  final bool navigateInProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final subtle = isDark ? AppColors.darkSubtle : AppColors.lightSubtle;

    final showNext = QuizPostResultFlowLogic.shouldShowNextButton(phase);
    final loadingAd = phase == QuizPostResultPhase.loadingRewardedAd;
    final showingAd = phase == QuizPostResultPhase.showingRewardedAd;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (loadingAd && !showNext) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 20),
                Text(
                  'Preparing your next step…',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ] else if (showingAd) ...[
                Text(
                  'Thanks for learning with DevPath',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ] else if (showNext) ...[
                Icon(
                  Icons.route_rounded,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  nextLesson == null
                      ? 'You reached the end of this path'
                      : 'Ready for your next lesson?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (nextLesson != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    nextLesson!.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(color: subtle),
                  ),
                ],
                if (adStatusMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    adStatusMessage!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: subtle),
                  ),
                ],
                const SizedBox(height: 28),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: navigateInProgress ? null : onNext,
                  child: navigateInProgress
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          QuizPostResultFlowLogic.nextButtonLabel(
                            nextLesson: nextLesson,
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
