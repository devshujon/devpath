import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_version.dart';
import '../../../core/debug/quiz_diagnostics.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/quiz_body_shell.dart';
import '../data/lessons_catalog.dart';
import '../logic/lesson_progression.dart';
import '../logic/lesson_quiz_validator.dart';
import '../models/lesson.dart';
import '../providers/learning_progress_provider.dart';
import '../widgets/xp_award_overlay.dart';

class LessonQuizScreen extends StatefulWidget {
  const LessonQuizScreen({
    super.key,
    this.initialArgs,
    this.onRequestClose,
  });

  /// When set (Android overlay), route [ModalRoute] arguments are not required.
  final LessonDetailArguments? initialArgs;
  final VoidCallback? onRequestClose;

  static const route = '/lesson-quiz';

  @override
  State<LessonQuizScreen> createState() => _LessonQuizScreenState();
}

class _LessonQuizScreenState extends State<LessonQuizScreen> {
  Lesson? _lesson;
  String? _argsLessonId;
  String? _initError;
  bool _initializing = true;
  int _index = 0;
  final Map<int, int> _answers = {};
  bool _showResult = false;
  bool _finishing = false;

  static const double _passingThreshold = 0.7;

  LessonDetailArguments? _resolveArgs() {
    if (widget.initialArgs != null) return widget.initialArgs;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is LessonDetailArguments) return args;
    return null;
  }

  void _closeQuiz() {
    if (widget.onRequestClose != null) {
      widget.onRequestClose!();
      return;
    }
    Navigator.maybePop(context);
  }

  @override
  void initState() {
    super.initState();
    final args = widget.initialArgs;
    if (args != null) {
      _loadLessonFromArgs(args);
    }
  }

  void _loadLessonFromArgs(LessonDetailArguments args) {
    if (_argsLessonId == args.lessonId && _lesson != null) {
      _initializing = false;
      return;
    }
    _argsLessonId = args.lessonId;
    QuizDiagnostics.log('init lessonId=${args.lessonId}');
    final loaded = LessonsCatalog.byId(args.lessonId);
    if (loaded == null) {
      _initializing = false;
      _lesson = null;
      _initError = 'Lesson not found: ${args.lessonId}';
      return;
    }
    final validationErrors = validateLessonQuiz(loaded);
    QuizDiagnostics.log(
      'loaded ${loaded.id} questions=${loaded.quizQuestions.length} '
      'validationErrors=${validationErrors.length}',
    );
    if (validationErrors.isNotEmpty) {
      _initializing = false;
      _lesson = null;
      _initError = validationErrors.join('\n');
      return;
    }
    _lesson = loaded;
    _initError = null;
    _initializing = false;
    _index = 0;
    _answers.clear();
    _showResult = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.initialArgs != null) return;
    final args = _resolveArgs();
    if (args == null) {
      if (_initError == null && _lesson == null) {
        setState(() {
          _initializing = false;
          _initError = 'Quiz could not start (missing lesson).';
        });
      }
      return;
    }
    if (_argsLessonId == args.lessonId && _lesson != null) return;
    setState(() => _loadLessonFromArgs(args));
  }

  void _retryInit() {
    setState(() {
      _initializing = true;
      _initError = null;
      _lesson = null;
      _argsLessonId = null;
      final args = _resolveArgs() ?? widget.initialArgs;
      if (args != null) {
        _loadLessonFromArgs(args);
      } else {
        _initializing = false;
        _initError = 'Quiz could not start (missing lesson).';
      }
    });
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

  Widget _fullScreen(Widget child) => SizedBox.expand(child: child);

  @override
  Widget build(BuildContext context) {
    try {
      return SizedBox.expand(
        child: ColoredBox(
          color: Colors.white,
          child: _buildQuizContent(context),
        ),
      );
    } catch (e, st) {
      QuizDiagnostics.log('Quiz build failed: $e\n$st');
      return const SizedBox.expand(
        child: ColoredBox(
          color: Colors.white,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Quiz could not display. Force-stop the app and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildQuizContent(BuildContext context) {
    if (_initializing) {
      return _fullScreen(Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: Text('Quiz · v$kAppFullVersionLabel'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading quiz…'),
            ],
          ),
        ),
      ));
    }

    final lesson = _lesson;
    if (lesson == null) {
      return _fullScreen(Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: Text('Quiz · v$kAppFullVersionLabel'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _initError ?? "Couldn't load this quiz.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _retryInit,
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _closeQuiz,
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ));
    }
    final locked = context.select<LearningProgressProvider, bool>(
      (p) => p.lessonWithProgress(lesson).isLocked,
    );
    if (locked) {
      return _fullScreen(Scaffold(
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
                  onPressed: _closeQuiz,
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ));
    }
    if (lesson.quizQuestions.isEmpty) {
      return _fullScreen(Scaffold(
        appBar: AppBar(
          title: Text(
            lesson.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No questions available for this lesson.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: _closeQuiz,
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ));
    }
    if (_showResult) {
      return _fullScreen(_ResultView(
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
        onClose: _closeQuiz,
      ));
    }
    return _fullScreen(_buildQuestionScaffold(context, lesson));
  }

  Widget _buildQuestionScaffold(BuildContext context, Lesson lesson) {
    final index = _index;
    final q = lesson.quizQuestions[index];
    final total = lesson.quizQuestions.length;
    final isLast = index == total - 1;
    final selected = _answers[index];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.darkText : AppColors.lightText;
    final subtle = isDark ? AppColors.darkSubtle : AppColors.lightSubtle;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;

    QuizDiagnostics.log(
      'build question index=$index/$total text=${q.question.length} chars '
      'options=${q.options.length}',
    );

    // High-contrast quiz panel on Android (ghost WebView is often full-screen black).
    final useLightQuizPanel =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final panelBg =
        useLightQuizPanel ? const Color(0xFFF4F6FA) : bg;
    final panelFg =
        useLightQuizPanel ? const Color(0xFF0F1419) : fg;
    final panelSubtle =
        useLightQuizPanel ? const Color(0xFF5D6670) : subtle;

    return Material(
      color: useLightQuizPanel ? Colors.white : bg,
      child: SafeArea(
        child: QuizBodyShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (useLightQuizPanel)
                Container(
                  width: double.infinity,
                  color: const Color(0xFFFFD54F),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    'Quiz dialog · v$kAppFullVersionLabel',
                    style: const TextStyle(
                      color: Color(0xFF0F1419),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _closeQuiz,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Text(
                        lesson.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: fg,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              LinearProgressIndicator(
                value: (index + 1) / total,
                minHeight: 4,
                backgroundColor: isDark
                    ? const Color(0xFF262B35)
                    : const Color(0xFFE4E7EE),
              ),
              Expanded(
                child: ColoredBox(
                  color: panelBg,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    children: [
                      Text(
                        'Build $kAppFullVersionLabel · Question ${index + 1} of $total',
                        style: TextStyle(color: panelSubtle, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        q.question,
                        style: TextStyle(
                          color: panelFg,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
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
                            onTap: () => setState(() => _answers[index] = i),
                            forceLightChrome: useLightQuizPanel,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              ColoredBox(
                color: panelBg,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      if (index > 0)
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _index--),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back'),
                        ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: _answers.containsKey(index)
                            ? () {
                                if (index < total - 1) {
                                  setState(() => _index++);
                                } else {
                                  setState(() => _showResult = true);
                                }
                              }
                            : null,
                        icon: Icon(
                          isLast ? Icons.check : Icons.arrow_forward,
                          size: 16,
                        ),
                        label: Text(isLast ? 'Finish' : 'Next'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
              Navigator.of(context).pop(); // dismiss XP overlay
              widget.onRequestClose?.call();
              Navigator.of(context, rootNavigator: true).pushReplacementNamed(
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
    if (widget.onRequestClose != null) {
      widget.onRequestClose!();
      return;
    }
    Navigator.of(context).popUntil((route) {
      final name = route.settings.name;
      return name != AppRoutes.lessonQuiz && name != AppRoutes.lessonDetail;
    });
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final bool forceLightChrome;

  const _OptionTile({
    required this.text,
    required this.selected,
    required this.onTap,
    this.forceLightChrome = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        forceLightChrome ? false : Theme.of(context).brightness == Brightness.dark;
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
