# DevPath — Rich Lesson System Architecture

**Status:** Design (no implementation yet)
**Scope:** Lesson content model, JSON schema, lesson UI/UX, curriculum tooling, roadmap
**Constraints carried from the existing app:** offline-first, no backend, Provider + SharedPreferences/Hive, no breaking changes to the lesson / quiz / XP / streak / achievement / roadmap systems already shipped.

---

## 0. The core tension, and how this design resolves it

You asked for three things that pull in different directions:

- **Duolingo** wants *short, addictive, do-focused* sessions.
- **Wikipedia** wants *long, deep, read-focused* reference.
- **A history museum** wants *narrative and context*.

If every lesson dumps 1,500 words and 15 sections on a beginner the moment they tap a node, the Duolingo loop dies — people bounce. If we cut the history to keep it short, the museum dies.

**Resolution: tier the content, not the lessons.** Every lesson carries all 15 ingredients, but they're sorted into three tiers with different visibility:

| Tier | Visibility | Purpose | Holds |
|---|---|---|---|
| **Core** | Always visible, ~4–6 min read | The Duolingo path — learn enough to pass the quiz | Introduction, visual explanation, beginner + advanced examples, best practices, common mistakes |
| **Deep Dive** | Collapsed by default ("History & Deep Dive" card) | The Wikipedia + museum layer — optional depth | History, who/when/why created, problem solved, evolution timeline, industry use cases, interview questions, fun facts |
| **Practice** | Action buttons at the end | The Duolingo payoff — gamified doing | Quiz, coding challenge, mini project |

A casual learner reads Core, taps the quiz, earns XP, moves on — fast loop intact. A curious learner expands the Deep Dive and gets the full museum. **Same lesson, two audiences, one data file.** This single idea drives the entire architecture below.

---

## 1. Content architecture — your 15 sections, mapped

Nothing you listed is dropped. Here's where each requested element lives and how it's represented (block types defined in Part 2):

| # | Your requirement | Tier | Represented as |
|---|---|---|---|
| 1 | Introduction | Core | `prose` |
| 5 | Visual explanation | Core | `figure` (offline diagram — see Part 4) |
| 7 | Beginner examples | Core | `code` (with "Try in Playground") |
| 8 | Advanced examples | Core | `code` |
| 11 | Common mistakes | Core | `callout` (warning) + `codeCompare` (wrong → right) |
| 10 | Best practices | Core | `callout` (tip) + `list` |
| 2 | What it is | Core | folded into Introduction `prose` |
| 3 | Why it exists | Core → lead-in | `callout` (info) at top of Core, expanded in Deep Dive |
| — | History | Deep Dive | `factSheet` + `prose` + `timeline` |
| 4 | Who created it | Deep Dive | `factSheet` row |
| 5b | When created | Deep Dive | `factSheet` row + `timeline` |
| 6 | What problem it solved | Deep Dive | `factSheet` row + `prose` |
| 7b | How it evolved | Deep Dive | `timeline` |
| 9 | Where used today | Deep Dive / Core | `realWorld` (named sites/companies) |
| 11b | Industry use cases | Deep Dive | `realWorld` + `prose` |
| 12 | Interview questions | Deep Dive | `interviewQA` (collapsible Q→A) |
| 13 | Fun facts | Deep Dive | `quote` / `callout` (fact) |
| 14 | Historical timeline | Deep Dive | `timeline` |
| — | Quiz | Practice | `quiz` (reuses existing `QuizQuestion`) |
| — | Coding challenge | Practice | `challengeRef` (points at the existing challenges feature) |
| 15 | Mini project | Practice | `projectPrompt` (opens Playground with starter) |

**The lesson is an ordered list of typed blocks.** That's the whole content model. A lesson author doesn't write a screen; they write a sequence of blocks in JSON, and the renderer knows how to draw each type. New pedagogy later = new block type, authored without touching existing lessons.

---

## 2. The reusable content section library (block types)

This is the heart of the scalable system — a small, fixed vocabulary of block types. Every lesson, in every track (HTML/CSS/JS/PHP), is composed from these. Think of it as "portable text" (the pattern Notion, Sanity, and Contentful use).

