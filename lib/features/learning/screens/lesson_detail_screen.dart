import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../curriculum/models/curriculum_load_result.dart';
import '../../curriculum/models/lesson_block.dart';
import '../../curriculum/services/curriculum_loader.dart';
import '../../curriculum/theme/lesson_type.dart';
import '../../curriculum/widgets/block_renderer.dart';
import '../../curriculum/widgets/lesson_blocks.dart';
import '../../curriculum/widgets/lesson_skeleton.dart';
import '../../quiz_engine/models/quiz_item.dart';
import '../../quiz_engine/screens/quiz_runner_screen.dart';
import '../../quiz_engine/services/quiz_set_loader.dart';
import '../data/lessons_catalog.dart';
import '../models/lesson.dart';
import '../providers/learning_progress_provider.dart';

class LessonDetailArguments {
  final String lessonId;
  const LessonDetailArguments({required this.lessonId});
}

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({super.key});
  static const route = '/lesson-detail';

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  String? _loadedId;
  CurriculumLoadResult? _result;
  bool _loading = true;
  Future<QuizSet?>? _quizFuture;

  void _ensureLoad(Lesson lesson) {
    if (_loadedId == lesson.id) return;
    _loadedId = lesson.id;
    _quizFuture = QuizSetLoader.instance.load(lesson.id);
    _loading = true;
    _result = null;
    _load(lesson);
  }

  Future<void> _load(Lesson lesson) async {
    final result = await CurriculumLoader.instance.loadResult(lesson);
    if (!mounted || _loadedId != lesson.id) return;
    setState(() {
      _loading = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as LessonDetailArguments?;
    if (args == null) return const _MissingArgs();

    final raw = LessonsCatalog.byId(args.lessonId);
    if (raw == null) return _MissingLesson(id: args.lessonId);

    _ensureLoad(raw);

    final isCompleted = context.select<LearningProgressProvider, bool>(
      (p) => p.completedLessons.contains(raw.id),
    );
    final nextId = context.select<LearningProgressProvider, String?>(
      (p) => p.nextUnlockedIdAfter(raw.id),
    );
    final lesson = raw.copyWith(isCompleted: isCompleted, isLocked: false);
    final next = nextId == null ? null : LessonsCatalog.byId(nextId);
    final content = _result?.content;
    final accent = lesson.track.color;
    final pad = LessonType.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lesson.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: _MetaChip(
                text: lesson.difficulty.label,
                color: lesson.difficulty.color,
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(pad, 8, pad, 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _LessonHero(lesson: lesson, accent: accent),
                const SizedBox(height: 14),
                _MetaWrap(lesson: lesson),
                if (content?.objectives.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  _Objectives(items: content!.objectives, accent: accent),
                ],
                const SizedBox(height: 18),
                if (_loading) const LessonSkeleton(),
                if (!_loading && content != null)
                  BlockRenderer(
                    key: ValueKey<String>('blocks-${lesson.id}'),
                    content: content,
                    accent: accent,
                    onTryCode: (code, lang) => _openPlaygroundWith(
                      context,
                      lesson,
                      _slotFor(lang, code),
                    ),
                    onOpenStarter: (starter) =>
                        _openPlaygroundWith(context, lesson, starter),
                  ),
                if (!_loading && content == null) ...[
                  if (_result?.showFailureBanner == true)
                    const _LoadFallbackBanner(),
                  _SimpleAbout(lesson: lesson),
                  const SizedBox(height: 16),
                  ExerciseBlockView(
                    ExerciseBlock(
                      prompt:
                          'Practice this lesson in the playground. Use the starter code, tap Run, then come back for the quiz.',
                      starterCode: lesson.starterCode,
                      checks: const [],
                    ),
                    accent,
                    onStart: (starter) =>
                        _openPlaygroundWith(context, lesson, starter),
                  ),
                  const SizedBox(height: 16),
                  QuickRecapView(
                    items: [
                      lesson.description,
                      'Practice in the playground, then take the quiz to earn XP.',
                    ],
                    accent: accent,
                  ),
                ],
                const SizedBox(height: 22),
                _EndOfLesson(
                  lesson: lesson,
                  next: next,
                  onQuiz: () => _openQuiz(context, lesson),
                  onPlayground: () => _openPlayground(context, lesson),
                  onNext: next == null ? null : () => _openLesson(context, next),
                ),
                _AdvancedPracticeStep(future: _quizFuture, lesson: lesson),
                SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _openPlayground(BuildContext context, Lesson lesson) {
    Navigator.pushNamed(
      context,
      AppRoutes.playground,
      arguments: PlaygroundArguments(
        lessonId: lesson.id,
        starterCode: lesson.starterCode,
      ),
    );
  }

  void _openPlaygroundWith(
    BuildContext context,
    Lesson lesson,
    Map<String, String> starter,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.playground,
      arguments: PlaygroundArguments(
        lessonId: lesson.id,
        starterCode: starter,
      ),
    );
  }

  Map<String, String> _slotFor(String lang, String code) {
    final slot = (lang == 'css' || lang == 'js') ? lang : 'html';
    return {'html': '', 'css': '', 'js': '', slot: code};
  }

  void _openQuiz(BuildContext context, Lesson lesson) {
    Navigator.pushNamed(
      context,
      AppRoutes.lessonQuiz,
      arguments: LessonDetailArguments(lessonId: lesson.id),
    );
  }

  void _openLesson(BuildContext context, Lesson lesson) {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.lessonDetail,
      arguments: LessonDetailArguments(lessonId: lesson.id),
    );
  }
}

class _LessonHero extends StatelessWidget {
  final Lesson lesson;
  final Color accent;
  const _LessonHero({required this.lesson, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.18),
            accent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.track.label.toUpperCase(),
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(lesson.title, style: LessonType.titleStyle(context)),
          const SizedBox(height: 8),
          Text(lesson.description, style: LessonType.bodyStyle(context)),
        ],
      ),
    );
  }
}

