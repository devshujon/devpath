import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Visual variants for [CalloutBlock].
enum CalloutVariant { info, tip, warning, fact }

CalloutVariant _calloutVariant(String? s) => switch (s) {
      'tip' => CalloutVariant.tip,
      'warning' => CalloutVariant.warning,
      'fact' => CalloutVariant.fact,
      _ => CalloutVariant.info,
    };

extension CalloutVariantMeta on CalloutVariant {
  Color get color => switch (this) {
        CalloutVariant.info => const Color(0xFF0984E3),
        CalloutVariant.tip => const Color(0xFF00B894),
        CalloutVariant.warning => const Color(0xFFE17055),
        CalloutVariant.fact => const Color(0xFF6C5CE7),
      };

  IconData get icon => switch (this) {
        CalloutVariant.info => Icons.info_outline,
        CalloutVariant.tip => Icons.check_circle_outline,
        CalloutVariant.warning => Icons.warning_amber_rounded,
        CalloutVariant.fact => Icons.auto_awesome_outlined,
      };

  String get label => switch (this) {
        CalloutVariant.info => 'Why it exists',
        CalloutVariant.tip => 'Best practice',
        CalloutVariant.warning => 'Common mistake',
        CalloutVariant.fact => 'Did you know?',
      };
}

/// How a [FigureBlock] is rendered.
enum FigureKind { html, ascii }

/// Progressive-disclosure group. Core is expanded; deep is collapsed.
enum SectionTier { core, deep }

SectionTier _sectionTier(String? s) =>
    s == 'deep' || s == 'deepDive' ? SectionTier.deep : SectionTier.core;

// ─────────────────────────────────────────────────────────────────────
//  Sealed block hierarchy. Every lesson's `content` array is a list of
//  these. The renderer (block_renderer.dart) switches exhaustively
//  over the sealed type, so adding a block type forces a render branch.
//
//  Unknown / future block types parse into [UnknownBlock] and render
//  nothing, so a newer content file never crashes an older app build.
// ─────────────────────────────────────────────────────────────────────

sealed class LessonBlock {
  const LessonBlock();

  factory LessonBlock.fromJson(Map<String, dynamic> j) {
    try {
      return LessonBlock._parse(j);
    } catch (e) {
      final type = _str(j['type'], 'malformed');
      if (kDebugMode) {
        debugPrint('Curriculum: dropping malformed block "$type": $e');
      }
      return UnknownBlock(type: type);
    }
  }

  factory LessonBlock._parse(Map<String, dynamic> j) {
    switch (j['type'] as String? ?? '') {
      case 'summary':
        return SummaryBlock(md: _str(j['md']));
      case 'heading':
        return HeadingBlock(text: _str(j['text']), level: _int(j['level'], 2));
      case 'prose':
        return ProseBlock(md: _str(j['md']));
      case 'callout':
        return CalloutBlock(
          variant: _calloutVariant(j['variant'] as String?),
          md: _str(j['md']),
        );
      case 'list':
        return ListBlock(
          ordered: j['ordered'] == true,
          items: _strList(j['items']),
        );
      case 'code':
        return CodeBlock(
          lang: _str(j['lang'], 'text'),
          code: _str(j['code']),
          runnable: j['runnable'] == true,
          caption: _strOrNull(j['caption']),
        );
      case 'codeCompare':
        return CodeCompareBlock(
          lang: _str(j['lang'], 'text'),
          wrong: _str(j['wrong']),
          right: _str(j['right']),
          note: _strOrNull(j['note']),
        );
      case 'figure':
        return FigureBlock(
          kind: j['kind'] == 'ascii' ? FigureKind.ascii : FigureKind.html,
          spec: _str(j['spec']),
          caption: _strOrNull(j['caption']),
          height: _int(j['height'], 180).toDouble(),
        );
      case 'factSheet':
        return FactSheetBlock(
          rows: _objList(j['rows'])
              .map((r) => FactRow(_str(r['label']), _str(r['value'])))
              .toList(),
        );
      case 'creator':
        return CreatorBlock(
          name: _str(j['name']),
          role: _strOrNull(j['role']),
          era: _strOrNull(j['era']),
          place: _strOrNull(j['place']),
          story: _str(j['story']),
        );
      case 'timeline':
        return TimelineBlock(
          entries: _objList(j['entries'])
              .map((e) => TimelineEntry(
                    year: _str(e['year']),
                    title: _str(e['title']),
                    detail: _strOrNull(e['detail']),
                  ))
              .toList(),
        );
      case 'realWorld':
        return RealWorldBlock(
          items: _objList(j['items'])
              .map((i) => RealWorldItem(_str(i['name']), _strOrNull(i['note'])))
              .toList(),
        );
      case 'quote':
        return QuoteBlock(text: _str(j['text']), author: _strOrNull(j['author']));
      case 'interviewQA':
        return InterviewQABlock(
          items: _objList(j['items'])
              .map((i) => QAPair(_str(i['q']), _str(i['a'])))
              .toList(),
        );
      case 'syntaxBreakdown':
        return SyntaxBreakdownBlock(
          lang: _str(j['lang'], 'text'),
          code: _str(j['code']),
          parts: _objList(j['parts'])
              .map((p) => SyntaxPart(_str(p['fragment']), _str(p['label'])))
              .toList(),
        );
      case 'exercise':
        return ExerciseBlock(
          prompt: _str(j['prompt']),
          starterCode: _strMap(j['starterCode']),
          checks: _strList(j['checks']),
        );
      case 'deepDive':
        return DeepDiveBlock(
          title: _str(j['title'], 'History & Deep Dive'),
          children: _objList(j['children'])
              // Guard the schema rule: no nested deep dives.
              .where((c) => c['type'] != 'deepDive')
              .map(LessonBlock.fromJson)
              .toList(),
        );
      case 'section':
        return SectionBlock(
          title: _str(j['title'], 'Section'),
          tier: _sectionTier(j['tier'] as String? ?? j['kind'] as String?),
          children: _objList(j['children']).map(LessonBlock.fromJson).toList(),
        );
      default:
        final type = _str(j['type']);
        if (kDebugMode) {
          debugPrint('Curriculum: skipping unknown block type "$type"');
        }
        return UnknownBlock(type: type);
    }
  }
}