| Block `type` | Renders as | Key fields | Used for |
|---|---|---|---|
| `prose` | Rich paragraph(s), inline `code`, **bold**, links | `md` (markdown-lite string) | Explanations, narrative |
| `heading` | Section header inside a tier | `text`, `level` | Structure |
| `callout` | Colored box w/ icon | `variant` (`info`/`tip`/`warning`/`fact`), `md` | Why-it-exists, best practices, mistakes, fun facts |
| `list` | Bulleted/numbered | `ordered`, `items[]` | Best-practice checklists |
| `code` | Syntax-styled code card + optional **Try in Playground** button | `lang`, `code`, `runnable`, `caption` | Examples (beginner/advanced/interactive) |
| `codeCompare` | Two stacked cards: ❌ wrong / ✅ right | `wrong`, `right`, `lang`, `note` | Common mistakes |
| `figure` | Rendered diagram (see Part 4) | `kind`, `spec`, `caption` | Visual explanation |
| `factSheet` | Compact key→value card | `rows[]` (`label`,`value`) | Who/when/problem-solved |
| `timeline` | Vertical dated milestones | `entries[]` (`year`,`title`,`detail`) | Evolution / history |
| `realWorld` | Chips/cards of named sites or companies | `items[]` (`name`,`note`) | Where used today, industry usage |
| `quote` | Pull-quote w/ attribution | `text`, `author` | Fun facts, historical quotes |
| `interviewQA` | List of collapsible Q→A | `items[]` (`q`,`a`) | Interview prep |
| `projectPrompt` | Brief + "Open in Playground" | `title`, `brief`, `starterCode{html,css,js}` | Mini project |
| `challengeRef` | Card linking to a challenge | `challengeId` | Coding challenge handoff |
| `quiz` | (Not a content block — see note) | — | Practice gate |
| `deepDive` | **Container** that renders its children **collapsed** | `title`, `children[]` (blocks) | The "History & Deep Dive" section |

Two structural notes:

- **`deepDive` is a container block.** It holds an array of any other blocks and renders them inside a single collapsible card titled "History & Deep Dive" (expandable, collapsed by default, remembers expansion per-lesson). This is the explicit feature you asked for, and because it nests ordinary blocks, authors compose it from the same vocabulary.
- **`quiz` stays where it already is.** You already have a working `QuizQuestion` model and `lesson_quiz_screen`. The rich content does *not* re-invent quizzes; it references them. Quiz questions remain a top-level `quiz[]` array on the lesson (as today), not a content block, so the existing quiz flow is untouched.

### Section templates (authoring shortcuts)

To keep 37+ lessons consistent, define **named block sequences** authors copy. Example — the standard "History & Deep Dive" template is always:

```
deepDive:
  factSheet      (created by / year / problem solved)
  prose          (the origin story)
  timeline       (evolution)
  realWorld      (industry usage)
  interviewQA    (3–5 questions)
  callout:fact   (a fun fact)
```

Templates aren't a code construct — they're a documented authoring convention plus a skeleton JSON file (Part 7). That's what keeps the curriculum uniform as it scales.

---

## 3. Lesson UI/UX redesign

### Principle

The **path** (Learn tab, already built) is the Duolingo map. The **lesson detail** becomes the Wikipedia article. The **quiz/challenge** is the Duolingo practice. We're redesigning the middle one: `lib/features/learning/screens/lesson_detail_screen.dart`.

### Wireframe — lesson detail (scrolling article, dark, mobile-first)

