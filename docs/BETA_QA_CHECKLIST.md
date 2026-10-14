# DevPath v1.2.1+14 — Android beta manual QA checklist

Use build **1.2.1+14** (`com.devpath.app` release or `com.devpath.app.debug` debug).

**Legend**

| Tag | Meaning |
|-----|---------|
| `[AUTO]` | Covered by automated tests in CI |
| `[CODE]` | Verified by source inspection only |
| `[DEVICE]` | Requires physical Android device |
| `[UNVERIFIED]` | Not yet confirmed |

---

## Install & upgrade

| # | Step | Tag | Pass |
|---|------|-----|------|
| 1 | Fresh install opens to dashboard | `[DEVICE]` | |
| 2 | Upgrade from 1.2.1+13 keeps progress | `[DEVICE]` | |
| 3 | About shows **v1.2.1+14** | `[DEVICE]` | |
| 4 | Privacy policy opens in-app (no dead tap) | `[DEVICE]` | |

---

## Navigation

| # | Step | Tag | Pass |
|---|------|-----|------|
| 5 | Dashboard → Learn → lesson | `[AUTO]` partial | |
| 6 | Roadmap opens and scrolls | `[DEVICE]` | |
| 7 | Bottom nav: Home / Learn / Editor / Profile | `[DEVICE]` | |
| 8 | System back from quiz returns to lesson | `[DEVICE]` | |

---

## H1 Heading lesson & quiz

| # | Step | Tag | Pass |
|---|------|-----|------|
| 9 | H1 lesson content scrolls; no horizontal overflow | `[AUTO]` layout | |
| 10 | Figure blocks render (Flutter fallback on Android) | `[CODE]` | |
| 11 | Take Quiz opens **white sheet** with Q1 of 5 | `[DEVICE]` **Confirmed on Honor (+13 screenshot)** |
| 12 | Select answer; **Next** enables | `[DEVICE]` | |
| 13 | Complete all 5 questions | `[DEVICE]` | |
| 14 | Pass (≥70%): result + XP claim | `[AUTO]` flow test | |
| 15 | Fail: retake without corrupting progress | `[DEVICE]` | |
| 16 | `<h1>` option readable and tappable | `[DEVICE]` **Confirmed on Honor** |

---

## b01_html quiz

| # | Step | Tag | Pass |
|---|------|-----|------|
| 17 | Unlock b01 if needed; open quiz | `[AUTO]` catalog | |
| 18 | 3 questions render and complete | `[DEVICE]` | |

---

## Editor / Playground → Quiz (regression)

| # | Step | Tag | Pass |
|---|------|-----|------|
| 19 | Code Editor → Learn → H1 → Quiz (no blank/black) | `[DEVICE]` `[UNVERIFIED]` on +14 |
| 20 | Playground → Learn → H1 → Quiz | `[DEVICE]` `[UNVERIFIED]` |
| 21 | Repeat lesson → quiz → back **3×** | `[DEVICE]` `[UNVERIFIED]` |

---

## Progress & rewards

| # | Step | Tag | Pass |
|---|------|-----|------|
| 22 | Complete lesson once; XP not doubled on second claim | `[AUTO]` idempotent | |
| 23 | Streak increments on active day | `[DEVICE]` | |
| 24 | Achievements screen loads | `[DEVICE]` | |
| 25 | Kill app; reopen; progress persisted | `[DEVICE]` | |
| 26 | Certificates list loads | `[DEVICE]` | |

---

## Offline & notifications

| # | Step | Tag | Pass |
|---|------|-----|------|
| 27 | Airplane mode: open H1 lesson and quiz | `[DEVICE]` | |
| 28 | Profile → Daily reminder requests permission | `[DEVICE]` | |
| 29 | Battery whitelist opens system UI | `[DEVICE]` | |

---

## Layout

| # | Step | Tag | Pass |
|---|------|-----|------|
| 30 | Small phone (~360dp width) quiz readable | `[AUTO]` 360/390/430 | |
| 31 | Long question scrolls; Next remains reachable | `[DEVICE]` | |
| 32 | Release build: **no** yellow debug quiz banner | `[DEVICE]` | |

---

## Automated baseline (agent)

- `[AUTO]` `flutter analyze`: clean  
- `[AUTO]` `flutter test`: 89/89  
- `[AUTO]` Quiz catalog validation (H1=5, b01=3)  
- `[AUTO]` Stale route tests (Linux; not Android WebView)

---

## Physical device evidence on record

- **Honor Android:** H1 quiz visible (user screenshot, **v1.2.1+13**). **+14** retest recommended for release sheet and privacy screen.
