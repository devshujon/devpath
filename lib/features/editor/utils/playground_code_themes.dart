import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';

/// Dark editor theme aligned with VS Code–style surfaces.
CodeThemeData playgroundCodeTheme({required bool isDark}) {
  if (!isDark) {
    return const CodeThemeData(
      styles: {
        'root': const TextStyle(color: Color(0xFF1A1A1A)),
        'comment': const TextStyle(color: Color(0xFF008000)),
        'keyword': const TextStyle(color: Color(0xFF0000FF)),
        'string': const TextStyle(color: Color(0xFFA31515)),
        'tag': const TextStyle(color: Color(0xFF800000)),
        'attribute': const TextStyle(color: Color(0xFFFF0000)),
      },
    );
  }
  return const CodeThemeData(
    styles: {
      'root': TextStyle(color: Color(0xFFD4D4D4)),
      'comment': const TextStyle(color: Color(0xFF6A9955)),
      'keyword': const TextStyle(color: Color(0xFF569CD6)),
      'string': const TextStyle(color: Color(0xFFCE9178)),
      'tag': const TextStyle(color: Color(0xFF4EC9B0)),
      'attribute': const TextStyle(color: Color(0xFF9CDCFE)),
    },
  );
}
