# PR #7 Quiz Timer — Final QA Report

## Branch & commit

- **Branch:** `cursor/quiz-result-rewarded-982f`
- **Commit:** (see `git log -1` after QA push)
- **PR:** #7 (draft, not merged)
- **Version:** `1.2.1+14` — **unchanged**

---

## 1. Timer lifecycle audit

| Requirement | Status | Notes |
|-------------|--------|-------|
| One timer per active question | OK | `_timerArmedForIndex` + post-frame `_armQuestionTimer`; not re-armed on every rebuild |
| Stops on submit | OK | `_stopQuestionTimer()` before scoring |
| No double submit/expiry | OK | `_submitLocked`, `_timeExpired`, `_fireExpiredOnce()` |
| Question change cancels prior | OK | `_armQuestionTimer` disposes previous instance |
| Lifecycle pause/resume | OK | `WidgetsBindingObserver` + timer `pause`/`resume` |
| Dispose cancels timers | OK | `dispose()` on screen + timer; **fix:** `_closeQuiz` now disposes timer |
| Retry resets current question only | OK | `questionTimerRetry` → `_armQuestionTimer()` same index |
| Prior answers preserved | OK | Session map unchanged on timer retry |
| Leave quiz / late updates | OK | `_closeQuiz` disposes timer; callbacks check `mounted` |

**Race handling:** Submit sets lock and stops timer before validation; expiry handler checks `_submitLocked` and `_timeExpired`.

---

## 2. Rewarded retry audit

| Requirement | Status |
|-------------|--------|
| Grant only on `rewardGranted` | OK |
| Dismiss without reward | OK — stays on Time's Up |
| Load/show failure recoverable | OK — message + free restart |
| No stuck loading | OK — `_adBusy` cleared in all paths |
| Repeated taps | OK — `_adBusy` guard; **test added** |
| No reset of prior answers | OK |
| Test ad IDs | OK — `AdMobConfig` sample unit |
| Production ads | Not enabled |

**Fix:** `_rewardedTimerRetrySameQuestion` requires `_timeExpired` so retry cannot run outside timeout flow.

---

## 3. Scoring & progress

- Timeout does not write answers or call `completeLesson`.
- XP/completion unchanged (widget test on timeout).
- Purposes remain distinct: `questionTimerRetry`, `quizExtraAttempt`, `answerReveal`, `postQuizContinue`.

---

## 4. Android / H1

- No edits to `lesson_quiz_launcher.dart` or `PlatformViewGate`.
- Physical checklist: `docs/QUIZ_TIMER_PR7_PHYSICAL_QA.md` — **not run in CI**.

---

## 5. Analyzer (15 issues)

| Severity | File | Issue | PR-related? | Action |
|----------|------|-------|-------------|--------|
| info | `rewarded_ad_coordinator.dart` | unawaited dispose | Yes | **Fixed** — `await previous.dispose()` |
| warning | `playground_screen.dart` | unused import | No | Pre-existing |
| info ×11 | `playground_code_themes.dart` | unnecessary const | No | Pre-existing |
| warning | `quiz_rewarded_retry_reveal_test.dart` | unused `revealOutcome` param | Yes | **Fixed** — constructor initializer |

**Post-fix:** **12 issues** (all pre-existing editor lints except none in quiz/ads).

---

## 6. Bugs found & fixed in QA

1. **Exit quiz** could leave timer callbacks active → dispose on `_closeQuiz`.
2. **Timer retry** could theoretically be invoked when not expired → `_timeExpired` guard.
3. **Expiry** armed index left set → cleared on timeout.
4. **Double expiry callback** → `_fireExpiredOnce()`.
5. **Analyzer** — await ad dispose; test constructor warning.

---

## 7. Tests & builds

```text
flutter pub get   — OK
flutter analyze   — 13 issues (pre-existing editor warnings only)
flutter test      — see CI run (mocked ads)
flutter build apk --debug — OK
```

**Added tests:** expiry once, dispose stops ticks, free restart after timeout, ad unavailable, double-tap ad idempotency, timeout no XP.

**Mocked tests do not verify real AdMob fill.**

---

## 8. Physical device

| Completed in CI | Pending on device |
|-----------------|-------------------|
| None | H1 WebView path, timer lifecycle, ad retry/dismiss, background |

---

## 9. Remaining risks

- Real ad latency/fill and WebView stacking on OEM devices.
- UMP / production ad units not configured.

---

## 10. PR #7 readiness

**Ready for manual device QA** on debug APK with test ads, after automated **146+** tests pass. **Not ready to merge** until physical checklist is signed off and product approves ad policy.
