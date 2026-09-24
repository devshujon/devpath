import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/lesson_type.dart';

/// On Android, [WebViewWidget] platform views can draw over routes pushed
/// on top (e.g. lesson quiz). Curriculum figures use this renderer instead.
bool get useFlutterFigureRendererOnAndroid {
  if (kIsWeb) return false;
  return Platform.isAndroid ||
      defaultTargetPlatform == TargetPlatform.android;
}

String figureSpecToPlainText(String spec) {
  var s = spec;
  s = s.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  s = s.replaceAll(RegExp(r'</div>', caseSensitive: false), '\n');
  s = s.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
  s = s.replaceAll(RegExp(r'<[^>]*>'), '');
  s = s
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
  s = s.replaceAll(RegExp(r'[ \t]+\n'), '\n');
  s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return s.trim();
}

class FigureAndroidFallback extends StatelessWidget {
  final String spec;
  final double height;

  const FigureAndroidFallback({
    super.key,
    required this.spec,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = figureSpecToPlainText(spec);
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161A21) : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lessonBorder(context)),
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          text.isEmpty ? 'Diagram' : text,
          style: LessonType.codeStyle(context).copyWith(height: 1.45),
        ),
      ),
    );
  }
}