```
┌─────────────────────────────────────┐
│ ◀            ▓▓▓▓▓▓░░░░░░  47%        │ ← sticky read-progress bar
├─────────────────────────────────────┤
│  HTML · Beginner · 6 min · +50 XP    │ ← track-colored meta strip
│                                       │
│  The <h1> Heading Tag                 │ ← lesson title (hero)
│  ───────────────────                  │
│                                       │
│  ┌─ ℹ Why it exists ───────────────┐  │ ← callout(info), Core lead-in
│  │ Before headings, every page was │  │
│  │ a flat wall of text…            │  │
│  └─────────────────────────────────┘  │
│                                       │
│  An <h1> defines the most important   │ ← prose (Introduction)
│  heading on a page. Browsers render   │
│  it large and bold, but its real job  │
│  is *meaning*, not size…              │
│                                       │
│  ┌─────────────────────────────────┐  │ ← figure (rendered diagram)
│  │   h1 ▸ h2 ▸ h3  (document tree)  │  │
│  └─────────────────────────────────┘  │
│  Headings form an outline, like a     │
│  table of contents.                   │
│                                       │
│  ┌─ </> example ───────  [▶ Try] ──┐  │ ← code block, runnable
│  │ <h1>Welcome to my site</h1>     │  │
│  └─────────────────────────────────┘  │
│                                       │
│  ┌─ ⚠ Common mistake ──────────────┐  │ ← codeCompare
│  │ ❌ <h1>…</h1> <h1>…</h1>  (two)  │  │
│  │ ✅ one <h1>, then <h2> sections  │  │
│  └─────────────────────────────────┘  │
│                                       │
│  ┌─ ✓ Best practices ──────────────┐  │ ← callout(tip) + list
│  │ • Exactly one <h1> per page     │  │
│  │ • Don't skip levels (h1→h3)     │  │
│  └─────────────────────────────────┘  │
│                                       │
│  ┌═════════════════════════════════┐  │
│  ║ 📜 History & Deep Dive       ▼  ║  │ ← deepDive (COLLAPSED)
│  ╚═════════════════════════════════╝  │   tap to expand
│                                       │
├─────────────────────────────────────┤
│  [   I've read this — Take Quiz  ▶ ]  │ ← sticky bottom CTA
└─────────────────────────────────────┘
```

### Wireframe — Deep Dive expanded

```
  ┌═ 📜 History & Deep Dive ─────── ▲ ═┐
  │                                    │
  │  ┌ Fact sheet ───────────────────┐ │ ← factSheet
  │  │ Created by   Tim Berners-Lee   │ │
  │  │ First seen   1991              │ │
  │  │ Standardized HTML 2.0 (1995)   │ │
  │  │ Solved       document structure│ │
  │  └────────────────────────────────┘ │
  │                                    │
  │  In 1989 at CERN, Tim Berners-Lee  │ ← prose (origin story)
  │  needed to link physics papers…    │
  │                                    │
  │  │ 1991  HTML Tags document        │ ← timeline
  │  │ 1995  HTML 2.0 standardized     │
  │  │ 1999  HTML 4.01                 │
  │  │ 2014  HTML5 (semantic headings) │
  │                                    │
  │  Used by ▸ every website ▸ MDN ▸   │ ← realWorld chips
  │  Wikipedia ▸ GOV.UK                │
  │                                    │
  │  ▸ Q: How many h1 per page?    [+] │ ← interviewQA (collapsible)
  │  ▸ Q: h1 vs title tag?         [+] │
  │                                    │
  │  ┌ ★ Fun fact ───────────────────┐ │ ← callout(fact)
  │  │ The first web page is still    │ │
  │  │ live at info.cern.ch           │ │
  │  └────────────────────────────────┘ │
  └────────────────────────────────────┘
```

### Interaction flow

1. Path node tap → **lesson start sheet** (already built) → "Start lesson".
2. Lesson detail opens, scroll position 0, read-progress bar at 0%.
3. As the user scrolls, the **read-progress bar** fills (scroll offset ÷ content height). This is the Duolingo "you're making progress" nudge applied to reading.
4. `code` blocks marked `runnable: true` show a **▶ Try** button → opens the Playground (`AppRoutes.playground` with `PlaygroundArguments(starterCode:…)`) pre-filled with that snippet. Re-uses the playground you already have.
5. The **History & Deep Dive** card is collapsed; tapping expands it inline (animated height). Expansion state is remembered per lesson (SharedPreferences key `deepdive_expanded:<lessonId>`) so returning users keep their preference.
6. Sticky bottom CTA: **"Take the Quiz"** → existing `lesson_quiz_screen`. On pass → existing XP award overlay → lesson marked complete (all current behavior, unchanged).
7. If the lesson has a `projectPrompt`, after passing the quiz the result screen offers **"Build the mini project"** → Playground with the project starter.

### What changes vs. what doesn't

