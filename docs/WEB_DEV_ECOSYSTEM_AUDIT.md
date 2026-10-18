# DevPath Web Development Ecosystem — Phase 1 Audit

**Recorded:** 2026-10-18  
**Branch (start):** `cursor/admob-official-config-982f` @ `d634192`  
**Implementation branch:** `cursor/web-dev-ecosystem-982f`

## Version (unchanged)

| Field | Value |
|-------|--------|
| pubspec | `1.3.0+15` |
| Android applicationId | `com.devpath.app` (debug suffix `.debug`) |

## Architecture map (pre-change baseline)

| Layer | Location | Role |
|-------|----------|------|
| Lesson catalog | `lib/features/learning/data/lessons_catalog.dart` | Canonical 38 lessons (HTML/CSS/JS + capstone) |
| Rich curriculum | `assets/curriculum/<track>/<id>.json` | Optional overlay via `CurriculumLoader` |
| Progress | `learning_progress_v1` SharedPreferences | XP, completions, badges |
| Quiz | Embedded `QuizQuestion` in catalog + `LessonQuizScreen` | Primary assessment |
| Learn UI | `learn_screen.dart`, `roadmap_screen.dart` | Filters + path |
| Playground | `playground_screen.dart` | HTML/CSS/JS only; Android static preview policy |
| WebView safety | `platform_view_gate.dart`, quiz modal + `forceOpen` | No WebView quiz overlay |
| Projects | `projects_track_catalog.dart` | 9 guided projects |

## Reuse decision

- Extend `LessonTrack` + `LessonsCatalog` (no duplicate progress/quiz engines).
- Per-track unlock policy so new lessons do not re-lock HTML/CSS/JS intermediate gates.
- Generator: `tool/generate_learning_tracks.dart` + `tool/learning_tracks/track_specs.dart`.
