# DevPath — Complete Application Audit Report

**Date:** 2026-10-14  
**Auditor:** Cloud agent (code + automated tests; limited device coverage)  
**Physical device evidence:** User screenshot — H1 quiz **visible and functional** on Honor/Android with **v1.2.1+13** (question, options, Next, progress).

---

## A. Executive summary

DevPath is a Flutter learning app (HTML/CSS/JS/PHP tracks, playground, mobile code editor, quizzes, XP, streaks, achievements, certificates, notifications). The **critical Honor blank-quiz regression is resolved** in the release line using **Android full-height bottom sheet + no WebView on Android editor/preview + platform-view lifecycle hardening**.

**Automated health:** `flutter analyze` clean; **89/89** widget/unit tests pass; debug APK ~**160 MB**; release APK ~**62 MB** (tree-shaken).

**Release readiness:** Suitable for **controlled debug/beta** on Android after targeted device regression (Editor → Learn → Quiz, Playground → Quiz, progress persistence). **Not** a blanket production PASS: AdMob/rewarded ads **not implemented in UI**, privacy URL TODO, and broad feature manual QA remain.

---

## B. Baseline

| Item | Value |
|------|--------|
| Branch audited | `cursor/release-v1-2-1-982f` (includes quiz fix; ahead of `cursor/mobile-code-editor-982f`) |
| Commit (pre-audit polish) | `6d10488` — quiz bottom sheet (1.2.1+13) |
| Working tree | Clean at audit start |
| App version | `1.2.1+13` (`pubspec.yaml`, `lib/core/app_version.dart`) |
| Flutter | 3.47.7 (Dart 3.13.5) |
| Android Gradle Plugin | 8.11.1 |
| Kotlin | 2.2.20 |
| compileSdk / targetSdk | 36 |
| minSdk | 24 |
| Java | 17 (OpenJDK 21 on CI VM) |

**Note:** User requested base branch `cursor/mobile-code-editor-982f`; quiz fixes and audit work live on **`cursor/release-v1-2-1-982f`**. Merge to mobile-code-editor or `main` is a separate integration step.

---

## C. Feature audit table

| Feature | Status | Evidence | Issues | Fixes in audit |
|---------|--------|----------|--------|----------------|
| Dashboard | OK | Code + layout tests | — | — |
| Learn / Roadmap | OK | Navigation routes, unlock tests | — | — |
| Lesson detail | OK | Layout tests 360–430dp | — | — |
| Curriculum JSON | OK | `lesson_content_test` all JSON | — | — |
| Lesson quiz (catalog) | OK | Catalog validation, flow tests | Honor overlay (was critical) | Fixed +13 bottom sheet |
| Quiz runner (advanced) | OK | Separate route `/quiz-runner` | Not same as lesson quiz | — |
| Playground | OK | Provider, autosave tests | Android preview = static HTML | By design (no WebView) |
| Code editor (mobile) | OK | Storage, provider tests | Android uses TextField not CodeMirror | `android_webview_policy.dart` |
| CodeMirror WebView | iOS/desktop | Policy | Android disabled | Intentional |
| Challenges / daily | OK | Providers in `main.dart` | Manual QA not run | — |
| Projects track | OK | Catalog + provider | — | — |
| Achievements / XP | OK | Idempotent `completeLesson` test | — | — |
| Certificates | OK | Provider wired | Manual QA not run | — |
| Notifications | Partial | Service + scheduler | Profile TODOs for permission flow | — |
| Profile / About | OK | Shows `kAppFullVersionLabel` | Privacy policy URL TODO | — |
| AdMob / rewarded ads | **Not in UI** | Manifest test App ID; plugin registered | No `MobileAds` in `lib/` | Documented risk |
| Offline curriculum | OK | Asset bundles, CSP on figures | — | — |

**Verification legend:** Code inspection + widget tests unless noted “physical device.”

---

## D. Critical bugs

| ID | Description | Status |
|----|-------------|--------|
| C1 | Android lesson quiz blank/black (WebView overlay / route compositing) | **Fixed** — verified on **physical device** (user screenshot, v1.2.1+13) |
| C2 | — | No other open critical bugs confirmed in code/tests |

---

## E. High-priority bugs

| ID | Description | Status |
|----|-------------|--------|
| H1 | Profile privacy policy tap no-op | Open — TODO in `profile_screen.dart` |
| H2 | Notification permission flow stubbed | Open — TODO |
| H3 | Release signing requires `key.properties` (not in repo) | Expected — release build used debug signing fallback |

---

## F. Medium-priority

- **Quiz UX:** Yellow debug strip shown on device builds — **audit change:** strip + open Snackbar only in **`kDebugMode`** for release polish.
- **Kotlin 2.2.20:** Flutter warns upgrade to 2.3.20+ soon.
- **42 outdated pub packages** (constraints) — schedule dependency review before store release.

---

## G. Low-priority

