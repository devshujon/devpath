# Physical QA — PR #11 Web Dev Ecosystem (Honor device)

**Status:** Pending — do not mark pass until recorded on a physical device.  
**Version under test:** `1.3.0+15` debug APK  
**Branch:** `cursor/web-dev-ecosystem-982f`

Record device model, Android version, screen width (dp), date, and tester initials for each section.

## Layout — filter chips (360 / 390 / 430 dp)

Use developer display width or a resizable emulator matching Honor viewports.

| Width | Learn screen chips scroll | No horizontal clip on Roadmap | Result |
|------:|---------------------------|-------------------------------|--------|
| 360 | | | Pending |
| 390 | | | Pending |
| 430 | | | Pending |

Tracks to spot-check: **All**, **PHP**, **SQL**, **TypeScript**, **Python**, **Web Dev**.

## Extended track navigation (offline)

Airplane mode ON after APK install.

| Track | Open lesson | Rich content loads | Quiz opens | Result |
|-------|-------------|-------------------|------------|--------|
| PHP (`php_24` Prepared Statements) | | | | Pending |
| SQL (`sql_36` SQL Injection) | | | | Pending |
| TypeScript (`typescript_10` Generics) | | | | Pending |
| Python (`python_01`) | | | | Pending |
| Web Essentials (`web_essentials_23` API errors) | | | | Pending |

## Existing user progress (upgrade path)

1. Install build **before** PR #11 (or import backup `learning_progress_v1` if available).
2. Complete at least `h1_heading` and one intermediate HTML lesson.
3. Install PR #11 debug APK **over** the previous install (same `applicationId` debug suffix).

| Check | Expected | Result |
|-------|----------|--------|
| Completed lessons still show complete | Yes | Pending |
| Intermediate HTML not re-locked | Yes | Pending |
| XP total unchanged | Yes | Pending |
| Re-complete same lesson | No extra XP | Pending |

## Playground (HTML/CSS/JS)

| Step | Expected | Result |
|------|----------|--------|
| Open playground from HTML lesson | Editor + preview | Pending |
| Run starter HTML | Static preview on Android | Pending |
| PHP lesson “Try code” if shown | No fake PHP execution | Pending |

## H1 quiz / WebView regression

| Step | Expected | Result |
|------|----------|--------|
| Open `h1_heading`, scroll figures if present | No ghost WebView | Pending |
| Open playground, back, open quiz | Quiz tappable, full-screen sheet | Pending |
| Complete quiz, navigate away | No overlapping WebView | Pending |

## XP and quiz retry

| Step | Expected | Result |
|------|----------|--------|
| Pass quiz first time | XP awarded once | Pending |
| Fail quiz, retry pass | XP rules unchanged vs pre-PR | Pending |
| Rewarded timer retry (if enabled in build) | Grant only on reward callback | Pending |

## Sign-off

- [ ] All critical rows filled with Pass/Fail notes  
- [ ] Failures filed as GitHub issues with lesson ID and screenshot  
- **Ready for merge:** only after critical paths Pass on physical device
