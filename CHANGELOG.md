# Changelog

## 1.3.0 — AdMob integration & platform features

### 1.3.0+15
- App version **1.3.0+15** (`pubspec.yaml`, `lib/core/app_version.dart`).
- Official AdMob App ID and ad units (rewarded, banner, interstitial) with **debug test IDs** vs **release production IDs** (`lib/core/ads/admob_config.dart`, debug manifest overlay).
- Rewarded placements unchanged grant rules (`questionTimerRetry`, post-quiz continue, etc.).
- Home dashboard footer banner; lesson-transition interstitial with frequency cap.
- Android “Open with” for web file types (separate PR #9 on related branch).

### Notes
- UMP consent **not** integrated — see `docs/ADMOB_AND_MONETIZATION.md`.
- Physical ad and quiz regression QA: `docs/BETA_QA_CHECKLIST.md`.

## 1.2.1 — Quiz reliability (Android)

### 1.2.1+6
- Quiz questions/options render in **AppBar bottom** (Honor WebView often covers Scaffold body only).
- **ActiveWebViewTracker** detaches ghost WebViews after Code Editor route is popped.
- Profile **About** shows real version (was hardcoded v1.0.0).

### 1.2.1+5
- Quiz open: `popUntil` shell, hard WebView detach (`about:blank`) via registry, longer frame teardown.
- Main shell mounts only the active tab (no `IndexedStack`) so hidden tabs cannot retain platform views.
- Debug quiz label `v1.2.1+5` on question screen (debug APK only).

### Bugs fixed
- **Android blank lesson quiz:** Stale **Code Editor** / **Playground** WebView routes on the root navigator could paint over the quiz body (AppBar + progress visible, questions invisible). Quiz now opens with `pushAndRemoveUntil`, keeping only `MainShell`, while `PlatformViewGate` suspends platform views.
- Quiz layout uses a single full-screen scaffold and `QuizBodyShell` so a collapsed body shows an explicit error instead of a silent blank area.
- Quiz definitions are validated before render; invalid catalog data surfaces a retry screen instead of crashing.

### Tests
- Stale Code Editor, Playground, and combined route regressions.
- H1 five-question flow through pass result; width checks at 360–430dp.
- Catalog-wide quiz validation including H1 (5 questions) and b01_html (3 questions).

### Notes
- Physical-device verification on Honor hardware is required before treating the Android quiz fix as fully closed; see `docs/QA_REPORT_v1.2.1.md`.

## 1.2.0 — Curriculum mobile harden

### Bugs fixed
- Lesson path nodes no longer draw a **completed** lesson as locked after a new first lesson (`h1_heading`) is inserted.
- Unlock precedence is now deterministic: **completed > current/unlocked > locked**.
- Completed lessons stay tappable on the path and the roadmap.
- Figure WebViews allow the initial offline `data:` / `about:` document and still block http(s).
- Missing curriculum JSON no longer shows a parse-failure banner; only invalid files do.
- Progress JSON coerces messy field types so one bad value cannot wipe XP or completions.
- Overlapping progress saves coalesce to the latest snapshot instead of dropping or racing.
- Quiz / challenge "Next" actions no longer pop the freshly pushed screen.
- Quiz questions scroll on 360–430dp phones instead of overflowing.
- Path nodes only animate the current lesson (no per-node pulse rebuilds).
- Locked lessons cannot be completed out of order; completed lessons stay open.
- Quiz completion returns to the previous screen (roadmap/dashboard), not a leftover lesson.
- Figure HTML uses an offline CSP; H1 exercise starter no longer loads a remote image.
- Syntax breakdown and ASCII figures no longer overflow or nest-scroll on 360–430dp.
- Lesson detail pins Take Quiz / Open Playground below the scroll area so Android WebViews cannot steal taps.
- Quiz screen reads route arguments in `didChangeDependencies` with visible errors when init fails.

### Mobile UX
- Lesson detail is redesigned for 360–430dp Android phones (wrap chips, responsive type, 16–20dp inset).
- Progressive disclosure: core lesson expanded, deep-dive topics collapsed.
- Code blocks scroll horizontally, never wrap, and include Copy.
- Figures are width-bounded with timeout/failure fallback (offline WebView).
- Timeline is vertical and compact.
- Skeleton loading instead of a blank screen; JSON failure falls back to the catalog description.

### Curriculum
- Gold-standard `h1_heading` lesson is first in the beginner path.
- Rich JSON supports `summary`, `objectives`, `blocks`/`content`, `quickRecap`, `exercise`, `project`.
- Unknown blocks are skipped (debug-logged) and never crash the lesson.

### Compatibility
- Existing SharedPreferences progress, XP, streaks, and badges are not reset.
- Lessons without JSON still use the original fallback layout.
- Playground, quiz, challenges, ads, certificates, and project save/load are unchanged.