class _MetaWrap extends StatelessWidget {
  final Lesson lesson;
  const _MetaWrap({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetaChip(
          text: '${lesson.estimatedMinutes} min',
          color: Theme.of(context).hintColor,
          icon: Icons.schedule,
        ),
        _MetaChip(
          text: lesson.difficulty.label,
          color: lesson.difficulty.color,
        ),
        _MetaChip(
          text: '+${lesson.xpReward} XP',
          color: Theme.of(context).colorScheme.primary,
          icon: Icons.star_outline,
        ),
        if (lesson.isCompleted)
          const _MetaChip(
            text: 'Completed',
            color: Color(0xFF00B894),
            icon: Icons.check_circle,
          ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const _MetaChip({required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Objectives extends StatelessWidget {
  final List<String> items;
  final Color accent;
  const _Objectives({required this.items, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What you will learn', style: LessonType.subheadStyle(context)),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline, size: 18, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item, style: LessonType.bodyStyle(context)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SimpleAbout extends StatelessWidget {
  final Lesson lesson;
  const _SimpleAbout({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About this lesson', style: LessonType.sectionStyle(context)),
        const SizedBox(height: 8),
        Text(lesson.description, style: LessonType.bodyStyle(context)),
      ],
    );
  }
}

class _LoadFallbackBanner extends StatelessWidget {
  const _LoadFallbackBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB020).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "Some rich lesson content couldn't be loaded. You can still read the summary and practice below.",
        style: LessonType.secondaryStyle(context),
      ),
    );
  }
}

class _EndOfLesson extends StatelessWidget {
  final Lesson lesson;
  final Lesson? next;
  final VoidCallback onQuiz;
  final VoidCallback onPlayground;
  final VoidCallback? onNext;

  const _EndOfLesson({
    required this.lesson,
    required this.next,
    required this.onQuiz,
    required this.onPlayground,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final accent = lesson.track.color;
    if (lesson.isCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF00B894).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF00B894).withValues(alpha: 0.28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF00B894)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lesson complete',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '+${lesson.xpReward} XP earned · keep the streak going.',
              style: LessonType.secondaryStyle(context),
            ),
            const SizedBox(height: 14),
            if (onNext != null && next != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    minimumSize: const Size.fromHeight(kLessonMinTap),
                  ),
                  onPressed: onNext,
                  child: Text(
                    'Continue to ${next!.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onQuiz,
                icon: const Icon(Icons.quiz_outlined),
                label: const Text('Retake quiz'),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lessonCardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: lessonBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("You've reached the end!", style: LessonType.sectionStyle(context)),
          const SizedBox(height: 6),
          Text(
            'Practice in the playground, then take the quiz to mark this lesson complete and earn XP.',
            style: LessonType.bodyStyle(context),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(kLessonMinTap),
              ),
              onPressed: onQuiz,
              icon: const Icon(Icons.quiz_outlined),
              label: const Text('Take Quiz'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPlayground,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Open Playground'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedPracticeStep extends StatelessWidget {
  final Lesson lesson;
  final Future<QuizSet?>? future;
  const _AdvancedPracticeStep({required this.lesson, required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuizSet?>(
      future: future,
      builder: (context, snap) {
        final set = snap.data;
        if (set == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.quizRunner,
                arguments: QuizRunnerArguments(
                  lessonId: lesson.id,
                  title: set.title,
                ),
              ),
              icon: const Icon(Icons.psychology_alt_outlined),
              label: Text('Advanced practice · ${set.items.length} questions'),
            ),
          ),
        );
      },
    );
  }
}

class _MissingArgs extends StatelessWidget {
  const _MissingArgs();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Lesson not provided. Open from the Roadmap.'),
        ),
      );
}

class _MissingLesson extends StatelessWidget {
  final String id;
  const _MissingLesson({required this.id});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Lesson not found: $id')),
      );
}