- **Changes:** `lesson_detail_screen.dart` goes from a short static layout to a block renderer. One new widget per block type (~15 small stateless widgets) + one `LessonContentView` that maps `block.type → widget`.
- **Unchanged:** the quiz screen, XP overlay, progress provider, path view, dashboard, challenges, achievements. The lesson detail is the only screen touched.

---

## 4. Visual explanation strategy (offline, no image assets)

You have no backend and ship no per-lesson images (the app uses generated icons and gradient placeholders today). Diagrams still matter for "visual explanation," so `figure` blocks support three offline `kind`s, in order of preference:

1. **`html` — rendered micro-diagram.** The `spec` is a tiny self-contained HTML/CSS snippet rendered in the same `WebView` the Playground preview already uses. Perfect for layout concepts (box model, flexbox axes, grid tracks, the DOM tree). Zero new dependencies, infinitely flexible, authored as text. **This is the workhorse.**
2. **`painter` — Flutter-drawn diagram.** For a fixed set of recurring concepts (e.g., a request/response arrow, a stack diagram), a `CustomPainter` keyed by a `spec` name. Sharper than WebView for simple vector shapes, but each needs Dart code, so reserve it for high-reuse diagrams.
3. **`ascii` — monospace box diagram.** Fallback for trivial trees/flows; pure text, trivially authored, always works.

All three are bundled in the JSON/app — fully offline. Recommendation: author 90% as `kind: html`, promote the few most-reused ones to `painter` later if rendering cost matters.

---

## 5. Data model changes (Dart) — additive, non-breaking

Your current `Lesson` (in `lib/features/learning/models/lesson.dart`) keeps **every field it has today**. We add optional fields that default to empty, so the 37 existing const lessons and all their consumers keep compiling and running.

### Existing `Lesson` (unchanged fields)
`id`, `title`, `description`, `track` (`LessonTrack`), `difficulty` (`Difficulty`), `xpReward`, `estimatedMinutes`, `starterCode`, `quizQuestions` (`List<QuizQuestion>`), plus runtime-decorated `isLocked` / `isCompleted`.

### Added fields (all optional)

```text
Lesson (extended)
├─ content        : List<LessonBlock>   // NEW — defaults []
├─ projectPrompt  : ProjectPrompt?      // NEW — defaults null
└─ schemaVersion  : int                 // NEW — defaults 1
```

If `content` is empty, the lesson renders exactly like today (just `description` + quiz). A lesson is "rich" once `content` is populated. **This is the migration switch** — flip lessons one at a time.

### New block model (sealed hierarchy, Dart 3)

```text
sealed class LessonBlock { String type }
 ├─ ProseBlock        { String md }
 ├─ HeadingBlock      { String text; int level }
 ├─ CalloutBlock      { CalloutVariant variant; String md }
 ├─ ListBlock         { bool ordered; List<String> items }
 ├─ CodeBlock         { String lang; String code; bool runnable; String? caption }
 ├─ CodeCompareBlock  { String lang; String wrong; String right; String? note }
 ├─ FigureBlock       { FigureKind kind; String spec; String? caption }
 ├─ FactSheetBlock    { List<FactRow> rows }
 ├─ TimelineBlock     { List<TimelineEntry> entries }
 ├─ RealWorldBlock    { List<RealWorldItem> items }
 ├─ QuoteBlock        { String text; String? author }
 ├─ InterviewQABlock  { List<QAPair> items }
 ├─ ChallengeRefBlock { String challengeId }
 └─ DeepDiveBlock     { String title; List<LessonBlock> children }
```

`sealed` gives exhaustive `switch` rendering — the compiler forces you to handle every block type in the renderer, so adding a type can't silently break a screen.

### Loading layer (the scalable part)

```text
CurriculumLoader  (singleton, offline)
 ├─ loadManifest()         → reads assets/curriculum/manifest.json once at startup
 │                           (lightweight: id, title, track, difficulty, xp, order, lock rule)
 ├─ loadLesson(id)         → lazily reads assets/curriculum/<track>/<id>.json
 │                           (heavy: full content blocks); caches in memory
 └─ fallbackToCatalog(id)  → if no JSON file exists yet, return the existing
                              const LessonsCatalog entry (so migration is gradual)
```

