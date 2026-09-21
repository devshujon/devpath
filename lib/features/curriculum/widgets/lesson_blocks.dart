import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/lesson_block.dart';
import '../models/lesson_content.dart';
import '../theme/lesson_type.dart';
import 'figure_view.dart';
import 'markdown_lite.dart';

const double kBlockGap = 16;

// ── Summary ──────────────────────────────────────────────────────────
class SummaryBlockView extends StatelessWidget {
  final SummaryBlock block;
  final Color accent;
  const SummaryBlockView(this.block, this.accent, {super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Lesson summary',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: accent, width: 4)),
        ),
        child: MarkdownLite(
          block.md,
          style: LessonType.bodyStyle(context),
        ),
      ),
    );
  }
}

// ── Heading ──────────────────────────────────────────────────────────
class HeadingBlockView extends StatelessWidget {
  final HeadingBlock block;
  const HeadingBlockView(this.block, {super.key});

  @override
  Widget build(BuildContext context) {
    final style = block.level <= 1
        ? LessonType.titleStyle(context)
        : block.level == 2
            ? LessonType.sectionStyle(context)
            : LessonType.subheadStyle(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(block.text, style: style),
    );
  }
}

// ── Prose ────────────────────────────────────────────────────────────
class ProseBlockView extends StatelessWidget {
  final ProseBlock block;
  const ProseBlockView(this.block, {super.key});

  @override
  Widget build(BuildContext context) => MarkdownLite(
        block.md,
        style: LessonType.bodyStyle(context),
      );
}

// ── Callout ──────────────────────────────────────────────────────────
class CalloutBlockView extends StatelessWidget {
  final CalloutBlock block;
  const CalloutBlockView(this.block, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = block.variant.color;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(block.variant.icon, size: 18, color: c),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.variant.label.toUpperCase(),
                  style: TextStyle(
                    color: c,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          MarkdownLite(block.md, style: LessonType.bodyStyle(context)),
        ],
      ),
    );
  }
}

// ── List ─────────────────────────────────────────────────────────────
class ListBlockView extends StatelessWidget {
  final ListBlock block;
  const ListBlockView(this.block, {super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < block.items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  child: block.ordered
                      ? Text(
                          '${i + 1}.',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w700,
                            fontSize: LessonType.body(context),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Icon(Icons.circle, size: 6, color: accent),
                        ),
                ),
                Expanded(
                  child: MarkdownLite(
                    block.items[i],
                    style: LessonType.bodyStyle(context),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Code ─────────────────────────────────────────────────────────────
class CodeBlockView extends StatefulWidget {
  final CodeBlock block;
  final void Function(String code)? onTry;
  const CodeBlockView(this.block, {super.key, this.onTry});

  @override
  State<CodeBlockView> createState() => _CodeBlockViewState();
}

class _CodeBlockViewState extends State<CodeBlockView> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.block.code));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final block = widget.block;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: lessonCodeBg(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 6, 2),
                child: Row(
                  children: [
                    Text(
                      block.lang.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF6E7681),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    _CodeAction(
                      label: _copied ? 'Copied' : 'Copy',
                      icon: _copied ? Icons.check : Icons.copy_outlined,
                      onPressed: _copy,
                    ),
                    if (block.runnable && widget.onTry != null)
                      _CodeAction(
                        label: 'Try',
                        icon: Icons.play_arrow,
                        onPressed: () => widget.onTry!(block.code),
                      ),
                  ],
                ),
              ),
              Scrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: SelectableText(
                    block.code,
                    style: LessonType.codeStyle(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (block.caption != null) ...[
          const SizedBox(height: 6),
          Text(block.caption!, style: LessonType.secondaryStyle(context)),
        ],
      ],
    );
  }
}

class _CodeAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _CodeAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          minimumSize: const Size(kLessonMinTap, kLessonMinTap),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: const Color(0xFF9AA4B2),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

// ── Code compare ─────────────────────────────────────────────────────
class CodeCompareBlockView extends StatelessWidget {
  final CodeCompareBlock block;
  const CodeCompareBlockView(this.block, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _panel(context, block.wrong, const Color(0xFFE74C3C), Icons.close, 'Avoid'),
        const SizedBox(height: 8),
        _panel(context, block.right, const Color(0xFF00B894), Icons.check, 'Prefer'),
        if (block.note != null) ...[
          const SizedBox(height: 8),
          MarkdownLite(block.note!, style: LessonType.secondaryStyle(context)),
        ],
      ],
    );
  }

  Widget _panel(
    BuildContext context,
    String code,
    Color c,
    IconData ic,
    String label,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: lessonCodeBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: c, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
            child: Row(
              children: [
                Icon(ic, size: 16, color: c),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      color: c,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SelectableText(code, style: LessonType.codeStyle(context)),
          ),
        ],
      ),
    );
  }
}

