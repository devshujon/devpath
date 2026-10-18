# AdMob and monetization — DevPath v1.3.0

## Configuration (PR: official DevPath units)

| Item | Debug / profile | Release |
|------|-----------------|---------|
| Android **App ID** (manifest) | Google **test** `…~3347511713` (`src/debug/`) | Production `ca-app-pub-3995622198490756~4702943512` |
| Rewarded (`questionTimerRetry` + other placements) | Google test unit | `…/6724892612` (DevPath_Quiz_Timer_Retry) |
| Banner (Home dashboard footer) | Google test banner | `…/3876947009` (DevPath_Main_Banner) |
| Interstitial (after lesson quiz navigation) | Google test interstitial | `…/4098729279` (DevPath_Lesson_Interstitial) |

Dart unit selection: `AdMobConfig.useProductionAdUnitIds` → `false` when `kDebugMode`, else `true`.  
Override release QA: `--dart-define=ADMOB_FORCE_TEST_IDS=true`.

**Never** put an ad **unit** ID in the manifest `APPLICATION_ID` field.

## Placements

- **Rewarded:** Quiz timer retry, extra attempt, answer reveal, post-quiz continue — reward granted **only** after SDK `onUserEarnedReward` + dismiss path in `RewardedAdCoordinator`.
- **Banner:** Home tab (`DashboardScreen`) footer only — not on Learn, quiz, or lesson detail.
- **Interstitial:** After completed quiz when navigating to next lesson/roadmap (`_navigateAfterQuiz`), min **15 minutes** between shows.

## Consent / review status

- **UMP (User Messaging Platform) is not integrated.** `AdMobConsent.prepareForAds()` logs a release reminder only.
- **Do not claim** AdMob/Play ad approval or live production serving without console verification and device tests.
- Privacy: `docs/legal/PRIVACY_POLICY.md` — update before production ads in EEA/UK.

## SDK initialization

Single init via `RewardedAdCoordinator.ensureInitialized()` → `MobileAds.instance.initialize()`. Banner/interstitial preload after that.

## Physical QA still required

- Test ads in **debug APK** (test App ID + test units).
- Production unit fill on **release** build with real device + AdMob account linked to package `com.devpath.app`.
- Timer retry: watch full rewarded ad → time restored; dismiss early → no retry.
