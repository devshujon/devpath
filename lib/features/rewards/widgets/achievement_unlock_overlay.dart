import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/achievement.dart';

/// Full-screen dim overlay shown when an achievement unlocks.
///
/// Animations:
///   - Card pop-in (elasticOut scale)
///   - Trophy circle pulse (looped, settles after a moment)
///   - Confetti dots fall behind the card
class AchievementUnlockOverlay extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementUnlockOverlay({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required Achievement achievement,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.65),
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (ctx, _, __) => AchievementUnlockOverlay(
          achievement: achievement,
          onDismiss: () => Navigator.of(ctx).maybePop(),
        ),
      ),
    );
  }

  @override
  State<AchievementUnlockOverlay> createState() =>
      _AchievementUnlockOverlayState();
}

class _AchievementUnlockOverlayState extends State<AchievementUnlockOverlay>
    with TickerProviderStateMixin {
  late AnimationController _entry;
  late AnimationController _pulse;
  late AnimationController _confetti;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _confetti = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();
  }

  @override
  void dispose() {
    _entry.dispose();
    _pulse.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A1F28) : Colors.white;
    final ach = widget.achievement;

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Stack(
          children: [
            // Confetti pass behind the card
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _confetti,
                  builder: (_, __) => CustomPaint(
                    painter: _ConfettiPainter(
                      progress: _confetti.value,
                      color: ach.color,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _entry,
                  curve: Curves.elasticOut,
                ),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _entry,
                    curve: Curves.easeOut,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    constraints: const BoxConstraints(maxWidth: 360),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: ach.color.withValues(alpha: 0.35),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '🏆',
                          style: TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ACHIEVEMENT UNLOCKED',
                          style: TextStyle(
                            color: ach.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, __) {
                            final scale =
                                1.0 + 0.06 * (1 - _pulse.value);
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      ach.color.withValues(alpha: 0.95),
                                      ach.color.withValues(alpha: 0.7),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          ach.color.withValues(alpha: 0.5),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  ach.icon,
                                  color: Colors.white,
                                  size: 44,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        Text(
                          ach.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ach.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(height: 1.4),
                        ),
                        if (ach.xpReward > 0) ...[
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C5CE7)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFF6C5CE7),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '+${ach.xpReward} XP',
                                  style: const TextStyle(
                                    color: Color(0xFF6C5CE7),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Already added to your total',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? const Color(0xFF8A929D)
                                      : const Color(0xFF5D6670),
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: widget.onDismiss,
                            style: FilledButton.styleFrom(
                              backgroundColor: ach.color,
                              minimumSize: const Size.fromHeight(44),
                            ),
                            child: const Text(
                              'Awesome!',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lightweight confetti — deterministic seed so layout is the same every
/// time but visually random. Doesn't allocate per frame.
class _ConfettiPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;

  _ConfettiPainter({required this.progress, required this.color});

  // Pre-computed dot offsets/speeds. Indexes used as seeds.
  static const int _dotCount = 36;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var i = 0; i < _dotCount; i++) {
      final hash = (i * 1103515245 + 12345) & 0x7fffffff;
      final xRatio = ((hash % 1000) / 1000.0);
      final speed = 0.6 + ((hash >> 10) % 400) / 1000.0; // 0.6..1.0
      final size01 = 4.0 + ((hash >> 20) % 60) / 10.0; // 4..10
      final hueShift = ((hash >> 5) % 4);

      final x = size.width * xRatio;
      // Fall from above the visible area to below; ease out at end.
      final y = (-30 + (size.height + 60) * (progress * speed))
          .clamp(-30.0, size.height + 30.0);

      // Slight horizontal drift
      final drift = math.sin(progress * math.pi * 2 + i) * 12;

      paint.color = _shift(color, hueShift)
          .withValues(alpha: (1 - progress).clamp(0.0, 1.0) * 0.9);

      final rect = Rect.fromCenter(
        center: Offset(x + drift, y),
        width: size01,
        height: size01 * 1.4,
      );
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(progress * math.pi * 4 + i * 0.4);
      canvas.translate(-rect.center.dx, -rect.center.dy);
      canvas.drawRect(rect, paint);
      canvas.restore();
    }
  }

  Color _shift(Color base, int variant) {
    switch (variant) {
      case 0:
        return base;
      case 1:
        return const Color(0xFFFFB020);
      case 2:
        return const Color(0xFF6C5CE7);
      default:
        return const Color(0xFF00B894);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress || old.color != color;
}
