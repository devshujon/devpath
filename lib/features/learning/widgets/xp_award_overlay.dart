import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/badge.dart';
import '../providers/learning_progress_provider.dart';

/// Full-screen dim overlay shown after a lesson is completed.
///
/// Animates:
///   - "+50 XP" rising and fading in
///   - Progress bar filling from old → new XP ratio
///   - Optional level-up celebration
///   - Optional badge unveils
///
/// Auto-dismisses after [autoCloseAfter] unless [showActions] is true,
/// in which case the user taps a button to continue.
class XpAwardOverlay extends StatefulWidget {
  final CompletionResult result;

  /// XP-to-next-level ratio BEFORE this completion. Combined with the
  /// post-completion ratio (read from the provider via the result) to
  /// animate the bar fill from old → new.
  final double oldProgress;

  /// XP-to-next-level ratio AFTER this completion.
  final double newProgress;

  /// Called when the user taps Continue.
  final VoidCallback? onContinue;

  /// Called when the user taps "Next lesson". Null hides the option.
  final VoidCallback? onNextLesson;

  const XpAwardOverlay({
    super.key,
    required this.result,
    required this.oldProgress,
    required this.newProgress,
    this.onContinue,
    this.onNextLesson,
  });

  /// Pushes the overlay as a transparent route.
  static Future<void> show(
    BuildContext context, {
    required CompletionResult result,
    required double oldProgress,
    required double newProgress,
    VoidCallback? onNextLesson,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => XpAwardOverlay(
          result: result,
          oldProgress: oldProgress,
          newProgress: newProgress,
          onContinue: () => Navigator.of(context).maybePop(),
          onNextLesson: onNextLesson,
        ),
      ),
    );
  }

  @override
  State<XpAwardOverlay> createState() => _XpAwardOverlayState();
}

class _XpAwardOverlayState extends State<XpAwardOverlay>
    with TickerProviderStateMixin {
  late AnimationController _entry;
  late AnimationController _xpRise;
  late AnimationController _barFill;
  late Animation<double> _entryScale;
  late Animation<double> _entryFade;
  late Animation<double> _xpOffset;
  late Animation<double> _xpFade;
  late Animation<double> _barValue;

  @override
  void initState() {
    super.initState();

    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _entryScale = CurvedAnimation(parent: _entry, curve: Curves.easeOutBack);
    _entryFade = CurvedAnimation(parent: _entry, curve: Curves.easeOut);

    _xpRise = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _xpOffset = Tween<double>(begin: 0, end: -40).animate(
      CurvedAnimation(parent: _xpRise, curve: Curves.easeOutCubic),
    );
    _xpFade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 25),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(_xpRise);

    _barFill = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _barValue = Tween<double>(
      begin: widget.oldProgress,
      end: widget.newProgress,
    ).animate(CurvedAnimation(parent: _barFill, curve: Curves.easeOutCubic));

    // Sequence:
    //  - entry pop-in
    //  - 200ms later: XP starts rising
    //  - 400ms later: bar fills
    _entry.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _xpRise.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _barFill.forward();
    });
  }

  @override
  void dispose() {
    _entry.dispose();
    _xpRise.dispose();
    _barFill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A1F28) : Colors.white;
    final result = widget.result;

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _entryFade,
            child: ScaleTransition(
              scale: Tween(begin: 0.8, end: 1.0).animate(_entryScale),
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 380),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Trophy(color: result.newLevel.color),
                    const SizedBox(height: 16),
                    Text(
                      result.levelUp
                          ? 'Level up!'
                          : 'Lesson complete!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (result.levelUp) ...[
                      const SizedBox(height: 6),
                      Text(
                        'You reached ${result.newLevel.label}',
                        style: TextStyle(
                          color: result.newLevel.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    // XP gain animation
                    SizedBox(
                      height: 50,
                      child: AnimatedBuilder(
                        animation: _xpRise,
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _xpOffset.value),
                          child: Opacity(
                            opacity: _xpFade.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C5CE7)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '+${result.xpEarned} XP',
                                style: const TextStyle(
                                  color: Color(0xFF6C5CE7),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Progress bar fill
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedBuilder(
                        animation: _barFill,
                        builder: (_, __) => LinearProgressIndicator(
                          value: _barValue.value,
                          minHeight: 10,
                          backgroundColor: isDark
                              ? const Color(0xFF262B35)
                              : const Color(0xFFE4E7EE),
                          valueColor: AlwaysStoppedAnimation(
                            result.newLevel.color,
                          ),
                        ),
                      ),
                    ),
                    if (result.newlyEarnedBadges.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _BadgesRow(badges: result.newlyEarnedBadges),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onContinue,
                            child: const Text('Done'),
                          ),
                        ),
                        if (widget.onNextLesson != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: widget.onNextLesson,
                              child: const Text(
                                'Next lesson',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Trophy extends StatefulWidget {
  final Color color;
  const _Trophy({required this.color});

  @override
  State<_Trophy> createState() => _TrophyState();
}

class _TrophyState extends State<_Trophy> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  Timer? _settleTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    // Settle after ~3 seconds so it doesn't bobble forever
    _settleTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      _ctrl.stop();
      _ctrl.animateTo(0.5, duration: const Duration(milliseconds: 300));
    });
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        final angle = math.sin(t * math.pi * 2) * 0.05;
        return Transform.rotate(
          angle: angle,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events,
              size: 40,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

class _BadgesRow extends StatelessWidget {
  final List<LearnerBadge> badges;
  const _BadgesRow({required this.badges});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          badges.length == 1 ? 'New badge!' : 'New badges!',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: badges
              .map(
                (b) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: b.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(b.icon, color: b.color, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        b.title,
                        style: TextStyle(
                          color: b.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
