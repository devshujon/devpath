# Changelog

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
