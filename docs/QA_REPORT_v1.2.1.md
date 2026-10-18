# DevPath v1.2.1 — QA report (quiz focus)

## Version
- **1.2.1+4** (Flutter `pubspec.yaml`)
- **Fix commit:** `8fad9e6989c60166e87db51f34bfbebba0e62e67` (quiz route stack) plus v1.2.1 validation/tests on release branch

## Root cause (confirmed in code review + regression tests)
Android **native WebView platform views** from routes left on the **root navigator** (e.g. after opening **Code Editor** or **Playground** and switching tabs without popping those routes) can draw **above** the lesson quiz. Flutter still paints the quiz **AppBar** and **progress bar**; question/options appear blank.

**Fix:** `openLessonQuiz()` uses `pushAndRemoveUntil` to keep only `MainShell`, plus `PlatformViewGate` while the quiz is open.

## Physical Android verification
**Not performed in the cloud build environment** (no Honor device / no emulator available in CI agent).

### Manual steps (Honor / any Android)
1. Install **v1.2.1 debug APK** (quizfix5 / v1.2.1 build below).
2. **Scenario B:** Home → **Code Editor** → switch to **Learn** (do not force-stop) → **The H1 Heading** → **Take Quiz**.
3. Expect: **Question 1 of 5**, full question text, **`<h1>`** option, **Next**.
4. **Scenario C:** Repeat after opening **Playground** instead of Code Editor.
5. **Scenario D:** Code Editor → Playground → Learn → H1 → Take Quiz.
6. Optional: `adb logcat | grep -E 'QuizDiagnostics|PlatformViewGate'`

Pass criteria: question, options, and Next/Finish visible and tappable; no blank body.

## Automated checks (agent run)
| Command | Result |
|---------|--------|
| `flutter analyze` | See release commit CI log |
| `flutter test` | See release commit (target: all green) |
| `flutter build apk --debug` | Debug APK artifact attached to release |

## Remaining risk
Until a physical device run completes scenarios B–D above, **do not treat the Honor blank-quiz issue as closed in production**.