class SummaryBlock extends LessonBlock {
  final String md;
  const SummaryBlock({required this.md});
}

class HeadingBlock extends LessonBlock {
  final String text;
  final int level;
  const HeadingBlock({required this.text, required this.level});
}

class ProseBlock extends LessonBlock {
  final String md;
  const ProseBlock({required this.md});
}

class CalloutBlock extends LessonBlock {
  final CalloutVariant variant;
  final String md;
  const CalloutBlock({required this.variant, required this.md});
}

class ListBlock extends LessonBlock {
  final bool ordered;
  final List<String> items;
  const ListBlock({required this.ordered, required this.items});
}

class CodeBlock extends LessonBlock {
  final String lang;
  final String code;
  final bool runnable;
  final String? caption;
  const CodeBlock({
    required this.lang,
    required this.code,
    required this.runnable,
    this.caption,
  });
}

class CodeCompareBlock extends LessonBlock {
  final String lang;
  final String wrong;
  final String right;
  final String? note;
  const CodeCompareBlock({
    required this.lang,
    required this.wrong,
    required this.right,
    this.note,
  });
}

class FigureBlock extends LessonBlock {
  final FigureKind kind;
  final String spec;
  final String? caption;
  final double height;
  const FigureBlock({
    required this.kind,
    required this.spec,
    this.caption,
    required this.height,
  });
}

class FactRow {
  final String label;
  final String value;
  const FactRow(this.label, this.value);
}

class FactSheetBlock extends LessonBlock {
  final List<FactRow> rows;
  const FactSheetBlock({required this.rows});
}

class CreatorBlock extends LessonBlock {
  final String name;
  final String? role;
  final String? era;
  final String? place;
  final String story;
  const CreatorBlock({
    required this.name,
    this.role,
    this.era,
    this.place,
    required this.story,
  });
}

class TimelineEntry {
  final String year;
  final String title;
  final String? detail;
  const TimelineEntry({required this.year, required this.title, this.detail});
}

class TimelineBlock extends LessonBlock {
  final List<TimelineEntry> entries;
  const TimelineBlock({required this.entries});
}

class RealWorldItem {
  final String name;
  final String? note;
  const RealWorldItem(this.name, this.note);
}

class RealWorldBlock extends LessonBlock {
  final List<RealWorldItem> items;
  const RealWorldBlock({required this.items});
}

class QuoteBlock extends LessonBlock {
  final String text;
  final String? author;
  const QuoteBlock({required this.text, this.author});
}

class QAPair {
  final String q;
  final String a;
  const QAPair(this.q, this.a);
}

class InterviewQABlock extends LessonBlock {
  final List<QAPair> items;
  const InterviewQABlock({required this.items});
}

class SyntaxPart {
  final String fragment;
  final String label;
  const SyntaxPart(this.fragment, this.label);
}

class SyntaxBreakdownBlock extends LessonBlock {
  final String lang;
  final String code;
  final List<SyntaxPart> parts;
  const SyntaxBreakdownBlock({
    required this.lang,
    required this.code,
    required this.parts,
  });
}

class ExerciseBlock extends LessonBlock {
  final String prompt;
  final Map<String, String> starterCode;
  final List<String> checks;
  const ExerciseBlock({
    required this.prompt,
    required this.starterCode,
    required this.checks,
  });
}

class DeepDiveBlock extends LessonBlock {
  final String title;
  final List<LessonBlock> children;
  const DeepDiveBlock({required this.title, required this.children});
}

class SectionBlock extends LessonBlock {
  final String title;
  final SectionTier tier;
  final List<LessonBlock> children;
  const SectionBlock({
    required this.title,
    required this.tier,
    required this.children,
  });
}

/// Forward-compatibility sink: any unrecognized `type` lands here and
/// renders nothing, so newer content can't crash an older build.
class UnknownBlock extends LessonBlock {
  final String type;
  const UnknownBlock({required this.type});
}

// ── tiny null-safe JSON coercers ──
String _str(Object? v, [String fallback = '']) => v is String ? v : fallback;
String? _strOrNull(Object? v) => v is String && v.isNotEmpty ? v : null;
int _int(Object? v, int fallback) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}
List<String> _strList(Object? v) =>
    v is List ? v.whereType<String>().toList() : const [];
List<Map<String, dynamic>> _objList(Object? v) => v is List
    ? v.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList()
    : const [];
Map<String, String> _strMap(Object? v) => v is Map
    ? v.map((k, val) => MapEntry('$k', val is String ? val : '$val'))
    : const {};
