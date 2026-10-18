# Web Development Learning Ecosystem — Implementation Report

## Baseline

| Item | Value |
|------|--------|
| Start branch | `cursor/admob-official-config-982f` @ `d634192` |
| Work branch | `cursor/web-dev-ecosystem-982f` |
| Version before/after | **1.3.0+15** (unchanged) |

## Tracks implemented

| Track | Lessons | Curriculum JSON | Quizzes |
|-------|--------:|-----------------|---------|
| HTML (existing) | 13 | 2 rich + catalog fallback | Yes |
| CSS (existing) | 12 | catalog | Yes |
| JavaScript (existing) | 12 | catalog | Yes |
| Capstone (existing) | 1 | catalog | Yes |
| **PHP** | 40 | 40 bundled | 3× per lesson |
| **SQL/MySQL** | 40 | 40 bundled | 3× per lesson |
| **TypeScript** | 16 | 16 bundled | 3× per lesson |
| **Python** | 20 | 20 bundled | 3× per lesson |
| **Web Development Essentials** | 45 | 45 bundled | 3× per lesson |
| **Total catalog** | **199** | 163 new JSON files | |

## Key code changes

- `LessonTrack` extended; `LessonTrack.filterChips` for Learn/Roadmap.
- `track_unlock_policy.dart` — web-core interleave vs independent tracks; preserves HTML/CSS/JS gates.
- Generated data: `php_lessons.dart`, `sql_lessons.dart`, `typescript_lessons.dart`, `python_lessons.dart`, `web_essentials_lessons.dart`.
- `TrackFilterRow` shared widget.
- Projects track: **16** projects (6 new cross-track entries).
- Tests: `test/learning/web_dev_tracks_test.dart`.

## Editor / runtime limitations

- Playground executes **HTML/CSS/JS** only (Android static preview policy unchanged).
- **No** on-device PHP, SQL, or Python runtime — lessons state this explicitly.
- TypeScript is **content + examples**; compile on a computer.

## Validation

| Check | Result |
|-------|--------|
| `flutter test` | **171/171** pass |
| `flutter analyze` | 0 errors (info/warnings incl. generated const noise) |
| `flutter build apk --debug` | Success |
| Release APK/AAB | **Not built** (per instructions) |

## Content quality (PR #11 hardening)

**13 priority lessons** have hand-authored quizzes + richer curriculum via `tool/learning_tracks/priority_lesson_overrides.dart`:

`php_22`, `php_23`, `php_24`, `php_37`, `sql_17`–`sql_20`, `sql_36`, `typescript_09`, `typescript_10`, `web_essentials_23`, `web_essentials_28`.

Regenerate: `dart run tool/generate_learning_tracks.dart` (overrides merge into catalog + JSON).

Remaining extended lessons still use generator templates — expand overrides incrementally.

## Physical device QA

Required: filter chips at 360/390/430dp, lesson open offline, quiz flow, verify web-core progress unchanged after upgrade.

## Recommended next step

Hand-refine high-traffic lessons (PHP prepared statements, SQL injection, TS generics) and replace template quiz questions with topic-specific assessments; add track certificates only if product wants them.
