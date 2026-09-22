import 'package:flutter/material.dart';

import '../models/quiz_item.dart';

/// The post-answer explanation panel. Always shown, always free — this
/// is the learning moment and is never gated behind ads or currency.
class QuizExplanationPanel extends StatelessWidget {
  final QuizItem item;
  final bool wasCorrect;

  const QuizExplanationPanel({
    super.key,
    required this.item,
    required this.wasCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = wasCorrect ? const Color(0xFF00B894) : const Color(0xFFE17055);
    final exp = item.explanation;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.10 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(wasCorrect ? Icons.check_circle : Icons.cancel, color: accent),
              const SizedBox(width: 8),
              Text(
                wasCorrect ? 'Correct' : 'Not quite',
                style: TextStyle(
                    color: accent, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (exp.whyCorrect.isNotEmpty) ...[
            _label('Why this is correct', const Color(0xFF00B894)),
            const SizedBox(height: 4),
            Text(exp.whyCorrect, style: const TextStyle(height: 1.5)),
          ],
          if (exp.whyOthersWrong.isNotEmpty) ...[
            const SizedBox(height: 12),
            _label('Why the others are wrong', const Color(0xFFE17055)),
            const SizedBox(height: 4),
            for (final w in exp.whyOthersWrong)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(child: Text(w, style: const TextStyle(height: 1.45))),
                  ],
                ),
              ),
          ],
          if (exp.bestPractice != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0984E3).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline,
                      size: 18, color: Color(0xFF0984E3)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(exp.bestPractice!,
                        style: const TextStyle(height: 1.45)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _label(String text, Color c) => Text(
        text.toUpperCase(),
        style: TextStyle(
            color: c,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8),
      );
}
