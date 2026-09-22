import 'package:flutter/material.dart';

import '../models/quiz_item.dart';

/// Renders the input UI for any [QuizItem] and reports the user's answer.
///
/// Stateful only to own a TextEditingController for the text types. Give
/// it a ValueKey(item.id) so a fresh state (and empty field) is created
/// per question. When [revealed] is true (after submit) the input is
/// locked and selection options are colored correct / incorrect.
class QuizItemView extends StatefulWidget {
  final QuizItem item;
  final QuizAnswer answer;
  final bool revealed;
  final ValueChanged<QuizAnswer> onChanged;

  const QuizItemView({
    super.key,
    required this.item,
    required this.answer,
    required this.revealed,
    required this.onChanged,
  });

  @override
  State<QuizItemView> createState() => _QuizItemViewState();
}

class _QuizItemViewState extends State<QuizItemView> {
  final _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Color get _accent => Theme.of(context).colorScheme.primary;
  bool get _enabled => !widget.revealed;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return switch (item) {
      final McqItem i => _single(i.options, i.correctIndex),
      final OutputPredictionItem i => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_code(i.code, i.lang), const SizedBox(height: 12), _single(i.options, i.correctIndex)],
        ),
      final FindBugItem i => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_code(i.code, i.lang), const SizedBox(height: 12), _single(i.options, i.correctIndex)],
        ),
      final MultiSelectItem i => _multi(i.options, i.correctIndices),
      final FillBlankItem i => _text(hint: i.hint),
      final CompleteCodeItem i => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_code(i.stub, i.lang), const SizedBox(height: 12), _text(hint: 'Type the missing part')],
        ),
    };
  }

  // ── single-select (mcq / outputPrediction / findBug) ──
  Widget _single(List<String> options, int correctIndex) {
    return Column(
      children: [
        for (var i = 0; i < options.length; i++)
          _optionTile(
            label: options[i],
            selected: widget.answer.selectedIndex == i,
            isCorrect: i == correctIndex,
            multi: false,
            onTap: _enabled
                ? () => widget.onChanged(QuizAnswer()..selectedIndex = i)
                : null,
          ),
      ],
    );
  }

  // ── multi-select ──
  Widget _multi(List<String> options, Set<int> correctIndices) {
    return Column(
      children: [
        for (var i = 0; i < options.length; i++)
          _optionTile(
            label: options[i],
            selected: widget.answer.selectedSet.contains(i),
            isCorrect: correctIndices.contains(i),
            multi: true,
            onTap: _enabled
                ? () {
                    final next = {...widget.answer.selectedSet};
                    next.contains(i) ? next.remove(i) : next.add(i);
                    widget.onChanged(QuizAnswer()..selectedSet = next);
                  }
                : null,
          ),
      ],
    );
  }

  Widget _optionTile({
    required String label,
    required bool selected,
    required bool isCorrect,
    required bool multi,
    required VoidCallback? onTap,
  }) {
    Color border = Theme.of(context).dividerColor;
    Color? fill;
    if (widget.revealed) {
      if (isCorrect) {
        border = const Color(0xFF00B894);
        fill = const Color(0xFF00B894).withValues(alpha: 0.12);
      } else if (selected) {
        border = const Color(0xFFE17055);
        fill = const Color(0xFFE17055).withValues(alpha: 0.12);
      }
    } else if (selected) {
      border = _accent;
      fill = _accent.withValues(alpha: 0.10);
    }

    final icon = multi
        ? (selected ? Icons.check_box : Icons.check_box_outline_blank)
        : (selected
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: selected || (widget.revealed && isCorrect) ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: selected ? _accent : Theme.of(context).hintColor),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14.5))),
              if (widget.revealed && isCorrect)
                const Icon(Icons.check, size: 18, color: Color(0xFF00B894)),
            ],
          ),
        ),
      ),
    );
  }

  // ── text input (fillBlank / completeCode) ──
  Widget _text({String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _textCtrl,
          enabled: _enabled,
          autocorrect: false,
          enableSuggestions: false,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontFamilyFallback: ['Menlo', 'Courier'],
          ),
          decoration: InputDecoration(
            hintText: hint ?? 'Type your answer',
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          onChanged: (v) => widget.onChanged(QuizAnswer()..text = v),
        ),
      ],
    );
  }

  Widget _code(String code, String lang) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0E1116),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
            child: Text(lang.toUpperCase(),
                style: const TextStyle(
                    color: Color(0xFF6E7681),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontFamilyFallback: ['Menlo', 'Courier'],
                fontSize: 12.5,
                height: 1.5,
                color: Color(0xFFE6E6E6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
