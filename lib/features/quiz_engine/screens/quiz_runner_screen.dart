import 'package:flutter/material.dart';

import '../models/quiz_item.dart';
import '../services/quiz_grader.dart';
import '../services/quiz_set_loader.dart';
import '../widgets/quiz_explanation_panel.dart';
import '../widgets/quiz_item_view.dart';

class QuizRunnerArguments {
  final String lessonId;
  final String? title;
  const QuizRunnerArguments({required this.lessonId, this.title});
}

/// A reusable runner for any [QuizSet]. Steps through items one at a
/// time, grades on submit, shows a free explanation, then advances to a
/// final score. Loads the set from assets by lesson id. This screen is
/// self-contained and does not touch the existing lesson-quiz or XP flow.
class QuizRunnerScreen extends StatelessWidget {
  final QuizRunnerArguments? args;
  const QuizRunnerScreen({super.key, this.args});
  static const route = '/quiz-runner';

  @override
  Widget build(BuildContext context) {
    final a = args ??
        (ModalRoute.of(context)?.settings.arguments as QuizRunnerArguments?);
    if (a == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Practice')),
        body: const Center(child: Text('No quiz specified.')),
      );
    }
    return _QuizRunnerView(args: a);
  }
}

class _QuizRunnerView extends StatefulWidget {
  final QuizRunnerArguments args;
  const _QuizRunnerView({required this.args});

  @override
  State<_QuizRunnerView> createState() => _QuizRunnerViewState();
}

class _QuizRunnerViewState extends State<_QuizRunnerView> {
  bool _loading = true;
  QuizSet? _set;

  int _index = 0;
  QuizAnswer _current = QuizAnswer();
  bool _submitted = false;
  bool _lastCorrect = false;
  int _correct = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final set = await QuizSetLoader.instance.load(widget.args.lessonId);
    if (!mounted) return;
    setState(() {
      _set = set;
      _loading = false;
    });
  }

  void _submit() {
    final item = _set!.items[_index];
    final correct = QuizGrader.isCorrect(item, _current);
    setState(() {
      _submitted = true;
      _lastCorrect = correct;
      if (correct) _correct++;
    });
  }

  void _next() {
    if (_index >= _set!.items.length - 1) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _index++;
      _current = QuizAnswer();
      _submitted = false;
    });
  }

  void _restart() {
    setState(() {
      _index = 0;
      _current = QuizAnswer();
      _submitted = false;
      _correct = 0;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.args.title ?? _set?.title ?? 'Practice';

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_set == null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: Text('No advanced quiz for this lesson yet.')),
      );
    }
    if (_finished) return _buildResult(context);
    return _buildQuestion(context);
  }

  Widget _buildQuestion(BuildContext context) {
    final items = _set!.items;
    final item = items[_index];
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(_set!.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_index + 1) / items.length,
            minHeight: 4,
            backgroundColor: accent.withValues(alpha: 0.15),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Question ${_index + 1} of ${items.length}',
                            style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5)),
                        const Spacer(),
                        _DifficultyChip(item.difficulty),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(item.prompt,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700, height: 1.4)),
                    const SizedBox(height: 16),
                    QuizItemView(
                      key: ValueKey(item.id),
                      item: item,
                      answer: _current,
                      revealed: _submitted,
                      onChanged: (a) => setState(() => _current = a),
                    ),
                    if (_submitted) ...[
                      const SizedBox(height: 18),
                      QuizExplanationPanel(item: item, wasCorrect: _lastCorrect),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _bottomBar(context, items.length),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context, int total) {
    final isLast = _index >= total - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SizedBox(
        height: 50,
        child: _submitted
            ? FilledButton.icon(
                onPressed: _next,
                icon: Icon(isLast ? Icons.flag : Icons.arrow_forward),
                label: Text(isLast ? 'See results' : 'Next question'),
              )
            : FilledButton(
                onPressed: _current.isEmpty ? null : _submit,
                child: const Text('Submit answer'),
              ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final total = _set!.items.length;
    final pct = total == 0 ? 0 : ((_correct / total) * 100).round();
    final accent = Theme.of(context).colorScheme.primary;
    final passed = pct >= 80;

    return Scaffold(
      appBar: AppBar(title: Text(_set!.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(passed ? Icons.emoji_events : Icons.replay_circle_filled,
                  size: 72, color: accent),
              const SizedBox(height: 16),
              Text('$_correct / $total correct',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('$pct%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18, color: accent, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                passed
                    ? 'Great work — you have a solid grasp of this.'
                    : 'Good effort. Review the explanations and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).hintColor, height: 1.4),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final QuizDifficulty difficulty;
  const _DifficultyChip(this.difficulty);

  @override
  Widget build(BuildContext context) {
    final c = switch (difficulty) {
      QuizDifficulty.beginner => const Color(0xFF00B894),
      QuizDifficulty.intermediate => const Color(0xFF0984E3),
      QuizDifficulty.advanced => const Color(0xFFE17055),
      QuizDifficulty.expert => const Color(0xFF6C5CE7),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(difficulty.label,
          style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