- The **path view** and **dashboard** only need manifest data (cheap) — they don't parse heavy content.
- A lesson's heavy JSON is parsed **only when opened**, then cached. Parsing 1,500 words of blocks is single-digit milliseconds.
- `LearningProgressProvider`, locking rules, and quiz wiring read from the merged `Lesson` exactly as they do now.

---

## 6. JSON schema

Two file types: one `manifest.json` (order + lightweight metadata) and one file per lesson (full content). Per-lesson files keep diffs small, make authoring parallelizable, and avoid one monster file.

### Directory layout (bundled assets, offline)

```
assets/
  curriculum/
    manifest.json
    html/
      h1_heading.json
      links.json
      …
    css/
      flexbox.json
      …
    js/
      dom.json
      …
    php/
      intro.json
      …
```

### `manifest.json`

```json
{
  "schemaVersion": 1,
  "tracks": ["html", "css", "js", "php", "capstone"],
  "lessons": [
    {
      "id": "h1_heading",
      "track": "html",
      "difficulty": "beginner",
      "title": "The <h1> Heading Tag",
      "estimatedMinutes": 6,
      "xpReward": 50,
      "order": 1,
      "file": "html/h1_heading.json"
    }
  ]
}
```

The manifest is the single source of truth for **order and locking** — your existing locking rules (sequential beginner, % gates for intermediate/advanced) read `order` + `difficulty` from here.

### Per-lesson file — full schema (annotated)

```json
{
  "schemaVersion": 1,
  "id": "h1_heading",
  "track": "html",
  "difficulty": "beginner",
  "title": "The <h1> Heading Tag",
  "estimatedMinutes": 6,
  "xpReward": 50,

  "content": [
    { "type": "callout", "variant": "info",
      "md": "Before headings, every web page was a flat wall of text with no structure. The `<h1>` was part of the fix." },

    { "type": "prose",
      "md": "An **`<h1>`** defines the most important heading on a page. Browsers render it large and bold, but its real purpose is *meaning* — it tells browsers, search engines, and screen readers what the page is about." },

    { "type": "figure", "kind": "html",
      "caption": "Headings form a document outline.",
      "spec": "<div style='font-family:sans-serif'><b>h1</b> Site title<div style='margin-left:16px'>h2 Section<div style='margin-left:16px'>h3 Sub-point</div></div></div>" },

    { "type": "code", "lang": "html", "runnable": true,
      "caption": "Your first heading",
      "code": "<h1>Welcome to my site</h1>" },

    { "type": "codeCompare", "lang": "html",
      "note": "Use one h1, then structure the rest with h2–h6.",
      "wrong": "<h1>Home</h1>\n<h1>About</h1>",
      "right": "<h1>Home</h1>\n<h2>About</h2>" },

    { "type": "callout", "variant": "tip",
      "md": "**Best practices**" },
    { "type": "list", "ordered": false,
      "items": [
        "Exactly one `<h1>` per page",
        "Don't skip levels (h1 → h3)",
        "Write the h1 for humans, not keyword stuffing"
      ] },

    { "type": "deepDive", "title": "History & Deep Dive",
      "children": [
        { "type": "factSheet", "rows": [
          { "label": "Created by",   "value": "Tim Berners-Lee" },
          { "label": "First seen",   "value": "1991" },
          { "label": "Standardized", "value": "HTML 2.0 (1995)" },
          { "label": "Solved",       "value": "Giving documents structure on the web" }
        ]},
        { "type": "prose",
          "md": "In 1989 at CERN, Tim Berners-Lee needed a way to link and structure physics papers. HTML's heading tags came straight from how academic documents were already organized…" },
        { "type": "timeline", "entries": [
          { "year": "1991", "title": "HTML Tags document", "detail": "h1–h6 appear in the first public HTML description." },
          { "year": "1995", "title": "HTML 2.0",           "detail": "Headings standardized by the IETF." },
          { "year": "1999", "title": "HTML 4.01",          "detail": "Presentation moves toward CSS." },
          { "year": "2014", "title": "HTML5",              "detail": "Sectioning elements refine heading semantics." }
        ]},
        { "type": "realWorld", "items": [
          { "name": "Wikipedia", "note": "article titles are h1" },
          { "name": "MDN",       "note": "doc structure" },
          { "name": "GOV.UK",    "note": "accessibility-first headings" }
        ]},
        { "type": "interviewQA", "items": [
          { "q": "How many <h1> should a page have?",
            "a": "Conventionally one, representing the page's main topic. HTML5 technically allows more, but one keeps the outline and SEO clean." },
          { "q": "What's the difference between <h1> and <title>?",
            "a": "<title> is the browser-tab / search-result label and lives in <head>. <h1> is the visible on-page heading. They often match but serve different surfaces." }
        ]},
        { "type": "quote",
          "text": "The first web page is still online at info.cern.ch.",
          "author": "Fun fact" }
      ]
    }
  ],

  "quiz": [
    { "question": "Which tag is the most important heading?",
      "options": ["<h1>", "<h6>", "<head>", "<heading>"],
      "correctIndex": 0 }
  ],

  "projectPrompt": {
    "title": "Build a structured article page",
    "brief": "Create a page with one h1, two h2 sections, and a short paragraph under each.",
    "starterCode": {
      "html": "<h1>My Article</h1>\n<h2>Intro</h2>\n<p>…</p>",
      "css": "body{font-family:sans-serif;max-width:640px;margin:40px auto}",
      "js": ""
    }
  }
}
```

