# Quiz timer + rewarded retry — report

## Branch & commit

- Branch: `cursor/quiz-result-rewarded-982f`
- Commit: (see `git log -1` after push)

## Version protection

- `pubspec.yaml` remains **`1.2.1+14`** (unchanged).

## Files changed

| File | Role |
|------|------|
| `lib/features/learning/logic/quiz_question_timer_config.dart` | Single config (`30s` default) |
| `lib/features/learning/logic/quiz_question_timer.dart` | Deadline-based timer, pause/resume |
| `lib/features/learning/widgets/quiz_question_timer_display.dart` | Countdown UI |
| `lib/features/learning/widgets/quiz_time_expired_panel.dart` | Time's up + actions |
| `lib/features/learning/screens/lesson_quiz_screen.dart` | Integration, lifecycle |
| `lib/core/ads/rewarded_ad_purpose.dart` | `questionTimerRetry` |
| Tests | `quiz_question_timer_test.dart`, `quiz_timer_rewarded_retry_test.dart` |

## Timer behavior

- Starts when a question becomes active (post-frame, one timer per question index).
- Stops on submit, back navigation, result/feedback modes, dispose.
- **Deadline-based** `remaining()`; 250ms UI tick only for display/expiry check.
- App background: pause; resume restores remaining budget.
- Cannot go negative; no callback after dispose (`mounted` checks).

## Rewarded retry (timeout)

- Purpose: `RewardedAdPurpose.questionTimerRetry` (separate from extra attempt / reveal).
- Grant: only `rewardGranted` → same question index, prior answers kept, timer reset to config duration.
- Alternatives: **Restart quiz — free**, **Exit quiz**; ad failure message, no infinite loader.

## Configuration

```dart
QuizQuestionTimerConfig.perQuestionDuration = Duration(seconds: 30);
```

## Tests

- Unit: timer remaining, stop, pause/resume, config default.
- Widget: countdown visible, expiry UI, correct stops timer, ad purpose, dismiss without grant, answers preserved.
- Full suite: `flutter test` (mocked ads).

## Validation commands

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Physical device still required

- Real rewarded fill for `questionTimerRetry`.
- H1 Android WebView / platform-view regression.
- Background/foreground timer pause on device.

## Risks

- Production AdMob / UMP not configured (test IDs only).
- CI does not run real ads.
