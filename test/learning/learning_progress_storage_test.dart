import 'package:devpath/features/learning/providers/learning_progress_provider.dart';
import 'package:devpath/features/learning/services/learning_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LearningProgressData.fromJson', () {
    test('coerces messy types without wiping XP or completions', () {
      final data = LearningProgressData.fromJson({
        'completedLessons': ['b01_html', 42, '', null],
        'currentXP': '150',
        'streakDays': 3.0,
        'longestStreak': '7',
        'totalMinutesLearned': true,
        'lastActiveDate': 'not-a-date',
        'earnedBadges': ['first_lesson', 1],
      });

      expect(data.completedLessons, {'b01_html', '42'});
      expect(data.currentXP, 150);
      expect(data.streakDays, 3);
      expect(data.longestStreak, 7);
      expect(data.totalMinutesLearned, 0);
      expect(data.lastActiveDate, isNull);
      expect(data.earnedBadges, {'first_lesson', '1'});
    });

    test('round-trips a healthy snapshot unchanged', () {
      final original = LearningProgressData(
        completedLessons: const {'h1_heading', 'b01_html'},
        currentXP: 100,
        streakDays: 2,
        longestStreak: 4,
        totalMinutesLearned: 20,
        lastActiveDate: DateTime(2026, 9, 21),
        earnedBadges: const {'first_lesson'},
      );
      final restored = LearningProgressData.fromJson(original.toJson());
      expect(restored.completedLessons, original.completedLessons);
      expect(restored.currentXP, 100);
      expect(restored.streakDays, 2);
      expect(restored.longestStreak, 4);
      expect(restored.totalMinutesLearned, 20);
      expect(restored.earnedBadges, original.earnedBadges);
      expect(restored.lastActiveDate, original.lastActiveDate);
    });
  });

  test('overlapping XP writes persist the latest total', () async {
    final provider = LearningProgressProvider.test(
      const LearningProgressData(currentXP: 0),
    );

    await Future.wait([
      provider.addXP(10),
      provider.addXP(25),
    ]);

    expect(provider.currentXP, 35);
    final stored = await LearningStorage.instance.load();
    expect(stored.currentXP, 35);
  });

  test('completing a lesson persists XP without resetting other fields', () async {
    SharedPreferences.setMockInitialValues({
      'learning_progress_v1':
          '{"completedLessons":["b01_html"],"currentXP":50,"streakDays":2,"longestStreak":2,"totalMinutesLearned":8,"earnedBadges":[]}',
    });

    final existing = await LearningStorage.instance.load();
    expect(existing.completedLessons, {'b01_html'});
    expect(existing.currentXP, 50);

    final provider = LearningProgressProvider.test(existing);
    await provider.completeLesson('h1_heading');

    final stored = await LearningStorage.instance.load();
    expect(stored.completedLessons, containsAll(['b01_html', 'h1_heading']));
    expect(stored.currentXP, greaterThanOrEqualTo(100));
    expect(stored.streakDays, greaterThan(0));
  });
}
