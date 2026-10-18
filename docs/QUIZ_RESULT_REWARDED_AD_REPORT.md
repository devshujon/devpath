# Quiz result redesign & rewarded ad flow — report

## Files changed

| Area | Files |
|------|--------|
| Result UI | `lib/features/learning/widgets/quiz_result_panel.dart` |
| Post-close continue | `lib/features/learning/widgets/quiz_post_result_continue.dart` |
| State machine | `lib/features/learning/logic/quiz_post_result_flow.dart` |
| Quiz screen wiring | `lib/features/learning/screens/lesson_quiz_screen.dart` |
| AdMob | `lib/core/ads/admob_config.dart`, `lib/core/ads/rewarded_ad_coordinator.dart` |
| App init | `lib/main.dart` |
| Tests | `test/learning/quiz_rewarded_ad_flow_test.dart`, `test/learning/quiz_post_result_flow_test.dart`, `test/core/rewarded_ad_coordinator_test.dart`, `test/learning/lesson_quiz_flow_test.dart` (expectations) |

## Result screen improvements

- Score card with animated circular progress, accuracy %, pass/fail badge, and XP line from real quiz data.
- Pass copy: **Excellent Work!** (perfect) / **Quiz Completed!** (pass); fail copy: **Keep Practicing!** with no false success state.
- Lesson title in app bar; theme-aware colors via `AppColors`; reduced-motion skips score animation.
- Claim XP uses existing `LearningProgressProvider.completeLesson` + `XpAwardOverlay` (no duplicate next-lesson shortcut on overlay).

## Rewarded ad implementation

- `RewardedAdCoordinator` wraps official `RewardedAd.load` / `show` with test unit ID default (`AdMobConfig`, overridable via `ADMOB_REWARDED_UNIT_ID`).
- `RewardedAdGateway` + `debugGatewayOverride` for mocked tests.
- `MobileAds.instance.initialize()` in `main.dart` (fail-soft offline).
- Single in-flight ad session; dispose on dismiss/failure; reward callback does **not** grant quiz XP or alter lesson progress.

## Navigation flow

1. Finish quiz → redesigned result.
2. **Claim XP** → overlay → result shows **XP claimed**.
3. **Close** (passed + XP handled) → result closes → **Loading** → rewarded ad if available.
4. After ad completes / unavailable / failed → **Next Lesson →** (or **Back to Roadmap** when no `CompletionResult.nextLesson`).
5. **Next** uses `CompletionResult.nextLesson` from provider (roadmap rules unchanged).

Failed quiz: **Close** exits quiz immediately (no ad gate).

## XP duplication protection

- `_xpClaimedThisSession` + disabled claim button while `_finishing`.
- `completeLesson` remains idempotent.
- Ad reward callback is intentionally empty (monetization only).

## Offline / ad-unavailable

- Load/show failures → short message + **Next** (no infinite spinner; 12s load timeout).
- Web/tests use unavailable path via mock or platform guard.

## Tests (mocked ads)

Covers: perfect/partial/fail results, single XP claim, close → ad once, unavailable fallback, next button visibility. **Real AdMob delivery not tested** — mocks only.

## Validation (this run)

Run locally:

```bash
export PATH="/opt/flutter/bin:$PATH"
flutter analyze
flutter test
flutter build apk --debug
```

## Limitations

- Production ad unit IDs and UMP consent not configured (manifest still uses Google **test** App ID).
- Physical device ad fill not verified in CI.
- Post-close panel is a separate in-quiz phase (result UI is hidden before ad); full-screen ad covers continue UI while showing.
