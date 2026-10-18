import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/certificate.dart';

/// Renders the certificate. Wrap with a [RepaintBoundary] for capture.
/// 4:3 landscape; renders even when [issuedAt] is null (locked state).
class CertificateView extends StatelessWidget {
  final Certificate certificate;
  final DateTime? issuedAt;
  final String holderName;

  /// When true, overlays a subtle PREVIEW watermark — for the locked state.
  final bool showPreviewWatermark;

  const CertificateView({
    super.key,
    required this.certificate,
    this.issuedAt,
    this.holderName = 'DevPath Learner',
    this.showPreviewWatermark = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = certificate.accentColor;
    final issued = issuedAt;

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accent.withValues(alpha: 0.4), width: 2),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: CustomPaint(painter: _BorderPainter(accent))),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header
                  Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: accent, width: 1.5),
                        ),
                        child: Icon(certificate.icon, color: accent, size: 30),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'DEVPATH',
                        style: TextStyle(
                          color: accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'CERTIFICATE OF COMPLETION',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF555555),
                          fontSize: 10,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Body
                  Column(
                    children: [
                      const Text(
                        'This certifies that',
                        style: TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        holderName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF1A1A1A),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Georgia',
                          decoration: TextDecoration.underline,
                          decorationColor: accent.withValues(alpha: 0.6),
                          decorationThickness: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'has successfully earned the',
                        style: TextStyle(color: Color(0xFF777777), fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          certificate.title.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Footer
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80,
                              height: 1,
                              color: const Color(0xFF555555),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Issued',
                              style: TextStyle(
                                color: Color(0xFF555555),
                                fontSize: 9,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              issued != null
                                  ? DateFormat.yMMMMd().format(issued)
                                  : '— pending —',
                              style: const TextStyle(
                                color: Color(0xFF222222),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accent, width: 1.5),
                          color: accent.withValues(alpha: 0.08),
                        ),
                        child: Center(
                          child: Text(
                            '✦',
                            style: TextStyle(color: accent, fontSize: 26),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (showPreviewWatermark)
              Center(
                child: Transform.rotate(
                  angle: -0.35,
                  child: Text(
                    'PREVIEW',
                    style: TextStyle(
                      color: accent.withValues(alpha: 0.15),
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
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

class _BorderPainter extends CustomPainter {
  final Color color;
  _BorderPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const inset = 10.0;
    final rect = Rect.fromLTWH(
      inset, inset, size.width - inset * 2, size.height - inset * 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      paint,
    );

    const cornerSize = 14.0;
    final cornerPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const tl = Offset(inset, inset);
    final tr = Offset(size.width - inset, inset);
    final bl = Offset(inset, size.height - inset);
    final br = Offset(size.width - inset, size.height - inset);
    canvas.drawLine(tl, tl + const Offset(cornerSize, 0), cornerPaint);
    canvas.drawLine(tl, tl + const Offset(0, cornerSize), cornerPaint);
    canvas.drawLine(tr, tr + const Offset(-cornerSize, 0), cornerPaint);
    canvas.drawLine(tr, tr + const Offset(0, cornerSize), cornerPaint);
    canvas.drawLine(bl, bl + const Offset(cornerSize, 0), cornerPaint);
    canvas.drawLine(bl, bl + const Offset(0, -cornerSize), cornerPaint);
    canvas.drawLine(br, br + const Offset(-cornerSize, 0), cornerPaint);
    canvas.drawLine(br, br + const Offset(0, -cornerSize), cornerPaint);
  }

  @override
  bool shouldRepaint(_BorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
