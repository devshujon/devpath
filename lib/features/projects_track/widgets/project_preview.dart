import 'package:flutter/material.dart';

import '../models/track_project.dart';

/// Synthetic "preview image" — gradient + project icon. Keeps the APK
/// small while still giving each project a distinct visual identity.
class ProjectPreview extends StatelessWidget {
  final TrackProject project;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final bool showIcon;

  const ProjectPreview({
    super.key,
    required this.project,
    this.height,
    this.borderRadius,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius is BorderRadius
        ? borderRadius as BorderRadius
        : BorderRadius.circular(12);
    final h = height ?? 120;

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        height: h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: project.previewGradient.isEmpty
                ? const [Color(0xFF6C5CE7), Color(0xFFA29BFE)]
                : project.previewGradient,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _StripesPainter()),
            if (showIcon)
              Center(
                child: Icon(
                  project.previewIcon,
                  size: h * 0.4,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1.5;
    const gap = 14.0;
    for (var x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StripesPainter oldDelegate) => false;
}
