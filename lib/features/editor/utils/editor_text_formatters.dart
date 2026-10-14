import 'package:flutter/services.dart';

/// Tab → two spaces (shared with [CodeEditorPane]).
class TabIndentFormatter extends TextInputFormatter {
  const TabIndentFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.text.contains('\t')) return newValue;
    final replaced = newValue.text.replaceAll('\t', '  ');
    final offset = newValue.selection.baseOffset +
        (replaced.length - newValue.text.length);
    return newValue.copyWith(
      text: replaced,
      selection:
          TextSelection.collapsed(offset: offset.clamp(0, replaced.length)),
    );
  }
}

/// Auto-closes brackets and quotes where practical.
class BracketAutoCloseFormatter extends TextInputFormatter {
  const BracketAutoCloseFormatter();

  static const _pairs = {
    '(': ')',
    '[': ']',
    '{': '}',
    '"': '"',
    "'": "'",
  };

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length != oldValue.text.length + 1) {
      return newValue;
    }
    final inserted = newValue.text.substring(
      newValue.selection.baseOffset - 1,
      newValue.selection.baseOffset,
    );
    final close = _pairs[inserted];
    if (close == null) return newValue;
    final withClose = newValue.text.replaceRange(
      newValue.selection.baseOffset,
      newValue.selection.baseOffset,
      close,
    );
    return TextEditingValue(
      text: withClose,
      selection: TextSelection.collapsed(offset: newValue.selection.baseOffset),
    );
  }

}