### Schema rules (enforced by the validator, Part 7)

- `schemaVersion`, `id`, `track`, `difficulty`, `title`, `content` are required; `quiz` required (≥1 question); `projectPrompt` optional.
- Every block must have a known `type`; unknown types fail validation (and at runtime render nothing rather than crash).
- `code.lang` ∈ {`html`,`css`,`js`,`php`,`bash`,`text`}.
- `callout.variant` ∈ {`info`,`tip`,`warning`,`fact`}.
- `figure.kind` ∈ {`html`,`painter`,`ascii`}.
- `deepDive.children` may contain any block **except another `deepDive`** (no nested collapsibles).
- Recommended word budget per lesson: **800–1,500 words** across all `prose`/`callout`/`md` fields — the validator warns outside this range so the curriculum stays consistent.

---

## 7. Scalable curriculum system

The schema is only half of "scalable." The other half is the authoring + safety system so you (or future contributors / Fiverr collaborators) can add lessons without breaking anything.

### a) Lesson skeleton

Ship `assets/curriculum/_TEMPLATE.json` — a complete lesson with every block type stubbed and inline comments (as `"_comment"` keys) explaining each. Authoring a new lesson = copy the template, fill it in, add one line to `manifest.json`.

### b) Content validator (extend your existing tooling)

You already have `tool/validate_quizzes.dart`. Generalize it into `tool/validate_curriculum.dart` that, run locally before release:

- parses `manifest.json` + every lesson file,
- checks required fields, known block types, enum values, the no-nested-deepDive rule,
- verifies every `manifest` lesson has a file and vice-versa,
- verifies `challengeRef.challengeId` exists in the challenges catalog,
- verifies each lesson's locking `order` is unique within its track,
- warns on word count outside 800–1,500,
- prints a per-track completion report (how many lessons are "rich" vs still falling back to the const catalog).

This is your CI gate. A malformed lesson never ships.

### c) Schema versioning

Every file carries `schemaVersion`. The loader reads it and can run small migrations (e.g., if v2 renames a field). Start at `1`. This is what lets the content format evolve over years without re-authoring everything.

### d) The PHP track

Your app advertises PHP, and `assets/lessons/php.json` exists in the legacy system, but the active `learning` catalog has no PHP track. To bring PHP into the rich system:

- add `php` to the `LessonTrack` enum (additive, non-breaking) with its own accent color and icon,
- author PHP lessons as `assets/curriculum/php/*.json` using the same schema,
- the legacy `php.json` becomes *source material* for authoring, then is retired.

This also resolves the **two-systems problem** noted during the path-view work: the legacy `lib/features/learn/` JSON system and the active `lib/features/learning/` system. The rich curriculum consolidates on `learning/`. The legacy `assets/lessons/*.json` files are mined for content, then deprecated — one canonical learning system going forward.

### e) Authoring guidelines (the museum voice)

