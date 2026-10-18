# PR #7 — Physical device QA checklist (not executed in CI)

**Branch:** `cursor/quiz-result-rewarded-982f` (features merged forward)  
**Original PR #7 target:** `1.2.1+14`  
**Current release retest:** `1.3.0+15` — re-run this checklist on a build showing **v1.3.0+15** in About / quiz debug label.

## Android platform regression (H1 / WebView)

1. Playground → **Run** → **Live Preview**
2. **Back** to lesson
3. Open **H1 Heading** → **Take Quiz**
4. Confirm quiz renders (no blank/black overlay); complete or exit cleanly

## Timer

5. Confirm countdown visible per question (~30s default)
6. Submit answer before expiry → timer stops, next question gets fresh timer
7. Let timer expire → **Time's Up!**; options disabled
8. **Restart quiz — free** → question 1, new timer
9. Expire again → **Watch ad to retry** (test ad) → same question, timer reset, prior answers on earlier questions unchanged (if applicable)
10. **Exit quiz** during expired state → no crash; re-open quiz OK

## Lifecycle

11. Background app mid-countdown → foreground → timer paused/resumed reasonably
12. Background during ad load → return → recoverable UI (no infinite spinner)

## Ads (Google test units only)

13. Dismiss ad early → no retry grant; free restart still works
14. Airplane mode / no fill → message + free restart

Record device model, Android version, and build (`flutter build apk --debug`).
