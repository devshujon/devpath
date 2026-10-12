# DevPath — Advanced Quiz & Rewarded Ad System

**Status:** Design (no implementation)
**Reuses (do not rebuild):** the existing `QuizQuestion` model (becomes one quiz type), `ChallengeValidator` (the regex engine already shipped — powers code-based question types), the `google_mobile_ads` dependency (already in `pubspec.yaml`), `RewardsProvider` + `AchievementCondition` (badges), `LearningProgressProvider` (XP/level), and the existing certificate system (boss quizzes become a new unlock requirement).
**Constraints:** offline-first (quizzes work with no network; ads degrade gracefully), no backend, Provider + SharedPreferences/Hive, additive/non-breaking.

---

## 1. Reuse map — what's new vs. what already exists

| Capability | Status |
|---|---|
| Multiple-choice question | **Exists** (`QuizQuestion`) → becomes `McqItem` |
| Code validation (HTML/CSS/JS) | **Exists** (`ChallengeValidator`) → powers complete-code, find-bug, coding exam |
| Rewarded ads | **Dependency exists** (`google_mobile_ads`) → wire `RewardedAd` lifecycle |
| Badges/achievements | **Exists** (`RewardsProvider`) → add quiz-mastery badges |
| XP / level | **Exists** (`LearningProgressProvider`) |
| Certificates | **Exists** → add boss-quiz pass requirement |
| Polymorphic question model | **New** |
| Gem currency + economy | **New** |
| Ad/XP gating + daily limits | **New** |
| Timers, streak multipliers | **New** |
| Boss quiz, interview mode, coding exam, analytics | **New (mostly orchestration over the above)** |

The headline: you are not building 12 engines. You're building **one polymorphic question model + 4 validation strategies + an economy layer**, reusing the validator and ad SDK you already have.

---

## 2. The 12 quiz types — grouped by validation strategy

| Strategy | Types | How it validates |
|---|---|---|
| **Selection** | 1 Multiple Choice · 2 Multiple Select · 6 Code Output Prediction · 10 CSS Visual Prediction · 11 JS Logic Challenge · 12 Project Scenario | Compare chosen option(s) to correct set. (Output/CSS/JS-logic are selection questions whose *options* are code results — CSS-visual renders each option in the preview WebView.) |
| **Sequence** | 4 Drag & Drop Order · 9 Arrange HTML Structure | Compare user's ordered list to the correct order. |
| **Pairing** | 5 Match The Pairs | Compare user's left→right pairings to the correct map. |
| **Code (validator)** | 3 Fill In The Blank · 8 Complete The Code · 7 Find The Bug | Normalize/assemble the user's text and run it through `ChallengeValidator` (or normalized-string match for simple blanks). |

So: **4 validators** (`selection`, `sequence`, `pairing`, `code`) cover all 12. New presentation widgets per type, shared validation underneath.

---

## 3. Quiz data model (polymorphic, sealed)

```text
sealed class QuizItem {
  String id
  String prompt                 // the question text / instruction
  Difficulty difficulty         // beginner | intermediate | advanced | expert
  int? timerSeconds             // null = untimed; else 30/60/120
  Explanation explanation       // ALWAYS present (see §4)
  String? relatedLessonId       // "related concept" deep-link
}

 ├─ McqItem        { List<String> options; int correctIndex }                 // existing QuizQuestion
 ├─ MultiSelectItem{ List<String> options; Set<int> correctIndices }
 ├─ OutputPredItem { String code; String lang; List<String> options; int correctIndex }
 ├─ CssVisualItem  { String css; List<String> optionHtml; int correctIndex }  // options rendered in WebView
 ├─ OrderItem      { List<String> shuffled; List<int> correctOrder }
 ├─ MatchItem      { List<Pair> left; List<Pair> right; Map<int,int> correct }
 ├─ FillBlankItem  { String template; List<Blank> blanks }                    // blanks accept variants
 ├─ CompleteCodeItem { String stub; String lang; List<ValidatorRule> checks } // → ChallengeValidator
 ├─ FindBugItem    { String buggyCode; String lang; List<ValidatorRule> fixChecks }
 └─ ScenarioItem   { String scenario; List<String> options; int correctIndex } // situational MCQ
```