- Duplicate version constants (`pubspec` vs `app_version.dart`) — manual sync.
- Verbose `QuizDiagnostics` / `PlatformViewGate` logs in debug only — acceptable.

---

## H. UI/UX

- **Quiz (device screenshot):** Readable question, code tags, tappable options, disabled Next until selection, accurate progress — **verified on device**.
- **360/390/430dp:** Covered by `lesson_quiz_flow_test`, `lesson_detail_layout_test`, `lesson_quiz_layout_test`.
- **Debug-only chrome** on quiz reduced in audit commit.

---

## I. Security & privacy

| Area | Finding |
|------|---------|
| Permissions | INTERNET, NETWORK_STATE, AD_ID, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED |
| Exported activity | MainActivity only (launcher) |
| WebView navigation | Local schemes only in editor/preview; figures block http(s) |
| Secrets | No API keys in repo; AdMob **test** App ID in manifest |
| File import | `file_picker` — user-driven |
| Ads | Plugin present; **no ad widgets** — low runtime ad risk, manifest ID still test |

---

## J. WebView / platform views

| Surface | Android | Lifecycle |
|---------|---------|-----------|
| CodeMirror | **Off** — TextField | N/A |
| Playground preview | **Off** — static HTML | N/A |
| Curriculum figures | Flutter fallback | N/A |
| iOS/other | WebView + `RouteAware` + `PlatformViewGate` | Tests: `figure_route_overlay_test` |

**Quiz open (Android):** `PlatformViewGate.forceOpen()`, optional native `hideStaleWebViews` (hide only, no destroy).

**Not verified on device:** Editor → Playground (WebView off on Android) → Quiz; repeat 10× stress.

---

## K. Curriculum & quiz data

- **H1:** 5 questions — validated in `lesson_quiz_catalog_validation_test`.
- **b01_html:** 3 questions — validated.
- **JSON parse:** All bundled curriculum files — `lesson_content_test`.
- **Quiz validator:** `lesson_quiz_validator.dart` before render.

---

## L. Progress & storage

- **SharedPreferences** learning snapshot — coercion tests pass.
- **`completeLesson` idempotent** — `learning_progress_unlock_test`.
- **Unlock precedence:** completed > unlocked > locked — tested.
- **No destructive migrations** in audit scope.

---

## M. Performance

| Artifact | Size |
|----------|------|
| Debug APK | ~168 MB (unstripped, debug suffix) |
| Release APK | ~61.8 MB (minify + shrink + icon tree-shake) |

Large debug size is normal (debug symbols, no shrink). Release size acceptable for WebView + assets.

---

## N. Accessibility

- **Audit:** Added `Semantics` on quiz option tiles (button + selected + label).
- **Remaining:** Full TalkBack pass on device not run; result screen announcements not customized.

---

## O. Files changed (audit polish)

- `lib/features/learning/screens/lesson_quiz_screen.dart` — debug banner gating; semantics on options
- `lib/features/learning/logic/lesson_quiz_launcher.dart` — debug-only Snackbar
- `test/learning/lesson_quiz_scoring_test.dart` — threshold + option tap test
- `docs/DEVPAT_COMPLETE_AUDIT_REPORT.md` — this report

---

## P. Tests added

- `test/learning/lesson_quiz_scoring_test.dart` (2 tests)

**Total suite:** 89 tests (was 87).

---

## Q. `flutter analyze`

**No issues found** (after audit changes).

---

## R. `flutter test`

**89/89 passed.**

---

## S. Debug build

**Success** — `app-debug.apk` ~167,945,213 bytes.

---

## T. Release build

**Success** — `app-release.apk` ~61,782,839 bytes (signing: debug keystore when `key.properties` absent).

---

## U. Remaining risks

1. Quiz bottom sheet on OEMs not tested beyond user’s Honor device.
2. iOS WebView quiz path uses `MaterialPageRoute` — not re-verified on iPhone.
3. AdMob production IDs and rewarded flow not implemented.
4. Privacy policy / notification UX incomplete.
5. Widget tests do **not** prove native WebView compositing.

---

## V. Physical device tests still recommended

1. Code Editor → Learn → H1 → Quiz → complete → back (10×).
2. Playground → Learn → Quiz.
3. Kill app mid-quiz; reopen — progress intact.
4. Fail quiz (retake); pass quiz — XP once only.
5. TalkBack on quiz options and Next.
6. Certificate / notification flows on real device.

---

## W. Release-readiness assessment

| Criterion | Assessment |
|-----------|------------|
| Core learning + quiz on Android | **Ready for controlled beta** (device evidence for H1 quiz) |
| Google Play production | **Not ready** — privacy URL, ads strategy, signing, broader QA |
| Regression safety | **Good** — 89 automated tests, analyze clean |

**Overall:** **Conditional GO** for **v1.2.1 debug/beta** on Android; **NO-GO** for silent production store release without items in §U and §V.

---

*No source ZIP or store release artifact created (not requested).*
