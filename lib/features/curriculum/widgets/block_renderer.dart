import 'package:flutter/material.dart';

import '../models/lesson_block.dart';
import '../models/lesson_content.dart';
import 'lesson_blocks.dart';

/// Renders a [LessonContent] with progressive disclosure.
///
/// Core blocks stay expanded. Deep-dive / optional sections start
/// collapsed so a 1,200-word lesson does not dump as one wall of text.
class BlockRenderer extends StatelessWidget {
  final LessonContent content;
  final Color accent;

  /// Open the playground with a single code snippet (from a `code` block's
  /// "Try" button). [lang] selects which editor slot it lands in.
  final void Function(String code, String lang) onTryCode;

  /// Open the playground pre-filled with a full starter map (from an
  /// `exercise` block or the mini `projectPrompt`).
  final void Function(Map<String, String> starter) onOpenStarter;

  const BlockRenderer({
    super.key,
    required this.content,
    required this.accent,
    required this.onTryCode,
    required this.onOpenStarter,
  });

  Widget render(LessonBlock block) {
    return switch (block) {
      final SummaryBlock b => SummaryBlockView(b, accent),
      final HeadingBlock b => HeadingBlockView(b),
      final ProseBlock b => ProseBlockView(b),
      final CalloutBlock b => CalloutBlockView(b),
      final ListBlock b => ListBlockView(b),
      final CodeBlock b => CodeBlockView(b, onTry: (code) => onTryCode(code, b.lang)),
      final CodeCompareBlock b => CodeCompareBlockView(b),
      final FigureBlock b => FigureBlockView(b),
      final FactSheetBlock b => FactSheetBlockView(b),
      final CreatorBlock b => CreatorBlockView(b, accent),
      final TimelineBlock b => TimelineBlockView(b, accent),
      final RealWorldBlock b => RealWorldBlockView(b, accent),
      final QuoteBlock b => QuoteBlockView(b, accent),
      final InterviewQABlock b => InterviewQABlockView(b),
      final SyntaxBreakdownBlock b => SyntaxBreakdownBlockView(b, accent),
      final ExerciseBlock b => ExerciseBlockView(b, accent, onStart: onOpenStarter),
      final DeepDiveBlock b => DeepDiveBlockView(b, accent, renderChild: render),
      final SectionBlock b => b.tier == SectionTier.deep
          ? DeepDiveBlockView(
              DeepDiveBlock(title: b.title, children: b.children),
              accent,
              renderChild: render,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (b.title.isNotEmpty) HeadingBlockView(HeadingBlock(text: b.title, level: 2)),
                for (final child in b.children)
                  if (child is! UnknownBlock) ...[
                    const SizedBox(height: kBlockGap),
                    render(child),
                  ],
              ],
            ),
      UnknownBlock _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final core = <Widget>[];
    final deep = <Widget>[];
    final after = <Widget>[];

    var seenDeep = false;
    for (final block in content.content) {
      if (block is UnknownBlock) continue;
      final isDeep = block is DeepDiveBlock ||
          (block is SectionBlock && block.tier == SectionTier.deep);
      if (isDeep) {
        seenDeep = true;
        if (deep.isNotEmpty) deep.add(const SizedBox(height: kBlockGap));
        deep.add(render(block));
      } else if (block is ExerciseBlock) {
        if (content.exercise != null) continue;
        after.add(const SizedBox(height: kBlockGap));
        after.add(render(block));
      } else if (seenDeep) {
        after.add(const SizedBox(height: kBlockGap));
        after.add(render(block));
      } else {
        if (core.isNotEmpty) core.add(const SizedBox(height: kBlockGap));
        core.add(render(block));
      }
    }

    final children = <Widget>[
      if (core.isNotEmpty) ...[
        SectionLabel('Core lesson', color: accent),
        ...core,
      ],
      if (deep.isNotEmpty) ...[
        const SizedBox(height: 20),
        SectionLabel('Deep dive', color: accent),
        Text(
          'Optional extras — tap a topic to open it.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        ...deep,
      ],
      ...after,
    ];

    if (content.exercise != null) {
      children.add(const SizedBox(height: kBlockGap));
      children.add(ExerciseBlockView(
        content.exercise!,
        accent,
        onStart: onOpenStarter,
      ));
    }

    if (content.quickRecap.isNotEmpty) {
      children.add(const SizedBox(height: 20));
      children.add(QuickRecapView(items: content.quickRecap, accent: accent));
    }

    if (content.projectPrompt != null) {
      children.add(const SizedBox(height: kBlockGap));
      children.add(ProjectPromptView(
        content.projectPrompt!,
        accent,
        onBuild: onOpenStarter,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