// ── Figure ───────────────────────────────────────────────────────────
class FigureBlockView extends StatelessWidget {
  final FigureBlock block;
  const FigureBlockView(this.block, {super.key});

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (block.kind == FigureKind.ascii) {
      body = Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 80,
          maxHeight: block.height.clamp(80, 240),
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: lessonCodeBg(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: SelectableText(
                block.spec,
                style: LessonType.codeStyle(context),
              ),
            ),
          ),
        ),
      );
    } else {
      body = FigureHtmlView(
        key: ValueKey<String>(block.spec),
        spec: block.spec,
        height: block.height,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        body,
        if (block.caption != null) ...[
          const SizedBox(height: 6),
          Text(block.caption!, style: LessonType.secondaryStyle(context)),
        ],
      ],
    );
  }
}

// ── Fact sheet ───────────────────────────────────────────────────────
class FactSheetBlockView extends StatelessWidget {
  final FactSheetBlock block;
  const FactSheetBlockView(this.block, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: lessonCardBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lessonBorder(context)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < block.rows.length; i++)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: i == 0
                    ? null
                    : Border(top: BorderSide(color: lessonBorder(context))),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 300;
                  final label = Text(
                    block.rows[i].label,
                    style: LessonType.secondaryStyle(context),
                  );
                  final value = Text(
                    block.rows[i].value,
                    style: TextStyle(
                      fontSize: LessonType.body(context),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  );
                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [label, const SizedBox(height: 4), value],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 108, child: label),
                      const SizedBox(width: 10),
                      Expanded(child: value),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Creator ──────────────────────────────────────────────────────────
class CreatorBlockView extends StatelessWidget {
  final CreatorBlock block;
  final Color accent;
  const CreatorBlockView(this.block, this.accent, {super.key});

  String get _initials {
    final name = block.name.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    String head(String s) => s.substring(0, 1).toUpperCase();
    if (parts.length == 1) return head(parts.first);
    return head(parts.first) + head(parts.last);
  }

