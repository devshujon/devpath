import 'package:flutter/material.dart';

/// Minimal inline markdown → TextSpan parser.
///
/// Supports **bold**, *italic*, and `inline code`. Deliberately tiny and
/// dependency-free (no flutter_markdown) since lessons only need inline
/// emphasis, and shipping a full markdown engine offline is overkill.
/// Unbalanced markers are treated as literal text, so malformed content
/// never throws.
class MarkdownLite extends StatelessWidget {
  final String data;
  final TextStyle? style;

  const MarkdownLite(this.data, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final base = (style ?? Theme.of(context).textTheme.bodyMedium ?? const TextStyle())
        .copyWith(height: style?.height ?? 1.55);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final codeBg = isDark ? const Color(0xFF2A2D34) : const Color(0xFFEEF0F3);
    final codeFg = isDark ? const Color(0xFFE6C07B) : const Color(0xFFB05A00);

    return Text.rich(
      TextSpan(children: _parse(data, base, codeBg, codeFg)),
    );
  }

  static List<InlineSpan> _parse(
    String src,
    TextStyle base,
    Color codeBg,
    Color codeFg,
  ) {
    final spans = <InlineSpan>[];
    final buf = StringBuffer();

    void flush() {
      if (buf.isNotEmpty) {
        spans.add(TextSpan(text: buf.toString(), style: base));
        buf.clear();
      }
    }

    int i = 0;
    while (i < src.length) {
      final c = src[i];

      // `inline code`
      if (c == '`') {
        final end = src.indexOf('`', i + 1);
        if (end > i) {
          flush();
          spans.add(TextSpan(
            text: src.substring(i + 1, end),
            style: base.copyWith(
              fontFamily: 'monospace',
              fontFamilyFallback: const ['Menlo', 'Courier'],
              color: codeFg,
              backgroundColor: codeBg,
              fontSize: (base.fontSize ?? 14) * 0.95,
            ),
          ));
          i = end + 1;
          continue;
        }
      }

      // **bold**
      if (c == '*' && i + 1 < src.length && src[i + 1] == '*') {
        final end = src.indexOf('**', i + 2);
        if (end > i) {
          flush();
          spans.add(TextSpan(
            text: src.substring(i + 2, end),
            style: base.copyWith(fontWeight: FontWeight.w700),
          ));
          i = end + 2;
          continue;
        }
      }

      // *italic*
      if (c == '*') {
        final end = src.indexOf('*', i + 1);
        if (end > i) {
          flush();
          spans.add(TextSpan(
            text: src.substring(i + 1, end),
            style: base.copyWith(fontStyle: FontStyle.italic),
          ));
          i = end + 1;
          continue;
        }
      }

      buf.write(c);
      i++;
    }
    flush();
    return spans;
  }
}
