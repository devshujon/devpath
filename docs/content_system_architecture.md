# DevPath — Rich Curriculum Content System

**Status:** Design (no implementation)
**Builds on:** `docs/lesson_system_architecture.md` (the block model, loader, and migration switch defined there are the foundation; this document extends them — it does not replace them).
**Scope:** 20-section lesson template, the 9 special content blocks, three new screens (Coding Timeline, Technology Museum, Knowledge Cards), gamification integration, JSON schema additions, asset organization, content production workflow, migration, and scaling to 500+ lessons.
**Constraints:** offline-first, no backend, Provider + SharedPreferences/Hive, additive/non-breaking to shipped systems.

---

## 1. What this document adds to the existing architecture

The prior doc established the core idea: **a lesson is an ordered list of typed blocks**, rich content lives in **per-lesson JSON assets** loaded lazily with a **fallback to the existing const catalog**, and the `Lesson` model is **extended, never replaced**. All of that stands.

This document does four new things:

1. Expands the lesson template from 15 to your **20 sections**, adding 4 new block types.
2. Formalizes your **9 named special blocks** against the block vocabulary.
3. Designs **three new global screens** (Timeline, Museum, Knowledge Cards) that are *not* per-lesson — they're app-wide discovery surfaces.
4. Extends the **gamification system** (XP + badges) to reward exploration, with explicit anti-farming rules.

---

## 2. The 20-section lesson template → block mapping

Every section you listed maps to existing or new blocks, sorted into the three visibility tiers from the prior doc (Core / Deep Dive / Practice).

| # | Section | Tier | Block(s) |
|---|---|---|---|
| 1 | Quick Summary | Core (top) | `summary` **(new)** — a 2–3 sentence TL;DR card, always first |
| 2 | Real World Example | Core | `prose` + `realWorld` ("you've seen this on…") |
| 3 | Why This Exists | Core (lead-in) | `callout:info` |
| 4 | History & Origins | Deep Dive | `prose` + `timeline` |
| 5 | Creator Story | Deep Dive | `creator` **(new)** — name, role, era, the human story |
| 6 | Evolution Timeline | Deep Dive | `timeline` |
| 7 | Technical Explanation | Core | `prose` |
| 8 | Syntax Breakdown | Core | `syntaxBreakdown` **(new)** — code with per-part labeled annotations |
| 9 | Visual Explanation | Core | `figure` (offline diagram) |
| 10 | Industry Usage | Deep Dive | `prose` + `realWorld` |
| 11 | Famous Companies Using It | Deep Dive | `realWorld` (company variant) |
| 12 | Common Mistakes | Core | `callout:warning` + `codeCompare` |
| 13 | Best Practices | Core | `callout:tip` + `list` |
| 14 | Interview Questions | Deep Dive | `interviewQA` |
| 15 | Did You Know? | Core/Deep Dive | `callout:fact` |
| 16 | Fun Facts | Deep Dive | `quote` / `callout:fact` |
| 17 | Mini Challenge | Practice | `challengeRef` |
| 18 | Practice Exercise | Practice | `exercise` **(new)** — guided task, lighter than a project |
| 19 | Mini Project | Practice | `projectPrompt` |
| 20 | Quiz | Practice | `quiz[]` array (reuses existing quiz system) |

**Four new block types** added to the vocabulary from the prior doc (which had 15): `summary`, `creator`, `syntaxBreakdown`, `exercise`. Everything else reuses blocks already designed. Total vocabulary: **19 block types.**

### The 4 new blocks — JSON shape

```json
{ "type": "summary",
  "md": "The `<h1>` is a page's single most important heading. It signals *meaning*, not just big text — and search engines and screen readers depend on it." }

{ "type": "creator",
  "name": "Tim Berners-Lee",
  "role": "Inventor of the World Wide Web",
  "era": "1989–present",
  "place": "CERN, Switzerland",
  "story": "A British scientist who wanted physicists to share documents across incompatible computers. His 1989 proposal was famously marked 'vague but exciting' by his boss." }

{ "type": "syntaxBreakdown",
  "lang": "html",
  "code": "<h1 class=\"title\">Hello</h1>",
  "parts": [
    { "fragment": "<h1>",        "label": "Opening tag — starts the heading" },
    { "fragment": "class=\"title\"", "label": "Attribute — hooks for CSS/JS" },
    { "fragment": "Hello",        "label": "Content — what users read" },
    { "fragment": "</h1>",       "label": "Closing tag — ends the heading" }
  ] }

{ "type": "exercise",
  "prompt": "Add a single h1 and two h2 sections to this page.",
  "starterCode": { "html": "<!-- your code -->", "css": "", "js": "" },
  "checks": ["one <h1>", "at least two <h2>"] }
```