  @override
  Widget build(BuildContext context) {
    final sub = [block.role, block.era, block.place]
        .where((e) => e != null && e.isNotEmpty)
        .join(' · ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lessonCardBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lessonBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CREATOR',
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: accent.withValues(alpha: 0.18),
                child: Text(
                  _initials,
                  style: TextStyle(color: accent, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(block.name, style: LessonType.subheadStyle(context)),
                    if (sub.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(sub, style: LessonType.secondaryStyle(context)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MarkdownLite(block.story, style: LessonType.bodyStyle(context)),
        ],
      ),
    );
  }
}

// ── Timeline (vertical, 360dp-safe) ──────────────────────────────────
class TimelineBlockView extends StatelessWidget {
  final TimelineBlock block;
  final Color accent;
  const TimelineBlockView(this.block, this.accent, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < block.entries.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 18,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (i != block.entries.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: accent.withValues(alpha: 0.28),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          block.entries[i].year,
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w800,
                            fontSize: LessonType.secondary(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          block.entries[i].title,
                          style: LessonType.subheadStyle(context).copyWith(
                            fontSize: LessonType.body(context),
                          ),
                        ),
                        if (block.entries[i].detail != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              block.entries[i].detail!,
                              style: LessonType.secondaryStyle(context),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Real world ───────────────────────────────────────────────────────
class RealWorldBlockView extends StatelessWidget {
  final RealWorldBlock block;
  final Color accent;
  const RealWorldBlockView(this.block, this.accent, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in block.items)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: lessonCardBg(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: lessonBorder(context)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.public, size: 18, color: accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: LessonType.body(context),
                        ),
                      ),
                      if (item.note != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            item.note!,
                            style: LessonType.secondaryStyle(context),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Quote ────────────────────────────────────────────────────────────
class QuoteBlockView extends StatelessWidget {
  final QuoteBlock block;
  final Color accent;
  const QuoteBlockView(this.block, this.accent, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(block.text, style: LessonType.bodyStyle(context).copyWith(
            fontStyle: FontStyle.italic,
          )),
          if (block.author != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '— ${block.author!}',
                style: TextStyle(
                  fontSize: LessonType.secondary(context),
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Interview Q&A ────────────────────────────────────────────────────
class InterviewQABlockView extends StatelessWidget {
  final InterviewQABlock block;
  const InterviewQABlockView(this.block, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final qa in block.items)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: lessonCardBg(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: lessonBorder(context)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                title: Text(
                  qa.q,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: LessonType.body(context),
                    height: 1.35,
                  ),
                ),
                iconColor: Theme.of(context).colorScheme.primary,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: MarkdownLite(
                      qa.a,
                      style: LessonType.bodyStyle(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Syntax breakdown ─────────────────────────────────────────────────
class SyntaxBreakdownBlockView extends StatelessWidget {
  final SyntaxBreakdownBlock block;
  final Color accent;
  const SyntaxBreakdownBlockView(this.block, this.accent, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: lessonCardBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lessonBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: lessonCodeBg(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                block.code,
                style: LessonType.codeStyle(context),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final p in block.parts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            p.fragment,
                            style: LessonType.codeStyle(context).copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 160),
                          child: Text(
                            p.label,
                            style: LessonType.secondaryStyle(context),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Exercise ─────────────────────────────────────────────────────────
class ExerciseBlockView extends StatelessWidget {
  final ExerciseBlock block;
  final Color accent;
  final void Function(Map<String, String> starter)? onStart;
  const ExerciseBlockView(this.block, this.accent, {super.key, this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lessonCardBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lessonBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, size: 18, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'TRY IT NOW',
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          MarkdownLite(block.prompt, style: LessonType.bodyStyle(context)),
          if (block.checks.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final check in block.checks)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check, size: 16, color: accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(check, style: LessonType.secondaryStyle(context)),
                    ),
                  ],
                ),
              ),
          ],
          if (onStart != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  minimumSize: const Size.fromHeight(kLessonMinTap),
                ),
                onPressed: () => onStart!(block.starterCode),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Open Playground'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Deep dive ────────────────────────────────────────────────────────
class DeepDiveBlockView extends StatefulWidget {
  final DeepDiveBlock block;
  final Color accent;
  final Widget Function(LessonBlock child) renderChild;
  const DeepDiveBlockView(
    this.block,
    this.accent, {
    super.key,
    required this.renderChild,
  });

  @override
  State<DeepDiveBlockView> createState() => _DeepDiveBlockViewState();
}

class _DeepDiveBlockViewState extends State<DeepDiveBlockView> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Semantics(
            button: true,
            label: _expanded
                ? 'Collapse ${widget.block.title}'
                : 'Expand ${widget.block.title}',
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: kLessonMinTap),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                  child: Row(
                    children: [
                      Icon(
                        _expanded ? Icons.remove : Icons.add,
                        size: 22,
                        color: accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.block.title,
                          style: LessonType.subheadStyle(context, color: accent),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.expand_more, color: accent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final child in widget.block.children) ...[
                    if (child is! UnknownBlock) ...[
                      widget.renderChild(child),
                      const SizedBox(height: kBlockGap),
                    ],
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Project prompt ───────────────────────────────────────────────────
class ProjectPromptView extends StatelessWidget {
  final ProjectPrompt project;
  final Color accent;
  final void Function(Map<String, String> starter) onBuild;
  const ProjectPromptView(
    this.project,
    this.accent, {
    super.key,
    required this.onBuild,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.16),
            accent.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MINI PROJECT',
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(project.title, style: LessonType.subheadStyle(context)),
          const SizedBox(height: 6),
          MarkdownLite(project.brief, style: LessonType.bodyStyle(context)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                minimumSize: const Size.fromHeight(kLessonMinTap),
              ),
              onPressed: () => onBuild(project.starterCode),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Build it in the Playground'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick recap ──────────────────────────────────────────────────────
class QuickRecapView extends StatelessWidget {
  final List<String> items;
  final Color accent;
  const QuickRecapView({super.key, required this.items, required this.accent});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK RECAP',
            style: TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 6, color: accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MarkdownLite(
                      item,
                      style: LessonType.bodyStyle(context),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const SectionLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color ?? Theme.of(context).hintColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