```text
class Explanation {
  String whyCorrect
  List<String> whyOthersWrong   // parallel to options where applicable
  String? bestPractice
  String? relatedConceptLessonId
}
```

Each subtype implements `bool check(answer)` or delegates to `ChallengeValidator`. The renderer maps `QuizItem` subtype → widget via an exhaustive `switch` (sealed → compiler-enforced coverage). Quiz banks are authored in JSON alongside lessons (per-lesson `quiz[]`) and in dedicated boss/interview files (§8–9).

---

## 4. Difficulty + explanations (free, always)

**Four difficulty levels** (`beginner`/`intermediate`/`advanced`/`expert`) tag each item and drive: default timer, XP weight, and which items appear in interview/boss pools.

**Explanations are shown after every answer, for free, always** — this is the core learning moment and is never gated:

```
┌─ Result ────────────────────────────┐
│  ✗ Not quite                         │
│                                      │
│  ✓ Why <h1> is correct:              │
│    It's the page's primary heading…  │
│                                      │
│  ✗ Why the others are wrong:         │
│    <head> is metadata, not visible…  │
│    <heading> isn't a real tag…       │
│                                      │
│  💡 Best practice: one <h1> per page │
│  🔗 Related: "Semantic HTML" lesson  │
│                                      │
│  [        Continue        ]          │
└──────────────────────────────────────┘
```

This is the single most important deviation from the original spec, and it's deliberate: gating *feedback* behind ads monetizes the exact instant learning happens and drives churn. Ads/currency gate *help that short-circuits effort* (§5), not the explanation.

---

## 5. Rewarded ad + dual-currency economy

### 5.1 Two currencies (recommended over "spend XP")

| Currency | Earned from | Spent on | Drives |
|---|---|---|---|
| **XP** | lessons, quizzes, streaks, discovery | **never spent** | level, badges, certificates, leaderboard |
| **Gems** | lesson completion (+5), daily streak (+10), boss-quiz pass (+50), rewarded ads (+10/ad, capped), milestones | hints, reveals, solutions, second attempts | the help economy |

XP is your progression signal — spending it would de-level users for asking for help and corrupt the metric. Gems are a separate spendable pool. All your original "spend XP" prices below are expressed in Gems.

### 5.2 What can be unlocked, and the price

