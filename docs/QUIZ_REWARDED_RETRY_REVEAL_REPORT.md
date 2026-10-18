# Quiz rewarded retry & answer reveal — final report

## 1. Architecture findings (Phase 1)

| Area | Finding |
|------|---------|
| Quiz UI | `LessonQuizScreen` — multi-question flow, `QuizQuestion` model with `correctIndex` + optional `explanation` |
| Progress | `LearningProgressProvider.completeLesson` — only path for lesson XP/completion (unchanged) |
| AdMob | `google_mobile_ads` + `RewardedAdCoordinator` (single in-flight session, test unit ID) |
| Post-quiz ads | Existing `RewardedAdPurpose.postQuizContinue` after result close (unchanged behavior) |
| Android quiz | Bottom-sheet launcher + `PlatformViewGate` unchanged |

## 2. Files changed

- `lib/core/ads/rewarded_ad_purpose.dart` — purpose enum (post-quiz / extra attempt / reveal)
- `lib/core/ads/rewarded_ad_coordinator.dart` — generic `showRewardedAd(purpose: …)`
- `lib/features/learning/logic/quiz_attempt_session.dart` — ephemeral attempt state
- `lib/features/learning/widgets/quiz_answer_feedback.dart` — incorrect / reveal UI
- `lib/features/learning/screens/lesson_quiz_screen.dart` — per-question check, retry/reveal wiring
- Tests: `quiz_attempt_session_test.dart`, `quiz_rewarded_retry_reveal_test.dart`, updated quiz flow/layout tests

## 3. Features implemented

- **Check answer** validates each question; correct → advance; incorrect → feedback without ad.
- **Try Again — free** → `QuizAttemptSession.restartFromBeginning` (Q1, clears answers/reveals for attempt).
- **Watch ad for another attempt** → `RewardedAdPurpose.quizExtraAttempt`; retry only if `rewardGranted`.
- **Reveal answer — watch ad** → `RewardedAdPurpose.answerReveal`; shows correct option + explanation after `rewardGranted`.
- Pre-submit reveal button on question screen (optional).
- **Continue quiz** after incorrect answer (no ad) to avoid trapping users.

## 4. AdMob test configuration

- Unit ID: Google sample rewarded ID via `AdMobConfig.rewardedAdUnitId` (override: `ADMOB_REWARDED_UNIT_ID`).
- Manifest: existing test App ID (unchanged).
- No production IDs enabled.

## 5. Retry & reveal behavior

| Action | Ad purpose | Grant condition |
|--------|------------|-----------------|
| Extra attempt | `quizExtraAttempt` | `RewardedAdFlowResult.rewardGranted` only |
| Answer reveal | `answerReveal` | `rewardGranted` only |
| Post-quiz continue | `postQuizContinue` | Navigation gate (no quiz retry/reveal) |

Dismissal without reward shows explicit message; free restart always available on incorrect feedback.

## 6. Reward verification

- Rewards applied in UI **after** coordinator returns `rewardGranted` (callback sets `rewardReported` before dismiss).
- Coordinator blocks concurrent requests (`_sessionInFlight`).
- Retry and reveal use **different** purposes; mocks/tests assert no cross-grant.
- Quiz XP still only via `completeLesson` on pass + claim.

## 7. Tests & results

- New: attempt session unit tests, retry/reveal widget tests with purpose mock gateway.
- Updated: H1 flow, layout, navigation, post-quiz ad flow (Check answer label).
- **Automated:** run `flutter test` locally (mocked ads only).
- **Not performed:** physical device AdMob fill.

## 8. Build

```bash
export PATH="/opt/flutter/bin:$PATH"
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## 9. Remaining risks

- Real ad latency/fill on device not validated in CI.
- UMP/consent and production ad units not configured.
- Long incorrect-feedback copy + buttons may need further small-screen tuning.

## 10. Physical device tests required

- H1 quiz on Android (WebView gate regression).
- Rewarded retry + reveal with Google test ads on device.
- Offline / airplane mode ad unavailable messaging.
- Background/resume during ad playback.
