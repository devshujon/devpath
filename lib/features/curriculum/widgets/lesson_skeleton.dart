import 'package:flutter/material.dart';

import '../theme/lesson_type.dart';

/// Polished placeholder shown while rich lesson JSON is loading.
class LessonSkeleton extends StatefulWidget {
  const LessonSkeleton({super.key});

  @override
  State<LessonSkeleton> createState() => _LessonSkeletonState();
}

class _LessonSkeletonState extends State<LessonSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = lessonCardBg(context);
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final t = 0.45 + (_pulse.value * 0.35);
        Color bar([double w = 1]) => base.withValues(alpha: t * w);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(bar(), height: 22, width: 180),
            const SizedBox(height: 14),
            _box(bar(0.9), height: 14),
            const SizedBox(height: 8),
            _box(bar(0.8), height: 14, widthFactor: 0.92),
            const SizedBox(height: 8),
            _box(bar(0.7), height: 14, widthFactor: 0.7),
            const SizedBox(height: 20),
            _box(bar(), height: 96),
            const SizedBox(height: 16),
            _box(bar(0.85), height: 14, widthFactor: 0.88),
            const SizedBox(height: 8),
            _box(bar(0.75), height: 14, widthFactor: 0.8),
            const SizedBox(height: 8),
            _box(bar(0.7), height: 14, widthFactor: 0.6),
          ],
        );
      },
    );
  }

  Widget _box(Color color, {required double height, double? width, double widthFactor = 1}) {
    return FractionallySizedBox(
      widthFactor: width == null ? widthFactor : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