Two columns: your original spec, and the recommended refinement (which I'd ship).

| Help | Your spec | Recommended | Rationale |
|---|---|---|---|
| **Explanation** (after answering) | — | **Free, always** | It's the learning |
| **Hint** (before answering) | 1 ad OR XP | 1 ad **OR** 10 gems | Preserves struggle; cheap |
| **Reveal answer** (give up, unsolved) | 3 ads OR 50 XP | 1 ad **OR** 30 gems | 3 sequential ads = long loads + data cost for tier-2 users |
| **Full solution / walkthrough** | 5 ads OR 100 XP | 1 ad **OR** 60 gems | Same; 5 ads is punishing |
| **Second attempt** (boss/exam) | — | 1 ad **OR** 40 gems | Optional retry |
| **Bonus XP** (post-quiz) | — | 1 ad → +25% session XP | Pure upside, opt-in |

The single-ad-per-reward model still monetizes but respects load times, data cost, and AdMob account health (excessive rewarded impressions per user can hurt standing). Keep the multi-ad option behind a config flag if you want to A/B it.

### 5.3 Rewarded ad flow (AdMob `RewardedAd`)

```
quiz starts → preload RewardedAd in background
user taps "Hint · watch ad"
   → opt-in confirm sheet ("Watch a short ad for a hint?")
   → show RewardedAd
        ├─ onUserEarnedReward → grant hint, consume daily allowance
        ├─ ad failed / no fill → offer gem path instead
        └─ user closed early → no reward, no consume
   → preload the next ad
```

**Offline-first rule:** ads need network. When offline (or no fill), the **gem path always remains**, and the **free post-answer explanation is never blocked**. Learning never hard-depends on an ad loading. This is non-negotiable given the app's offline promise and audience.

### 5.4 AdMob policy + compliance notes

- Rewarded ads **are** allowed to be incentivized — that's their designed use. Must be **user-initiated**, reward **only on completion**, never auto-play, never reward clicks.
- **Audience risk:** a "learn to code for beginners" app may attract under-13 users. Review AdMob's families/child-directed-treatment requirements; set content rating and `tagForChildDirectedTreatment` appropriately. This is a real compliance item, not optional.
- One ad unit per reward type or a shared rewarded unit; configure in AdMob console, keep test unit IDs in debug builds.

---

## 6. Anti-abuse (offline, honest about limits)

Daily limits, tracked locally via a date-keyed counter (the same date-hash pattern your daily-challenge code already uses; resets when the local date changes):

| Action | Your spec | Recommended cap |
|---|---|---|
| Hints | 20/day | 20/day |
| Answer reveals | 10/day | 10/day |
| Full solutions | 5/day | 5/day |
| **Gems earned from ads** | — | **e.g. 100/day** (protects the economy + AdMob health) |

**Honest limitation:** with no backend, limits live in local storage and a determined user can reset them (clock change, reinstall). For a free offline app that's an acceptable risk — note it, don't over-engineer server validation you can't host.

---

## 7. Timers + streak multipliers

- **Per-question timer** (optional, by type/difficulty: 30/60/120 s) shown as a ring. On timeout → counts as an attempt with no answer → show the free explanation. Timers off by default for beginner lessons; on for boss/interview/expert.
- **Streak multiplier** on XP earned within a session: 3 correct → 1.2×, 5 → 1.5×, 10 → 2×. A wrong answer or timeout resets the streak. Multiplier is displayed live ("🔥 5 in a row · 1.5×"). Integrates with `LearningProgressProvider.addXP` at award time.

---

## 8. Boss quizzes

- **One per module**, 20–50 mixed-type items, drawn from that module's lessons (weighted toward higher difficulty).
- **Pass = 80%+.** Authored in `assets/quizzes/boss/<track>.json`.
- **New certificate requirement:** the track certificate now unlocks on *all track lessons complete* **AND** *boss quiz ≥80%*. This connects the quiz system to the existing certificate feature (today certs unlock on lesson % alone). The Graduate certificate additionally requires all boss quizzes passed.
- Failing → retry allowed (learning first); optionally rate-limit retries/day or offer a gem/ad-gated immediate second attempt (§5.2).

---

## 9. Interview mode

- **Randomized** pool across the user's completed topics, timed, **no hints** (simulates a real interview).
- Produces a **score report**: accuracy %, average time/question, weak topics, a band ("Junior-ready / needs practice").
- Fully offline (pool is bundled). Ties into a "Researcher"-style badge and feeds the analytics in §11.
- Authored in `assets/quizzes/interview/<track>.json`.

---

## 10. Coding exam mode

- User **writes** HTML/CSS/JS in the existing editor; **`ChallengeValidator` auto-scores** against expected rules (the engine you already shipped), with **partial credit per rule** (e.g., 4/5 rules = 80%).
- Reuses the playground editor + preview + validator — minimal new surface. This is the bridge between "quiz" and your existing challenge system.

---

## 11. Analytics (on-device only)

No backend, so analytics are local aggregates (bounded storage — store rolling aggregates, not every attempt):

```text
QuizStats (per topic/track, in Hive/SharedPreferences)
├─ attempts, correct           → accuracy %
├─ totalTimeMs / attempts      → average time
├─ lastScores[] (rolling, cap) → average score, trend
└─ derived: weakTopics (lowest accuracy), strongTopics (highest)
```

A **Stats screen** surfaces accuracy %, weak vs. strong topics, average score, average time, and a "topics to review" list. Weak topics can resurface in practice (spaced-repetition-lite). All computed and stored locally.

---

## 12. XP economy ledger (how it all balances)

```
EARN  XP  : lesson +50 · quiz item +5..+20 (by difficulty × streak mult) · boss pass +200 · discovery (small, one-time)
EARN  Gems: lesson +5 · daily streak +10 · boss pass +50 · rewarded ad +10 (≤100/day) · milestone bonuses
SPEND Gems: hint 10 · reveal 30 · solution 60 · second attempt 40
NEVER spend XP.
```

Tuning principle: a diligent learner who never uses ads should still earn enough Gems through normal play to afford occasional help — the economy assists, it doesn't paywall. Ads are an *accelerator* for impatient users, not the only path.

---

## 13. UI/UX

```
┌─────────────────────────────────────┐
│ ◀  Quiz · HTML        💎 120   ⏱ 0:42 │ ← gem balance + timer ring
│     ▓▓▓▓▓░░░░  Q4/8     🔥 3 · 1.2×    │ ← progress + streak multiplier
├─────────────────────────────────────┤
│  Which tag is the largest heading?    │
│                                       │
│  ( ) <h1>        ( ) <h6>             │ ← per-type widget (here: MCQ)
│  ( ) <head>      ( ) <heading>        │
│                                       │
│  [ 💡 Hint · 1 ad or 10💎 ]           │ ← help bar (pre-answer)
├─────────────────────────────────────┤
│  [          Submit          ]         │
└─────────────────────────────────────┘
     ↓ after submit → free explanation panel (§4) → Continue
```

- One widget per `QuizItem` subtype (drag list for `OrderItem`, two-column tap-to-link for `MatchItem`, editor for code types, rendered option cards for `CssVisualItem`).
- Help bar shows live cost ("1 ad or 10💎"); tapping opens the opt-in/ad-or-gem chooser.
- Gem balance always visible in the app bar; spend animations for feedback.
- Result/explanation panel is identical across types (consistency).

---

## 14. Progression & certificate requirements (updated)

- Quiz **difficulty unlocks** with lesson progress in a track (expert items appear once the track is largely complete).
- **Topic mastery** = accuracy ≥ threshold across a topic's items; mastery feeds badges and "review" suggestions.
- **Certificate (updated):** track lessons complete **AND** boss quiz ≥80%. **Graduate:** all tracks + all boss quizzes (+ optional interview-mode threshold). This is the one change to the shipped certificate system, and it's additive (a stricter unlock, not a schema break).

---

## 15. Roadmap (phased — economy and ethics before ads)

**P1 — Polymorphic model + free explanations.** Build the sealed `QuizItem` hierarchy; implement Selection + Fill-blank + Output-prediction types; show free post-answer explanations. *Ships strictly better quizzes with zero monetization risk.*

**P2 — Gem economy (no ads yet).** Add the Gem currency, earn paths, balance UI, and the spend flow for hints/reveals using **gems only**. Establishes and lets you tune the economy in a safe, offline, ad-free form first.

**P3 — Rewarded ads.** Wire AdMob `RewardedAd` as the *alternative* to gems, with offline/no-fill fallback, daily limits, and the families/child-directed compliance work. *Monetization goes live only after the economy is proven.*

**P4 — Sequence & pairing types.** Drag-order, arrange-HTML, match-pairs, CSS-visual (WebView option rendering).

**P5 — Code types + coding exam.** Complete-code, find-bug, and exam mode via the existing `ChallengeValidator`.

**P6 — Boss quizzes + certificate gating + analytics screen.**

**P7 — Interview mode + timers/streak-multiplier polish.**

---

*End of quiz & ad design. No code written. The deliberate stance throughout: explanations are free (learning is never sold), help is gated by a Gem economy with rewarded ads as an opt-in accelerator, ads never block learning offline, and the "12 types" reduce to 4 validators reusing your existing `ChallengeValidator`. Build the model and free explanations first; turn on ads only after the gem economy is proven.*
