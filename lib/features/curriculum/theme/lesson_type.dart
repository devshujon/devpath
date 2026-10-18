import 'package:flutter/material.dart';

/// Mobile-first typography + spacing for rich lesson content.
///
/// Scales slightly between 360dp and 430dp so 360×640 stays readable
/// without giant headings on compact phones.
class LessonType {
  LessonType._();

  static double _lerp(BuildContext context, double compact, double roomy) {
    final width = MediaQuery.sizeOf(context).width;
    final t = ((width - 360) / 70).clamp(0.0, 1.0);
    return compact + (roomy - compact) * t;
  }

  static double get textScale => 1.0;

  static double title(BuildContext c) => _lerp(c, 26, 29);
  static double section(BuildContext c) => _lerp(c, 20, 22);
  static double subhead(BuildContext c) => _lerp(c, 17, 19);
  static double body(BuildContext c) => _lerp(c, 15, 16.5);
  static double secondary(BuildContext c) => _lerp(c, 13, 14);
  static double code(BuildContext c) => _lerp(c, 13, 14);

  static double get bodyHeight => 1.55;
  static double get titleHeight => 1.25;

  /// Horizontal content inset. ~16–20dp as specified.
  static double horizontalPadding(BuildContext c) {
    final width = MediaQuery.sizeOf(c).width;
    if (width < 370) return 16;
    if (width < 400) return 18;
    return 20;
  }

  static EdgeInsets pagePadding(BuildContext c) {
    final h = horizontalPadding(c);
    final bottom = MediaQuery.paddingOf(c).bottom + 28;
    return EdgeInsets.fromLTRB(h, 8, h, bottom);
  }

  static TextStyle titleStyle(BuildContext c, {Color? color}) => TextStyle(
        fontSize: title(c),
        fontWeight: FontWeight.w800,
        height: titleHeight,
        color: color,
        letterSpacing: -0.3,
      );

  static TextStyle sectionStyle(BuildContext c, {Color? color}) => TextStyle(
        fontSize: section(c),
        fontWeight: FontWeight.w800,
        height: 1.3,
        color: color,
      );

  static TextStyle subheadStyle(BuildContext c, {Color? color}) => TextStyle(
        fontSize: subhead(c),
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: color,
      );

  static TextStyle bodyStyle(BuildContext c, {Color? color}) {
    final base = Theme.of(c).textTheme.bodyMedium;
    return (base ?? const TextStyle()).copyWith(
      fontSize: body(c),
      height: bodyHeight,
      color: color ?? base?.color,
    );
  }

  static TextStyle secondaryStyle(BuildContext c, {Color? color}) => TextStyle(
        fontSize: secondary(c),
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: color ?? Theme.of(c).hintColor,
      );

  static TextStyle codeStyle(BuildContext c, {Color? color}) => TextStyle(
        fontFamily: 'monospace',
        fontFamilyFallback: const ['Menlo', 'Courier', 'monospace'],
        fontSize: code(c),
        height: 1.5,
        color: color ?? const Color(0xFFE6E6E6),
      );
}

Color lessonCardBg(BuildContext c) => Theme.of(c).brightness == Brightness.dark
    ? const Color(0xFF161A21)
    : const Color(0xFFF7F8FA);

Color lessonBorder(BuildContext c) => Theme.of(c).brightness == Brightness.dark
    ? const Color(0xFF262A32)
    : const Color(0xFFE4E7EE);

Color lessonCodeBg(BuildContext c) => Theme.of(c).brightness == Brightness.dark
    ? const Color(0xFF1E1E1E)
    : const Color(0xFF0E1116);

/// Minimum comfortable touch target.
const double kLessonMinTap = 44;