The `exercise` block's `checks` reuse the existing `ChallengeValidator` rule format — no new validation engine.

---

## 3. The 9 special content blocks, reconciled

Your named blocks map cleanly; only one is genuinely new:

| Your block | Implemented as | New? |
|---|---|---|
| History Block | `deepDive` container holding `prose` + `timeline` (an authoring template) | reuses |
| Timeline Block | `timeline` | exists |
| Creator Block | `creator` | **new** |
| Company Usage Block | `realWorld` with `variant: "company"` | reuses |
| Interview Block | `interviewQA` | exists |
| Fun Fact Block | `callout:fact` or `quote` | exists |
| Mistake Block | `codeCompare` + `callout:warning` | exists |
| Best Practice Block | `callout:tip` + `list` | exists |
| Challenge Block | `challengeRef` | exists |

So adopting your full spec costs **one new block** (`creator`) beyond the four above, because the others are presentation templates over blocks you already have.

---

## 4. New screen — "The History of the Web" (Coding Timeline)

A single app-wide timeline, not per-lesson. The museum's narrative spine.

### Data: `assets/curriculum/web_history.json`

```json
{
  "schemaVersion": 1,
  "eras": [
    { "id": "arpanet_1969", "year": "1969", "title": "ARPANET",
      "summary": "The first packet-switched network — the internet's ancestor.",
      "detail": "Funded by the US DoD, ARPANET connected four universities…",
      "track": null, "relatedLessons": [] },
    { "id": "www_1989", "year": "1989", "title": "The World Wide Web",
      "summary": "Tim Berners-Lee proposes a system of linked documents.",
      "detail": "…", "track": "html", "relatedLessons": ["h1_heading"] },
    { "id": "html_1991", "year": "1991", "title": "HTML",       "track": "html", "...": "" },
    { "id": "js_1995",   "year": "1995", "title": "JavaScript", "track": "js",   "...": "" },
    { "id": "php_1995",  "year": "1995", "title": "PHP",        "track": "php",  "...": "" },
    { "id": "css_1996",  "year": "1996", "title": "CSS",        "track": "css",  "...": "" },
    { "id": "fb_2004",   "year": "2004", "title": "Facebook",   "...": "" },
    { "id": "yt_2005",   "year": "2005", "title": "YouTube",    "...": "" },
    { "id": "iphone_2007","year": "2007","title": "iPhone",     "...": "" },
    { "id": "rwd_2010",  "year": "2010", "title": "Responsive Design", "track": "css", "...": "" },
    { "id": "modernjs_2014","year": "2014","title": "Modern JS (ES6)", "track": "js", "...": "" },
    { "id": "jamstack_2020","year": "2020","title": "JAMStack", "...": "" },
    { "id": "aiweb_2025","year": "2025", "title": "AI-powered Web", "...": "" }
  ]
}
```

### UX

```
┌─────────────────────────────────────┐
│ ◀   The History of the Web    ▓▓░ 8/13│ ← progress = eras opened
├─────────────────────────────────────┤
│   ●  1969 — ARPANET                   │
│   │     The internet's ancestor.   ▸  │ ← tap → detail sheet
│   ●  1989 — World Wide Web            │
│   │     Linked documents proposed. ▸  │
│   ●  1991 — HTML            [HTML] ▸   │ ← track chip links to lessons
│   │                                   │
│   ◌  2025 — AI-powered Web   (locked?)│
└─────────────────────────────────────┘
```

