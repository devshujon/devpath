import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Ensures the quiz body never fails silently when layout constraints collapse.
class QuizBodyShell extends StatelessWidget {
  final Widget child;

  const QuizBodyShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < 72) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Quiz layout error: body height is ${constraints.maxHeight.toStringAsFixed(0)}px. '
                'Try back and open the quiz again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }
        return ColoredBox(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBg
              : AppColors.lightBg,
          child: child,
        );
      },
    );
  }
}
