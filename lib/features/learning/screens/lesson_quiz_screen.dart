import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ads/interstitial_ad_coordinator.dart';
import '../../../core/ads/rewarded_ad_coordinator.dart';
import '../../../core/ads/rewarded_ad_purpose.dart';
import '../../../core/app_version.dart';
import '../../../core/debug/quiz_diagnostics.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/quiz_attempt_session.dart';
import '../logic/quiz_post_result_flow.dart';
import '../logic/quiz_question_timer.dart';
import '../logic/quiz_question_timer_config.dart';
import '../widgets/quiz_answer_feedback.dart';
import '../widgets/quiz_question_timer_display.dart';
import '../widgets/quiz_time_expired_panel.dart';
import '../widgets/quiz_body_shell.dart';
import '../widgets/quiz_post_result_continue.dart';
import '../widgets/quiz_result_panel.dart';
import '../data/lessons_catalog.dart';
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

class _LessonQuizScreenState extends State<LessonQuizScreen>
    with WidgetsBindingObserver {
  Lesson? _lesson;
  String? _argsLessonId;
  String? _initError;
  bool _initializing = true;
  QuizAttemptSession _session = QuizAttemptSession();
  bool _showResult = false;
  bool _awaitingQuestionFeedback = false;
  bool? _lastSubmitCorrect;
  bool _adBusy = false;
  String? _questionAdMessage;
  bool _finishing = false;
  bool _showPostContinue = false;
  bool _xpClaimedThisSession = false;
  CompletionResult? _completionResult;
  QuizPostResultPhase _postResultPhase = QuizPostResultPhase.resultVisible;
  bool _postCloseAdStarted = false;
  bool _navigatingNext = false;
  String? _adStatusMessage;
  QuizQuestionTimer? _questionTimer;
  Duration _timerRemaining = QuizQuestionTimerConfig.perQuestionDuration;
  bool _timeExpired = false;
  bool _timerPausedForLifecycle = false;
  bool _submitLocked = false;
  String? _timerAdMessage;
  int? _timerArmedForIndex;

  static const double _passingThreshold = 0.7;

  LessonDetailArguments? _resolveArgs() {
    if (widget.initialArgs != null) return widget.initialArgs;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is LessonDetailArguments) return args;
    return null;
  }

  void _closeQuiz() {
    _disposeQuestionTimer();
    if (widget.onRequestClose != null) {
      widget.onRequestClose!();
      return;
    }
    Navigator.maybePop(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final args = widget.initialArgs;
    if (args != null) {
      _loadLessonFromArgs(args);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeQuestionTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_showResult || _showPostContinue) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (!_timerPausedForLifecycle && _questionTimer?.isRunning == true) {
          _questionTimer?.pause();
          _timerPausedForLifecycle = true;
          if (mounted) setState(() {});
        }
      case AppLifecycleState.resumed:
        if (_timerPausedForLifecycle) {
          _questionTimer?.resume();
          _timerPausedForLifecycle = false;
          if (mounted) setState(() {});
        }
    }
  }

  void _disposeQuestionTimer() {
    _questionTimer?.dispose();
    _questionTimer = null;
  }

  void _armQuestionTimer() {
    _disposeQuestionTimer();
    _timeExpired = false;
    _submitLocked = false;
    _timerAdMessage = null;
    _timerRemaining = QuizQuestionTimerConfig.perQuestionDuration;
    _timerArmedForIndex = _session.questionIndex;
    _questionTimer = QuizQuestionTimer(
      onExpired: _handleQuestionTimeout,
      onTick: (remaining) {
        if (!mounted) return;
        setState(() => _timerRemaining = remaining);
      },
    )..start();
  }

  void _scheduleTimerForActiveQuestion() {
    if (_showResult || _showPostContinue || _awaitingQuestionFeedback) {
      _stopQuestionTimer();
      return;
    }
    if (_timeExpired) {
      _stopQuestionTimer();
      return;
    }
    final idx = _session.questionIndex;
    if (_timerArmedForIndex == idx && _questionTimer?.isRunning == true) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _session.questionIndex != idx) return;
      if (_timeExpired || _awaitingQuestionFeedback) return;
      _armQuestionTimer();
    });
  }

  void _stopQuestionTimer() {
    _questionTimer?.stop();
  }

  void _handleQuestionTimeout() {
    if (!mounted || _submitLocked || _timeExpired) return;
    if (_awaitingQuestionFeedback || _showResult) return;
    _stopQuestionTimer();
    _timerArmedForIndex = null;
    setState(() => _timeExpired = true);
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
    _session = QuizAttemptSession();
    _showResult = false;
    _awaitingQuestionFeedback = false;
    _lastSubmitCorrect = null;
    _questionAdMessage = null;
    _timeExpired = false;
    _timerAdMessage = null;
    _submitLocked = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _lesson != null) {
        _scheduleTimerForActiveQuestion();
      }
    });
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
      if (_session.answers[i] == lesson.quizQuestions[i].correctIndex) c++;
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
      return Theme(
        data: ThemeData.light(),
        child: SizedBox.expand(
          child: ColoredBox(
            color: Colors.white,
            child: _buildQuizContent(context),
          ),
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
    if (_showPostContinue) {
      final next = _completionResult?.nextLesson;
      return _fullScreen(
        QuizPostResultContinuePanel(
          phase: _postResultPhase,
          nextLesson: next,
          adStatusMessage: _adStatusMessage,
          navigateInProgress: _navigatingNext,
          onNext: _navigatingNext ? null : () => _navigateAfterQuiz(context, lesson),
        ),
      );
    }
    if (_showResult) {
      final alreadyCompleted = context.select<LearningProgressProvider, bool>(
        (p) => p.completedLessons.contains(lesson.id),
      );
      final xpHandled = _xpClaimedThisSession || alreadyCompleted;
      return _fullScreen(
        QuizResultPanel(
          lesson: lesson,
          correct: _correctCount,
          total: lesson.quizQuestions.length,
          passed: _passed,
          xpReward: lesson.xpReward,
          xpClaimed: xpHandled,
          claimInProgress: _finishing,
          onRetry: () {
            setState(() {
              _session = _session.restartFromBeginning(countRewardedRetry: false);
              _showResult = false;
              _awaitingQuestionFeedback = false;
              _postResultPhase = QuizPostResultPhase.resultVisible;
            });
          },
          onClaimXp: () => _markCompleteAndCelebrate(context, lesson),
          onClose: () => _onResultClose(context, lesson, xpHandled: xpHandled),
        ),
      );
    }
    return _fullScreen(_buildQuestionScaffold(context, lesson));
  }

  void _freeRestartAttempt() {
    _stopQuestionTimer();
    setState(() {
      _session = _session.restartFromBeginning(countRewardedRetry: false);
      _awaitingQuestionFeedback = false;
      _lastSubmitCorrect = null;
      _questionAdMessage = null;
      _timeExpired = false;
      _timerAdMessage = null;
      _submitLocked = false;
      _timerArmedForIndex = null;
    });
    _scheduleTimerForActiveQuestion();
  }

  Future<void> _rewardedTimerRetrySameQuestion() async {
    if (_adBusy || !_timeExpired) return;
    _adBusy = true;
    setState(() => _timerAdMessage = null);
    final outcome = await RewardedAdCoordinator.gateway.showRewardedAd(
      purpose: RewardedAdPurpose.questionTimerRetry,
    );
    if (!mounted) return;
    if (outcome == RewardedAdFlowResult.rewardGranted) {
      setState(() {
        _timeExpired = false;
        _submitLocked = false;
        _adBusy = false;
        _timerAdMessage = null;
        _timerArmedForIndex = null;
      });
      _armQuestionTimer();
      return;
    }
    setState(() {
      _adBusy = false;
      _timerAdMessage = _adOutcomeMessage(outcome);
    });
  }

  Future<void> _rewardedRetryAttempt() async {
    if (_adBusy) return;
    _adBusy = true;
    setState(() => _questionAdMessage = null);
    final outcome = await RewardedAdCoordinator.gateway.showRewardedAd(
      purpose: RewardedAdPurpose.quizExtraAttempt,
    );
    if (!mounted) return;
    if (outcome == RewardedAdFlowResult.rewardGranted) {
      setState(() {
        _session = _session.restartFromBeginning(countRewardedRetry: true);
        _awaitingQuestionFeedback = false;
        _lastSubmitCorrect = null;
        _adBusy = false;
        _questionAdMessage = null;
        _timeExpired = false;
        _timerArmedForIndex = null;
        _submitLocked = false;
      });
      _scheduleTimerForActiveQuestion();
      return;
    }
    setState(() {
      _adBusy = false;
      _questionAdMessage = _adOutcomeMessage(outcome);
    });
  }

  Future<void> _rewardedRevealCurrentQuestion(Lesson lesson) async {
    if (_adBusy) return;
    final index = _session.questionIndex;
    if (_session.isRevealed(index)) return;
    _adBusy = true;
    setState(() => _questionAdMessage = null);
    final outcome = await RewardedAdCoordinator.gateway.showRewardedAd(
      purpose: RewardedAdPurpose.answerReveal,
    );
    if (!mounted) return;
    if (outcome == RewardedAdFlowResult.rewardGranted) {
      setState(() {
        _session.markRevealed(index);
        _session.rewardedRevealsUsed++;
        _adBusy = false;
        _questionAdMessage = null;
      });
      return;
    }
    setState(() {
      _adBusy = false;
      _questionAdMessage = _adOutcomeMessage(outcome);
    });
  }

  String _adOutcomeMessage(RewardedAdFlowResult outcome) {
    return switch (outcome) {
      RewardedAdFlowResult.unavailable =>
        'Ad unavailable (offline or no fill). Use Try Again — free.',
      RewardedAdFlowResult.failed => 'Ad could not play. Try again later.',
      RewardedAdFlowResult.dismissedWithoutReward =>
        'Watch the full video to unlock this reward.',
      RewardedAdFlowResult.rewardGranted => '',
    };
  }

  void _submitCurrentAnswer(Lesson lesson) {
    if (_submitLocked || _timeExpired) return;
    final index = _session.questionIndex;
    final selected = _session.answers[index];
    if (selected == null) return;
    _submitLocked = true;
    _stopQuestionTimer();
    final q = lesson.quizQuestions[index];
    final correct = selected == q.correctIndex;
    if (correct) {
      final isLast = index >= lesson.quizQuestions.length - 1;
      setState(() {
        _awaitingQuestionFeedback = false;
        _lastSubmitCorrect = true;
        _timerArmedForIndex = null;
        if (isLast) {
          _showResult = true;
        } else {
          _session.questionIndex++;
          _lastSubmitCorrect = null;
          _submitLocked = false;
        }
      });
      if (!isLast) {
        _scheduleTimerForActiveQuestion();
      }
      return;
    }
    setState(() {
      _lastSubmitCorrect = false;
      _awaitingQuestionFeedback = true;
    });
  }

  void _continueAfterIncorrect(Lesson lesson) {
    final index = _session.questionIndex;
    final isLast = index >= lesson.quizQuestions.length - 1;
    _stopQuestionTimer();
    setState(() {
      _awaitingQuestionFeedback = false;
      _lastSubmitCorrect = null;
      _questionAdMessage = null;
      _submitLocked = false;
      _timerArmedForIndex = null;
      if (isLast) {
        _showResult = true;
      } else {
        _session.questionIndex++;
      }
    });
    if (!isLast) {
      _scheduleTimerForActiveQuestion();
    }
  }

  Widget _buildQuestionScaffold(BuildContext context, Lesson lesson) {
    final index = _session.questionIndex;
    final questionLocked =
        _timeExpired || _awaitingQuestionFeedback || _adBusy;
    final q = lesson.quizQuestions[index];
    final total = lesson.quizQuestions.length;
    final isLast = index == total - 1;
    final selected = _session.answers[index];
    final revealed = _session.isRevealed(index);
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
              if (useLightQuizPanel && kDebugMode)
                Container(
                  width: double.infinity,
                  color: const Color(0xFFFFD54F),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    'Quiz debug · v$kAppFullVersionLabel',
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
                    QuizQuestionTimerDisplay(
                      remaining: _timerRemaining,
                      expired: _timeExpired,
                      paused: _timerPausedForLifecycle,
                      adBusy: _adBusy,
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
                            onTap: questionLocked
                                ? null
                                : () => setState(
                                      () => _session.answers[index] = i,
                                    ),
                            forceLightChrome: useLightQuizPanel,
                          ),
                        );
                      }),
                      if (revealed) ...[
                        const SizedBox(height: 16),
                        QuizAnswerFeedback(
                          question: q,
                          wasIncorrect: _lastSubmitCorrect == false,
                          revealed: true,
                          adBusy: _adBusy,
                          adStatusMessage: null,
                          onFreeRestart: _freeRestartAttempt,
                          onRewardedRetry: _rewardedRetryAttempt,
                          onRewardedReveal: () =>
                              _rewardedRevealCurrentQuestion(lesson),
                          onContinue: () => _continueAfterIncorrect(lesson),
                          showContinue: _awaitingQuestionFeedback,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_timeExpired)
                QuizTimeExpiredPanel(
                  adBusy: _adBusy,
                  adStatusMessage: _timerAdMessage,
                  onWatchAdRetry: _rewardedTimerRetrySameQuestion,
                  onFreeRestart: _freeRestartAttempt,
                  onExitQuiz: _closeQuiz,
                ),
              if (_awaitingQuestionFeedback && !revealed)
                QuizAnswerFeedback(
                  question: q,
                  wasIncorrect: true,
                  revealed: false,
                  adBusy: _adBusy,
                  adStatusMessage: _questionAdMessage,
                  onFreeRestart: _freeRestartAttempt,
                  onRewardedRetry: _rewardedRetryAttempt,
                  onRewardedReveal: () =>
                      _rewardedRevealCurrentQuestion(lesson),
                  onContinue: () => _continueAfterIncorrect(lesson),
                ),
              ColoredBox(
                color: panelBg,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!revealed &&
                          !_awaitingQuestionFeedback &&
                          !_timeExpired &&
                          !_adBusy)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _rewardedRevealCurrentQuestion(lesson),
                            icon: const Icon(Icons.lightbulb_outline, size: 18),
                            label: const Text(
                              'Reveal answer — watch ad',
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          if (index > 0 &&
                              !_awaitingQuestionFeedback &&
                              !_timeExpired)
                            OutlinedButton(
                              onPressed: _adBusy
                                  ? null
                                  : () {
                                      _stopQuestionTimer();
                                      setState(() {
                                        _session.questionIndex--;
                                        _awaitingQuestionFeedback = false;
                                        _submitLocked = false;
                                        _timerArmedForIndex = null;
                                      });
                                      _scheduleTimerForActiveQuestion();
                                    },
                              child: const Text('Back'),
                            ),
                          if (index > 0 &&
                              !_awaitingQuestionFeedback &&
                              !_timeExpired)
                            const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _session.answers.containsKey(index) &&
                                      !_awaitingQuestionFeedback &&
                                      !_timeExpired &&
                                      !_adBusy &&
                                      !_submitLocked
                                  ? () => _submitCurrentAnswer(lesson)
                                  : null,
                              icon: Icon(
                                isLast ? Icons.check : Icons.arrow_forward,
                                size: 16,
                              ),
                              label: Text(isLast ? 'Finish' : 'Check answer'),
                            ),
                          ),
                        ],
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
    if (_finishing || _xpClaimedThisSession) return;
    setState(() {
      _finishing = true;
      _postResultPhase = QuizPostResultFlowLogic.beginClaimXp(_postResultPhase);
    });

    final provider = context.read<LearningProgressProvider>();
    final oldProgress = provider.progressToNextLevel;
    final result = await provider.completeLesson(lesson.id);
    final newProgress = provider.progressToNextLevel;

    if (!context.mounted) return;

    final animateFrom = result.levelUp ? 0.0 : oldProgress;

    await XpAwardOverlay.show(
      context,
      result: result,
      oldProgress: animateFrom,
      newProgress: newProgress,
    );

    if (!mounted) return;
    setState(() {
      _finishing = false;
      _xpClaimedThisSession = true;
      _completionResult = result;
      _postResultPhase = QuizPostResultFlowLogic.afterXpClaimed();
    });
  }

  void _ensureCompletionResult(BuildContext context) {
    if (_completionResult != null) return;
    final provider = context.read<LearningProgressProvider>();
    _completionResult = CompletionResult(
      xpEarned: 0,
      levelUp: false,
      newLevel: provider.currentLevel,
      newlyEarnedBadges: const [],
      nextLesson: provider.recommendedNextLesson,
    );
  }

  void _onResultClose(BuildContext context, Lesson lesson, {required bool xpHandled}) {
    if (!_passed || !xpHandled) {
      _closeQuiz();
      return;
    }
    if (_postCloseAdStarted) return;
    _ensureCompletionResult(context);
    _postCloseAdStarted = true;
    setState(() {
      _showResult = false;
      _showPostContinue = true;
      _postResultPhase = QuizPostResultFlowLogic.beginCloseAfterPass(
        passed: _passed,
        xpHandled: xpHandled,
        phase: _postResultPhase,
      );
      _postResultPhase = QuizPostResultFlowLogic.afterResultClosed();
    });
    _runPostCloseAdFlow();
  }

  Future<void> _runPostCloseAdFlow() async {
    if (!mounted) return;
    setState(() => _postResultPhase = QuizPostResultPhase.loadingRewardedAd);

    final outcome = await RewardedAdCoordinator.gateway.showRewardedAd(
      purpose: RewardedAdPurpose.postQuizContinue,
      onAdShowing: () {
        if (!mounted) return;
        setState(
          () => _postResultPhase = QuizPostResultFlowLogic.adNowShowing(),
        );
      },
    );

    if (!mounted) return;

    final adWasShown = outcome == RewardedAdFlowResult.rewardGranted ||
        outcome == RewardedAdFlowResult.dismissedWithoutReward;

    String? message;
    if (outcome == RewardedAdFlowResult.unavailable ||
        outcome == RewardedAdFlowResult.failed) {
      message = 'No ad available right now. You can continue learning.';
    }

    setState(() {
      _adStatusMessage = message;
      _postResultPhase = QuizPostResultFlowLogic.afterAdFlowResolved(
        adWasShown: adWasShown,
      );
    });
  }

  Future<void> _navigateAfterQuiz(BuildContext context, Lesson currentLesson) async {
    if (_navigatingNext) return;
    setState(() {
      _navigatingNext = true;
      _postResultPhase = QuizPostResultFlowLogic.beginNavigate();
    });

    // Natural transition after quiz flow — never during active questions.
    await InterstitialAdCoordinator.instance.maybeShowLessonTransition();

    final next = _completionResult?.nextLesson;
    if (!context.mounted) return;

    widget.onRequestClose?.call();

    final navigator = Navigator.of(context, rootNavigator: true);
    if (next != null) {
      await navigator.pushReplacementNamed(
        AppRoutes.lessonDetail,
        arguments: LessonDetailArguments(lessonId: next.id),
      );
    } else {
      navigator.popUntil((route) {
        final name = route.settings.name;
        return name == AppRoutes.shell ||
            name == AppRoutes.roadmap ||
            route.isFirst;
      });
      await navigator.pushNamed(AppRoutes.roadmap);
    }

    if (mounted) {
      setState(() => _navigatingNext = false);
    }
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;
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
    return Semantics(
      button: true,
      selected: selected,
      label: text,
      child: Material(
      color: selected
          ? primary.withValues(alpha: isDark ? 0.18 : 0.08)
          : (isDark ? const Color(0xFF141820) : Colors.white),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        // Disabled when onTap is null (feedback / ad in progress).
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
      ),
    );
  }
}

