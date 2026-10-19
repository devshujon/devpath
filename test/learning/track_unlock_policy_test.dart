import 'package:devpath/features/learning/data/lessons_catalog.dart';
import 'package:devpath/features/learning/logic/track_unlock_policy.dart';
import 'package:devpath/features/learning/models/lesson.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web core sequential ids exclude php', () {
    final lesson = LessonsCatalog.byId('b01_html')!;
    final ids = sequentialUnlockIdsFor(
      lesson: lesson,
      sameDifficulty: LessonsCatalog.byDifficulty(Difficulty.beginner),
    );
    expect(ids.every((id) {
      final l = LessonsCatalog.byId(id)!;
      return l.track == LessonTrack.html ||
          l.track == LessonTrack.css ||
          l.track == LessonTrack.js;
    }), isTrue);
    expect(ids, isNot(contains('php_01')));
  });

  test('php sequential ids are track-local', () {
    final lesson = LessonsCatalog.byId('php_03')!;
    final ids = sequentialUnlockIdsFor(
      lesson: lesson,
      sameDifficulty: LessonsCatalog.byDifficulty(Difficulty.beginner),
    );
    expect(ids.first, 'php_01');
    expect(ids, contains('php_03'));
    expect(ids, isNot(contains('b01_html')));
  });
}
