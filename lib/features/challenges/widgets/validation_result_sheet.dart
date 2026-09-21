import 'package:flutter/material.dart';

import '../models/validation_result.dart';

/// Bottom sheet shown after Submit. Variant depends on [result.passed].
class ValidationResultSheet extends StatelessWidget {
  final ValidationResult result;
  final int xpAwarded;
  final bool isDailyBonus;
  final bool levelUp;
  final String? levelLabel;
  final VoidCallback onClose;
  final VoidCallback? onNextChallenge;
  final VoidCallback? onTryAgain;
  final VoidCallback? onShowHint;

  const ValidationResultSheet({
    super.key,
    required this.result,
    required this.xpAwarded,
    required this.isDailyBonus,
    required this.levelUp,
    required this.levelLabel,
    required this.onClose,
    this.onNextChallenge,
    this.onTryAgain,
    this.onShowHint,
  });

  static Future<void> show(
    BuildContext context, {
    required ValidationResult result,
    required int xpAwarded,
    bool isDailyBonus = false,
    bool levelUp = false,
    String? levelLabel,
    VoidCallback? onNextChallenge,
    VoidCallback? onTryAgain,
    VoidCallback? onShowHint,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ValidationResultSheet(
        result: result,
        xpAwarded: xpAwarded,
        isDailyBonus: isDailyBonus,
        levelUp: levelUp,
        levelLabel: levelLabel,
        onClose: () => Navigator.of(context).maybePop(),
        onNextChallenge: onNextChallenge,
        onTryAgain: onTryAgain,
        onShowHint: onShowHint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1F28) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (result.passed)
                _SuccessBody(
                  xpAwarded: xpAwarded,
                  score: result.score,
                  isDailyBonus: isDailyBonus,
                  levelUp: levelUp,
                  levelLabel: levelLabel,
                )
              else
                _FailureBody(result: result, isDark: isDark),
              const SizedBox(height: 20),
              _Actions(
                passed: result.passed,
                onClose: onClose,
                onNextChallenge: onNextChallenge,
                onTryAgain: onTryAgain,
                onShowHint: onShowHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessBody extends StatefulWidget {
  final int xpAwarded;
  final int score;
  final bool isDailyBonus;
  final bool levelUp;
  final String? levelLabel;

  const _SuccessBody({
    required this.xpAwarded,
    required this.score,
    required this.isDailyBonus,
    required this.levelUp,
    required this.levelLabel,
  });

  @override
  State<_SuccessBody> createState() => _SuccessBodyState();
}

class _SuccessBodyState extends State<_SuccessBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _c, curve: Curves.elasticOut);
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScaleTransition(
          scale: _scale,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF00B894).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Color(0xFF00B894),
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Challenge complete!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Score: ${widget.score} / 100',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star,
                  color: Color(0xFF6C5CE7), size: 18),
              const SizedBox(width: 6),
              Text(
                '+${widget.xpAwarded} XP',
                style: const TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (widget.isDailyBonus) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB020).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DAILY 2×',
                    style: TextStyle(
                      color: Color(0xFFB37800),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.levelUp && widget.levelLabel != null) ...[
          const SizedBox(height: 12),
          Text(
            'Level up! You reached ${widget.levelLabel}',
            style: const TextStyle(
              color: Color(0xFFFFB020),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _FailureBody extends StatelessWidget {
  final ValidationResult result;
  final bool isDark;

  const _FailureBody({required this.result, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final ratio = result.totalRules == 0
        ? 0.0
        : result.passedRules / result.totalRules;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Color(0xFFEF4444),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Not quite yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${result.passedRules} of ${result.totalRules} requirements met (${result.score}/100)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: isDark
                ? const Color(0xFF262B35)
                : const Color(0xFFE4E7EE),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFEF4444)),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Missing',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView(
            shrinkWrap: true,
            children: result.missing.map((m) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        m.area,
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        m.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final bool passed;
  final VoidCallback onClose;
  final VoidCallback? onNextChallenge;
  final VoidCallback? onTryAgain;
  final VoidCallback? onShowHint;

  const _Actions({
    required this.passed,
    required this.onClose,
    this.onNextChallenge,
    this.onTryAgain,
    this.onShowHint,
  });

  @override
  Widget build(BuildContext context) {
    if (passed) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onClose,
              child: const Text('Done'),
            ),
          ),
          if (onNextChallenge != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onNextChallenge,
                child: const Text('Next challenge'),
              ),
            ),
          ],
        ],
      );
    }
    return Column(
      children: [
        Row(
          children: [
            if (onShowHint != null)
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.lightbulb_outline, size: 16),
                  label: const Text('Hint'),
                  onPressed: onShowHint,
                ),
              ),
            if (onShowHint != null) const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Try again'),
                onPressed: onTryAgain ?? onClose,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