Tapping an era opens a detail sheet (summary → detail prose → "Related lessons" links into the curriculum). Entries are all unlocked (it's reference, not gated). **Gamification:** opening an era marks it discovered; opening all 13 awards the **Timeline Master** badge + one-time XP.

### Placement in app IA

Add a **"Discover" tab** (5th bottom-nav item) hosting Timeline + Museum + Knowledge Cards, OR a "Discover" hub card on the dashboard. Recommendation: a Discover tab — five tabs is the practical ceiling but acceptable, and it gives these surfaces a permanent home rather than burying them.

---

## 5. New screen — Web Technology Museum

A gallery of "exhibits," one per technology.

### Data: `assets/curriculum/museum.json`

```json
{
  "schemaVersion": 1,
  "exhibits": [
    {
      "id": "javascript",
      "name": "JavaScript",
      "category": "language",
      "creator": "Brendan Eich",
      "year": "1995",
      "originalPurpose": "Add small interactive scripts to Netscape Navigator.",
      "evolution": [
        { "year": "1995", "note": "Written in 10 days as 'Mocha'." },
        { "year": "1997", "note": "Standardized as ECMAScript." },
        { "year": "2015", "note": "ES6 modernizes the language." },
        { "year": "2025", "note": "Runs servers, apps, AI tooling." }
      ],
      "currentStatus": "thriving",
      "funFact": "It was renamed 'JavaScript' as a marketing tie-in to Java, despite being unrelated.",
      "relatedLessons": ["dom", "js_functions"]
    }
  ]
}
```

`category` ∈ {`language`,`protocol`,`tool`,`framework`,`standard`}. `currentStatus` ∈ {`thriving`,`mature`,`legacy`,`deprecated`} — rendered as a colored status badge (a museum "condition" label).

### UX

```
┌─────────────────────────────────────┐
│ ◀   Web Technology Museum     6/15 🏛 │
├─────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐          │
│  │ JS  1995 │  │ CSS 1996 │          │ ← exhibit cards (grid)
│  │ thriving │  │ thriving │          │
│  └──────────┘  └──────────┘          │
│  ┌──────────┐  ┌──────────┐          │
│  │ PHP 1995 │  │ HTML 1991│          │
│  │ mature   │  │ thriving │          │
│  └──────────┘  └──────────┘          │
└─────────────────────────────────────┘
        ↓ tap an exhibit
┌─────────────────────────────────────┐
│   JavaScript            [thriving]    │
│   Created by Brendan Eich · 1995      │ ← creator block
│   Purpose: interactive scripts…       │
│   │ 1995  Written in 10 days          │ ← timeline block
│   │ 2015  ES6                         │
│   ★ Renamed for marketing…            │ ← fun fact
│   Learn more ▸ DOM ▸ Functions        │ ← related lessons
└─────────────────────────────────────┘
```

**Gamification:** first visit to an exhibit awards one-time XP; visiting all exhibits awards **Web Archaeologist**.

---

## 6. New feature — Knowledge Cards

Bite-size "Did you know?" facts surfaced throughout the app.

### Data: `assets/curriculum/knowledge_cards.json`

```json
{
  "schemaVersion": 1,
  "cards": [
    { "id": "js_10_days", "category": "javascript",
      "fact": "JavaScript was created in just 10 days in 1995.",
      "relatedLessonId": "dom" },
    { "id": "css_unmanageable", "category": "css",
      "fact": "CSS was invented because styling inside HTML had become unmanageable.",
      "relatedLessonId": "css_selectors" },
    { "id": "wp_40pct", "category": "php",
      "fact": "WordPress powers over 40% of all websites — and it's built in PHP.",
      "relatedLessonId": null }
  ]
}
```

### Surfacing strategy

- **Dashboard:** a "Did you know?" card showing the **daily card** (deterministic by date-hash — the exact pattern your daily-challenge system already uses, so the whole app shows the same card on a given day).
- **Between lessons:** after completing a lesson, occasionally surface a related card (matched by `relatedLessonId` or `category`).
- **Discover tab:** a "Discoveries" collection showing all cards the user has revealed, with locked silhouettes for undiscovered ones (collectible feel).

**Gamification:** each newly revealed card is a one-time discovery (+XP); milestones award the **Knowledge Seeker** badge.

---

## 7. Gamification integration

### XP for exploration (with guardrails)

The educational-psychology caveat: **reward discovery modestly and once.** If reading a history section pays the same as passing a quiz, or pays repeatedly, XP stops meaning "I can do this" and starts meaning "I tapped things." Rules:

| Action | XP | Frequency |
|---|---|---|
| Read a lesson's Deep Dive (expand + dwell) | +10 | **once per lesson** (keyed by lesson id) |
| Open a timeline era | +3 | once per era |
| Complete the timeline (all eras) | +50 | once |
| Visit a museum exhibit | +5 | once per exhibit |
| Visit all exhibits | +75 | once |
| Reveal a knowledge card | +5 | once per card |

**Anti-farming:** every award is keyed by a stable id in a `discovered` set (SharedPreferences). Re-opening never re-awards. This is the same one-time-award discipline that keeps quiz XP honest, applied to exploration. Exploration XP should also stay *small relative to* doing-XP (a lesson quiz is +50; reading its history is +10) so progression still reflects skill, not browsing.

### Five new badges

Implemented as new entries in `achievements_catalog.dart` with new `AchievementCondition` enum values (reusing the existing `RewardsProvider` machinery — no new system):

| Badge | Condition (`AchievementCondition`) | Unlock |
|---|---|---|
| Historian | `historySectionsRead` | Read 10 lesson Deep Dives |
| Researcher | `deepDivesCompletedInTrack` | Read every Deep Dive in one track |
| Knowledge Seeker | `knowledgeCardsDiscovered` | Reveal 25 knowledge cards |
| Web Archaeologist | `museumExhibitsVisited` | Visit every museum exhibit |
| Timeline Master | `timelineCompleted` | Open every era in the timeline |

These extend the existing 20-achievement catalog to 25, using the same unlock overlay, pending-rewards card, and persistence already shipped.

---

## 8. JSON schema additions (summary)

The lesson per-file schema from the prior doc gains the 4 new block types (`summary`, `creator`, `syntaxBreakdown`, `exercise`) and bumps `schemaVersion` to `2`. Three new app-wide content files are added:

```
web_history.json        eras[]      → Coding Timeline
museum.json             exhibits[]  → Technology Museum
knowledge_cards.json    cards[]     → Knowledge Cards
```

All four file types carry `schemaVersion`, are validated by the curriculum validator (Part 10), and are bundled offline.

---

## 9. Offline asset organization (full tree)

```
assets/
  curriculum/
    manifest.json            ← lesson order + lightweight metadata + locking
    _TEMPLATE.json           ← lesson skeleton authors copy
    web_history.json         ← Coding Timeline
    museum.json              ← Technology Museum
    knowledge_cards.json     ← Knowledge Cards
    html/      h1_heading.json, links.json, …
    css/       flexbox.json, …
    js/        dom.json, …
    php/       intro.json, …          ← NEW track (LessonTrack.php, additive)
    capstone/  …
```

Everything ships inside the APK. Manifest + the three discovery files load once at startup (all small). Heavy per-lesson content loads lazily on open and is cached. No network anywhere.

---

## 10. Content production workflow

The engine is finite; **the content is the real project.** A disciplined pipeline keeps quality and accuracy consistent across hundreds of lessons:

1. **Brief** — one-paragraph scope per lesson (concept, prerequisite, the one real-world anchor).
2. **Draft** — write Core prose first (beginner-readable), then Deep Dive narrative.
3. **Fact-check** — verify every name, date, and claim against primary/reputable sources. *History accuracy is non-negotiable in a teaching app — a wrong date or misattributed creator is worse than omitting it.*
4. **Author JSON** — copy `_TEMPLATE.json`, fill blocks, add the manifest entry.
5. **Validate** — run `tool/validate_curriculum.dart` (extended to check the new block types, the three discovery files, `relatedLessons` references, and word budget 800–1,500).
6. **Review** — self/peer read for tone and the "museum voice" guidelines (lead plain, history as narrative, one concrete anchor, runnable examples).
7. **Ship** — the lesson goes live; the const-catalog fallback for that id is removed.

**Throughput reality:** a well-researched, fact-checked rich lesson is a few hours of work. 500 lessons is a content-team-year, not a code task. Recommendation: build the engine, perfect **one** lesson (H1) as the gold standard, then author in small fact-checkable batches per track — never mass-generate unverified prose into a teaching product.

---

## 11. Migration strategy

Unchanged in spirit from the prior doc, now covering the new content:

1. **Engine + loader** ship first; all 37 existing lessons keep rendering via the const fallback.
2. **Per lesson:** author its JSON → it becomes "rich" → remove its const entry. One at a time; the app is always shippable.
3. **Legacy `assets/lessons/{html,css,javascript,php}.json`** become *source material* for authoring, then are retired. This collapses the two parallel learning systems (`learn/` and `learning/`) onto one canonical curriculum.
4. **New screens** (Timeline/Museum/Cards) ship independently of lesson migration — they read their own files and don't depend on any lesson being rich yet.

---

## 12. Scaling to 500+ lessons

The architecture is already shaped for this:

- **Per-lesson files** mean 500 lessons = 500 small files, not one giant file. Diffs stay tiny; authoring parallelizes.
- **Lazy load + memory cache + eviction:** only opened lessons are parsed and held; cache evicts least-recently-used so memory stays flat regardless of catalog size.
- **Manifest at scale:** 500 lightweight entries ≈ 50–80 KB JSON, parsed once at startup — trivial. If it ever grows uncomfortable, shard the manifest per track (`manifest/html.json`, …) and load a track's manifest when its path is opened.
- **Path rendering:** the Learn path already sections by difficulty and filters by track, so 500 nodes remain navigable (track filter + difficulty sections + lazy list).
- **Validator as the gate:** with hundreds of contributors-worth of content, the validator is what guarantees no malformed lesson ever ships.
- **Schema versioning** lets the format evolve over years without re-authoring everything.

---

*End of content-system design. No code written. Implementation order: extend the block vocabulary (4 new types) and `Lesson` schema → build the three discovery screens against their JSON → wire the exploration XP + 5 badges into the existing RewardsProvider → extend the validator. The engine work is finite; the lesson writing is the long, ongoing effort and should be done in verified batches.*
