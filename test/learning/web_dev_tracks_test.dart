import 'package:devpath/features/curriculum/services/curriculum_loader.dart';
import 'package:devpath/features/learning/data/lessons_catalog.dart';
import 'package:devpath/features/learning/logic/lesson_quiz_validator.dart';
import 'package:devpath/features/learning/models/lesson.dart';
import 'package:devpath/features/learning/providers/learning_progress_provider.dart';
import 'package:devpath/features/learning/services/learning_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('lesson ids are unique across full catalog', () {
    final ids = LessonsCatalog.all.map((l) => l.id).toList();
    expect(ids.length, ids.toSet().length);
  });

  test('filter chips cover extended tracks', () {
    expect(LessonTrack.filterChips, contains(LessonTrack.php));
    expect(LessonTrack.filterChips, contains(LessonTrack.webEssentials));
    expect(LessonTrack.filterChips, isNot(contains(LessonTrack.capstone)));
  });

  test('track lesson counts match prompt targets', () {
    expect(LessonsCatalog.byTrack(LessonTrack.php).length, 40);
    expect(LessonsCatalog.byTrack(LessonTrack.sql).length, 40);
    expect(LessonsCatalog.byTrack(LessonTrack.typescript).length, 16);
    expect(LessonsCatalog.byTrack(LessonTrack.python).length, 20);
    expect(LessonsCatalog.byTrack(LessonTrack.webEssentials).length, 45);
    expect(LessonsCatalog.byTrack(LessonTrack.html).length, 13);
  });

  test('generated track quizzes validate', () {
    for (final lesson in LessonsCatalog.all) {
      if (lesson.track == LessonTrack.html ||
          lesson.track == LessonTrack.css ||
          lesson.track == LessonTrack.js ||
          lesson.track == LessonTrack.capstone) {
        continue;
      }
      expect(validateLessonQuiz(lesson), isEmpty, reason: lesson.id);
    }
  });

  test('web core intermediate gate ignores new track beginner lessons', () {
    final provider = LearningProgressProvider.test(
      const LearningProgressData(
        completedLessons: {
          'h1_heading',
          'b01_html',
          'b02_css',
          'b03_js',
          'html_links',
          'css_selectors',
          'js_operators',
          'html_lists',
          'css_box_model',
          'js_conditionals',
          'html_images',
          'css_colors',
          'js_loops',
        },
        currentXP: 500,
      ),
    );
    final inter = provider.lessonsByDifficulty(Difficulty.intermediate);
    final htmlSemantic = inter.firstWhere((l) => l.id == 'html_semantic');
    expect(htmlSemantic.isLocked, isFalse);
  });

  test('php track unlocks sequentially within track', () {
    final provider = LearningProgressProvider.test(LearningProgressData.empty);
    final first = LessonsCatalog.byId('php_01')!;
    final second = LessonsCatalog.byId('php_02')!;
    expect(provider.lessonWithProgress(first).isLocked, isFalse);
    expect(provider.lessonWithProgress(second).isLocked, isTrue);
  });

  test('bundled curriculum JSON loads for sample php lesson', () async {
    final lesson = LessonsCatalog.byId('php_01')!;
    final content = await CurriculumLoader.instance.load(lesson);
    expect(content, isNotNull);
    expect(content!.id, 'php_01');
    expect(content.objectives, isNotEmpty);
  });
}