Documented tone rules so 37+ lessons feel like one author:

- **Lead with plain language**, then deepen. First sentence of every Introduction must be understandable by a total beginner.
- **History is narrative, not a date dump** — tell the story (the person, the problem, the "aha"), then let the `timeline` carry the dates.
- **Every concept gets one concrete real-world anchor** (a named site or company) — abstract claims ("used everywhere") are banned in favor of specifics.
- **Examples must be runnable** where the topic allows — prefer `runnable: true` so learning stays hands-on.

---

## 8. Offline-first confirmation

Nothing here adds a network dependency:

- All curriculum ships as **bundled assets** inside the APK (`assets/curriculum/**`), declared in `pubspec.yaml`.
- The **manifest** loads once at startup (tiny). **Lesson content** loads lazily from the local asset bundle when a lesson opens, then is cached in memory for the session.
- **Progress, XP, streak, completion, deep-dive expansion state** all stay in SharedPreferences/Hive exactly as today.
- Diagrams (`figure`) render from inline `spec` strings — no remote images.
- The only growth is APK size: ~37 lessons × ~1.5 KB JSON ≈ trivial; even 200 rich lessons is well under a megabyte of text.

---

## 9. Implementation roadmap

Sequenced so each phase ships independently and nothing breaks. **Engine before content.**

**Phase 1 — Model + loader (no UI change yet).**
Extend `Lesson` with optional `content` / `projectPrompt` / `schemaVersion`. Add the `LessonBlock` sealed hierarchy. Build `CurriculumLoader` with const-catalog fallback. Author ONE lesson file (`html/h1_heading.json`) as the proof. Existing app behaves identically because no screen reads `content` yet.

**Phase 2 — Block renderer + lesson detail redesign.**
Build the ~15 block widgets + `LessonContentView` + the read-progress bar + the collapsible Deep Dive + sticky quiz CTA. Wire `lesson_detail_screen.dart` to render `content` when present, else fall back to today's simple layout. Now the H1 lesson is fully rich; the other 36 still render the old way. **Ship this** — it's visible value with one flagship lesson.

**Phase 3 — `figure` rendering + "Try in Playground".**
Wire `figure: html` into the existing WebView, add the ▶ Try buttons that open the Playground pre-filled. Add `projectPrompt` → Playground handoff.

**Phase 4 — Validator + template + manifest.**
Ship `_TEMPLATE.json` and `tool/validate_curriculum.dart`. Move locking/order to read from `manifest.json`. This unlocks safe parallel authoring.

**Phase 5 — Content authoring (the long pole — see scope note).**
Enrich lessons track by track, highest-traffic first: all 12 HTML → all 12 CSS → all 12 JS → new PHP track. Each lesson is just a new JSON file; no code changes. The const catalog shrinks as each lesson migrates.

**Phase 6 — Deep-dive polish + interview mode.**
Per-lesson deep-dive expansion memory, an optional "Interview prep" filter that surfaces all `interviewQA` across completed lessons, and the ad-gated reveal hooks if/when you add them.

---

## 10. Honest scope note

The **engine** (Phases 1–4) is a focused, finite build — a model extension, a loader, ~15 small widgets, and a validator. That's the part I can spec and build cleanly.

The **content** (Phase 5) is the real mountain. "800–1,500 words × 15 sections" is **30,000–55,000 words of original, accurate, well-researched technical writing** across 37+ lessons — including correct history (real people, real dates), correct SEO/accessibility guidance, and genuine interview questions. That is a writing project measured in weeks, not a code generation task, and accuracy matters (wrong history or wrong best-practice advice in a teaching app is worse than none).

Recommendation: **build the engine first and make ONE lesson (H1) genuinely excellent end-to-end** as the template and quality bar. Then author the rest incrementally — ideally a few lessons at a time so each can be fact-checked — rather than mass-generating 37 lessons of unverified prose. The architecture above is explicitly designed so content can land lesson-by-lesson forever without ever touching the engine again.

---

*End of design. No code has been written yet — this document defines the content architecture, block library, lesson UI/UX, data model changes, JSON schema, curriculum tooling, offline strategy, and phased roadmap. Implementation begins at Phase 1 on your go-ahead.*
