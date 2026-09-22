import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../editor/widgets/code_editor_pane.dart';
import '../../editor/widgets/preview_pane.dart';
import '../../learning/logic/lesson_progression.dart';
import '../../learning/providers/learning_progress_provider.dart';
import '../data/challenges_catalog.dart';
import '../models/challenge.dart';
import '../providers/challenge_session_provider.dart';
import '../providers/challenges_provider.dart';
import '../providers/daily_challenge_provider.dart';
import '../widgets/instructions_card.dart';
import '../widgets/validation_result_sheet.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});
  static const route = '/challenge';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments
        as ChallengeRouteArguments?;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
            child: Text('Open a challenge from the Challenges screen.')),
      );
    }
    final ch = ChallengesCatalog.byId(args.challengeId);
    if (ch == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Challenge not found: ${args.challengeId}')),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => ChallengeSessionProvider(ch),
      child: _ChallengeView(challenge: ch, isDailyEntry: args.isDailyEntry),
    );
  }
}

class _ChallengeView extends StatelessWidget {
  final Challenge challenge;
  final bool isDailyEntry;

  const _ChallengeView({
    required this.challenge,
    required this.isDailyEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          challenge.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Reset',
            icon: const Icon(Icons.refresh),
            onPressed: () => _confirmReset(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            InstructionsCard(challenge: challenge),
            const _ChallengeTabBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 720;
                  return isWide
                      ? const _WideBody()
                      : const _NarrowBody();
                },
              ),
            ),
            _ChallengeBottomBar(
              onRun: () => context.read<ChallengeSessionProvider>().run(),
              onSubmit: () => _handleSubmit(context),
              onHint: () => _showHint(context, challenge),
              onSolution: () => _confirmShowSolution(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final session = context.read<ChallengeSessionProvider>();
    final challenges = context.read<ChallengesProvider>();
    final daily = context.read<DailyChallengeProvider>();
    final learning = context.read<LearningProgressProvider>();

    final result = session.submit();
    if (!context.mounted) return;

    if (!result.passed) {
      await ValidationResultSheet.show(
        context,
        result: result,
        xpAwarded: 0,
        onTryAgain: () => Navigator.of(context).maybePop(),
        onShowHint: () {
          Navigator.of(context).maybePop();
          session.toggleHint();
          _showHintSheet(context, challenge);
        },
      );
      return;
    }

    // ── Passed ──
    // Award XP. Skip XP if the user revealed the solution.
    final baseXp = session.solutionShown ? 0 : challenge.xpReward;
    final isDailyToday = isDailyEntry && !daily.completedToday;
    final bonusXp = isDailyToday ? baseXp : 0;
    final totalXp = baseXp + bonusXp;

    final beforeLevel = learning.currentLevel.level;
    if (totalXp > 0) {
      await learning.addXP(totalXp);
    }
    final levelUp = learning.currentLevel.level.index > beforeLevel.index;
    final levelLabel = levelUp ? learning.currentLevel.label : null;

    // Record completion (idempotent).
    await challenges.markCompleted(challenge.id);
    if (isDailyToday) {
      await daily.markTodayCompleted();
    }

    // Re-evaluate badges (counts may have changed).
    await learning.evaluateBadges(
      savedProjectsCount: 0, // projects unrelated to challenges
    );

    if (!context.mounted) return;

    final next = challenges.nextAfter(challenge.id);
    // Tracks whether the user took an action that navigated away (Next
    // challenge replaces this route). When true, skip the post-sheet
    // maybePop or we'd pop the freshly-pushed screen.
    var navigatedAway = false;

    await ValidationResultSheet.show(
      context,
      result: result,
      xpAwarded: totalXp,
      isDailyBonus: isDailyToday,
      levelUp: levelUp,
      levelLabel: levelLabel,
      onNextChallenge: next == null
          ? null
          : () {
              navigatedAway = true;
              Navigator.of(context).pop(); // close sheet
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.challenge,
                arguments: ChallengeRouteArguments(challengeId: next.id),
              );
            },
    );

    if (!shouldPopAfterCompletionOverlay(navigatedAway: navigatedAway) ||
        !context.mounted) {
      return;
    }
    await Navigator.of(context).maybePop();
  }

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset code?'),
        content: const Text(
          'Your edits will be replaced with the starter code.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<ChallengeSessionProvider>().reset();
    }
  }

  Future<void> _confirmShowSolution(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Show solution?'),
        content: const Text(
          'You can study the working code, but submitting after this '
          "won't award XP for this challenge.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Show'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<ChallengeSessionProvider>().revealSolution();
    }
  }

  void _showHint(BuildContext context, Challenge ch) {
    context.read<ChallengeSessionProvider>().toggleHint();
    _showHintSheet(context, ch);
  }

  void _showHintSheet(BuildContext context, Challenge ch) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hint',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ch.hint.isEmpty ? 'No hint provided for this challenge.' : ch.hint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeTabBar extends StatelessWidget {
  const _ChallengeTabBar();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ChallengeSessionProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF262B35) : const Color(0xFFE4E7EE);
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141820) : Colors.white,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: ChallengeTab.values.map((tab) {
          final selected = session.selectedTab == tab;
          return Expanded(
            child: InkWell(
              onTap: () => session.switchTab(tab),
              child: Container(
                alignment: Alignment.center,
                decoration: selected
                    ? BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: primary, width: 2),
                        ),
                      )
                    : null,
                child: Text(
                  tab.label,
                  style: TextStyle(
                    color: selected
                        ? primary
                        : (isDark
                            ? const Color(0xFF8A929D)
                            : const Color(0xFF5D6670)),
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActiveEditor extends StatelessWidget {
  const _ActiveEditor();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ChallengeSessionProvider>();
    return CodeEditorPane(
      initialText: session.currentDraft,
      onChanged: session.updateCurrent,
      resetKey: '${session.selectedTab.name}:${session.runVersion}',
    );
  }
}

class _CombinedPreview extends StatelessWidget {
  const _CombinedPreview();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ChallengeSessionProvider>();
    return PreviewPane(
      htmlDocument: _buildDocument(
        html: session.htmlCommitted,
        css: session.cssCommitted,
        js: session.jsCommitted,
      ),
      version: session.runVersion,
    );
  }

  static String _buildDocument({
    required String html,
    required String css,
    required String js,
  }) {
    final safeJs = js.replaceAll('</script>', r'<\/script>');
    final cssBlock = css.trim().isEmpty ? '' : '<style>$css</style>';
    final jsBlock = safeJs.trim().isEmpty ? '' : '<script>$safeJs</script>';

    final hasHtmlTag =
        RegExp(r'<html[\s>]', caseSensitive: false).hasMatch(html);
    final hasHead =
        RegExp(r'<head[\s>]', caseSensitive: false).hasMatch(html);
    final hasBodyClose =
        RegExp(r'</body\s*>', caseSensitive: false).hasMatch(html);

    if (hasHtmlTag) {
      var doc = html;
      if (cssBlock.isNotEmpty) {
        if (hasHead) {
          doc = doc.replaceFirstMapped(
            RegExp(r'(<head[^>]*>)', caseSensitive: false),
            (m) => '${m[1]}$cssBlock',
          );
        } else {
          doc = doc.replaceFirstMapped(
            RegExp(r'(<html[^>]*>)', caseSensitive: false),
            (m) => '${m[1]}<head>$cssBlock</head>',
          );
        }
      }
      if (jsBlock.isNotEmpty) {
        if (hasBodyClose) {
          doc = doc.replaceFirstMapped(
            RegExp(r'(</body\s*>)', caseSensitive: false),
            (m) => '$jsBlock${m[1]}',
          );
        } else {
          doc = '$doc\n$jsBlock';
        }
      }
      return doc;
    }

    return '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
$cssBlock
</head>
<body>
$html
$jsBlock
</body>
</html>''';
  }
}

class _PreviewLabel extends StatelessWidget {
  const _PreviewLabel();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? const Color(0xFF8A929D) : const Color(0xFF5D6670);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isDark ? const Color(0xFF141820) : const Color(0xFFF2F4F8),
      child: Row(
        children: [
          Icon(Icons.visibility_outlined, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            'Preview',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _NarrowBody extends StatelessWidget {
  const _NarrowBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(flex: 55, child: _ActiveEditor()),
        _PreviewLabel(),
        Expanded(flex: 45, child: _CombinedPreview()),
      ],
    );
  }
}

class _WideBody extends StatelessWidget {
  const _WideBody();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _ActiveEditor()),
        SizedBox(width: 1, child: ColoredBox(color: Color(0x33808080))),
        Expanded(
          child: Column(
            children: [
              _PreviewLabel(),
              Expanded(child: _CombinedPreview()),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChallengeBottomBar extends StatelessWidget {
  final VoidCallback onRun;
  final VoidCallback onSubmit;
  final VoidCallback onHint;
  final VoidCallback onSolution;

  const _ChallengeBottomBar({
    required this.onRun,
    required this.onSubmit,
    required this.onHint,
    required this.onSolution,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF262B35) : const Color(0xFFE4E7EE);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141820) : Colors.white,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              tooltip: 'Hint',
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: onHint,
            ),
            IconButton(
              tooltip: 'View solution',
              icon: const Icon(Icons.menu_book_outlined),
              onPressed: onSolution,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Run'),
                onPressed: onRun,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Submit'),
                onPressed: onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
