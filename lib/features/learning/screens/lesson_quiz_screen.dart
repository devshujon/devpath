import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../data/lessons_catalog.dart';
import '../logic/lesson_progression.dart';
import '../models/lesson.dart';
import '../providers/learning_progress_provider.dart';
import '../widgets/xp_award_overlay.dart';

class LessonQuizScreen extends StatefulWidget {
  const LessonQuizScreen({super.key});
  static const route = '/lesson-quiz';

  @override
  State<LessonQuizScreen> createState() => _LessonQuizScreenState();
}

class _LessonQuizScreenState extends State<LessonQuizScreen> {
  Lesson? _lesson;
  int _index = 0;
  final Map<int, int> _answers = {};
  bool _showResult = false;
  bool _finishing = false;

  static const double _passingThreshold = 0.7;

  void _ensureLesson(BuildContext context) {
    if (_lesson != null) return;
    final args =
        ModalRoute.of(context)?.settings.arguments as LessonDetailArguments?;
    if (args == null) return;
    _lesson = LessonsCatalog.byId(args.lessonId);
  }

  int get _correctCount {
    final lesson = _lesson;
    if (lesson == null) return 0;
    var c = 0;
    for (var i = 0; i < lesson.quizQuestions.length; i++) {
      if (_answers[i] == lesson.quizQuestions[i].correctIndex) c++;
    }
    return c;
  }

  double get _scoreRatio {
    final lesson = _lesson;
    if (lesson == null || lesson.quizQuestions.isEmpty) return 0;
    return _correctCount / lesson.quizQuestions.length;
  }

  bool get _passed => _scoreRatio >= _passingThreshold;

  @override
  Widget build(BuildContext context) {
    _ensureLesson(context);
    final lesson = _lesson;
    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Lesson not found.')),
      );
    }
    final locked = context.select<LearningProgressProvider, bool>(
      (p) => p.lessonWithProgress(lesson).isLocked,
    );
    if (locked) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            lesson.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 48, color: Theme.of(context).disabledColor),
                const SizedBox(height: 16),
                Text(
                  'This lesson is locked',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.maybePop(context),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (lesson.quizQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            lesson.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: const Center(child: Text('No quiz questions for this lesson.')),
      );
    }
    if (_showResult) {
      return _ResultView(
        lesson: lesson,
        correct: _correctCount,
        total: lesson.quizQuestions.length,
        passed: _passed,
        finishing: _finishing,
        alreadyCompleted: context
            .select<LearningProgressProvider, bool>(
              (p) => p.completedLessons.contains(lesson.id),
            ),
        onRetry: () {
          setState(() {
            _answers.clear();
            _index = 0;
            _showResult = false;
          });
        },
        onFinish: () => _markCompleteAndCelebrate(context, lesson),
        onClose: () => Navigator.maybePop(context),
      );
    }
    return _QuestionView(
      lesson: lesson,
      index: _index,
      selected: _answers[_index],
      onSelect: (i) => setState(() => _answers[_index] = i),
      onPrev: _index > 0 ? () => setState(() => _index--) : null,
      onNext: _answers.containsKey(_index)
          ? () {
              if (_index < lesson.quizQuestions.length - 1) {
                setState(() => _index++);
              } else {
                setState(() => _showResult = true);
              }
            }
          : null,
    );
  }

  Future<void> _markCompleteAndCelebrate(
    BuildContext context,
    Lesson lesson,
  ) async {
    if (_finishing) return;
    setState(() => _finishing = true);

    final provider = context.read<LearningProgressProvider>();
    final oldProgress = provider.progressToNextLevel;
    final result = await provider.completeLesson(lesson.id);
    final newProgress = provider.progressToNextLevel;

    if (!context.mounted) return;

    // On level-up the bar resets to 0..newProgress visually.
    final animateFrom = result.levelUp ? 0.0 : oldProgress;

    var navigatedAway = false;
    await XpAwardOverlay.show(
      context,
      result: result,
      oldProgress: animateFrom,
      newProgress: newProgress,
      onNextLesson: result.nextLesson == null
          ? null
          : () {
              navigatedAway = true;
              Navigator.of(context).pop(); // dismiss overlay
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(); // dismiss quiz
              }
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.lessonDetail,
                arguments:
                    LessonDetailArguments(lessonId: result.nextLesson!.id),
              );
            },
    );

    if (!mounted) return;
    setState(() => _finishing = false);
    if (!shouldPopAfterCompletionOverlay(navigatedAway: navigatedAway)) return;
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) {
      final name = route.settings.name;
      return name != AppRoutes.lessonQuiz && name != AppRoutes.lessonDetail;
    });
  }
}

class _QuestionView extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final int? selected;
  final ValueChanged<int> onSelect;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _QuestionView({
    required this.lesson,
    required this.index,
    required this.selected,
    required this.onSelect,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final q = lesson.quizQuestions[index];
    final total = lesson.quizQuestions.length;
    final isLast = index == total - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lesson.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (index + 1) / total,
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${index + 1} of $total',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        q.question,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                      ),
                      const SizedBox(height: 24),
                      ...List.generate(q.options.length, (i) {
                        final isSelected = selected == i;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _OptionTile(
                            text: q.options[i],
                            selected: isSelected,
                            onTap: () => onSelect(i),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onPrev != null)
                    OutlinedButton.icon(
                      onPressed: onPrev,
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Back'),
                    ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: onNext,
                    icon: Icon(
                      isLast ? Icons.check : Icons.arrow_forward,
                      size: 16,
                    ),
                    label: Text(isLast ? 'Finish' : 'Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: selected
          ? primary.withValues(alpha: isDark ? 0.18 : 0.08)
          : (isDark ? const Color(0xFF141820) : Colors.white),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? primary
                  : (isDark
                      ? const Color(0xFF262B35)
                      : const Color(0xFFE4E7EE)),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 18,
                color: selected
                    ? primary
                    : (isDark
                        ? const Color(0xFF5D6670)
                        : const Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: selected ? FontWeight.w600 : null,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final Lesson lesson;
  final int correct;
  final int total;
  final bool passed;
  final bool finishing;
  final bool alreadyCompleted;
  final VoidCallback onRetry;
  final VoidCallback onFinish;
  final VoidCallback onClose;

  const _ResultView({
    required this.lesson,
    required this.correct,
    required this.total,
    required this.passed,
    required this.finishing,
    required this.alreadyCompleted,
    required this.onRetry,
    required this.onFinish,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lesson.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.celebration : Icons.refresh,
                size: 64,
                color: passed
                    ? const Color(0xFF00B894)
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                passed ? 'You passed!' : 'Almost there',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                '$correct of $total correct',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 28),
              if (passed) ...[
                FilledButton.icon(
                  onPressed: finishing ? null : onFinish,
                  icon: finishing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check, size: 18),
                  label: Text(finishing
                      ? 'Saving…'
                      : alreadyCompleted
                          ? 'Continue'
                          : 'Claim ${lesson.xpReward} XP'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: onClose,
                  child: const Text('Close'),
                ),
              ] else ...[
                Text(
                  'You need 70% correct to mark this lesson complete.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retake quiz'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: onClose,
                  child: const Text('Back to lesson'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
