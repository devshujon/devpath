# Changelog

## 1.2.0 — Curriculum mobile harden

### Bugs fixed
- Lesson path nodes no longer draw a **completed** lesson as locked after a new first lesson (`h1_heading`) is inserted.
- Unlock precedence is now deterministic: **completed > current/unlocked > locked**.
- Completed lessons stay tappable on the path and the roadmap.

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
