# P0 — Trust Audit (half a day, blocks everything)

**Goal:** confirm the report's claims before a single new line is written. The last audit found the test suite is cosmetic and the engines are unproven; this phase turns "unproven" into either "verified" or "fixed."

### P0.1 — The five greps

| Command                                           | Expected                                               | If it fails                                                                                                                                                                            |
| ------------------------------------------------- | ------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `grep -rn "DateTime.now()" lib/domain/`           | **Zero hits**                                          | Highest-priority refactor: inject the clock through a provider, pass effective-now into every engine call. Nothing downstream (tests, debug clock, QA) is possible until this is clean |
| `grep -rn "settle(" lib/app/write/`               | Called in complete, undo, backfill, quest edit, import | Wire it — settlement is not optional plumbing                                                                                                                                          |
| `grep -rn "settled_through\|settledThrough" lib/` | Present on quests + profile, advanced by settlement    | Add columns now — schema changes are **free pre-release** (no users = no migration burden), expensive forever after                                                                    |
| `grep -rn "StreakRepair\|streak_repairs" lib/`    | Table + writes on freeze consumption                   | Add; the whole freeze economy hinges on persisted consumption                                                                                                                          |
| `grep -rn "Icons\." lib/ui/`                      | Near-zero                                              | Flutter's built-in `Icons` is the wrong font (no FILL axis, wrong family) — replace with `Symbol()` references                                                                         |

### P0.2 — Spec-drift checklist (the report graded itself wrong)

Each row: check → expected → fix if wrong.

| Claim/area      | Spec truth                                                                                                                                                                   |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Perfect Week    | **+75** and **grants a streak freeze** — not +50 with no grant                                                                                                               |
| Milestones      | Must exist: 7→+50, 30→+150, 100→+500, 365→+2000, paid at period close, once                                                                                                  |
| Perfect Day     | +15 **only** when ≥1 scheduled _day-unit_ essential, all satisfied; window quests gate weeks, not days; zero-essential days are **neutral** (no bonus, no meta-streak break) |
| Badge inventory | Report says 12; spec is ~14 general + 12 trials. At minimum confirm **Comeback** survived (the return-reward badge) — it's the psychology                                    |
| Burst usage     | Fires **only** in the three ceremonies. If Today shows "animated celebration bursts" on completion → remove; completion is the border flash + spring check                   |
| Import          | Export-only is half a feature — import is Phase 4c, but confirm it's genuinely absent, not hidden                                                                            |
| Guardrails      | Cadence-edit streak warning + "6th essential daily" nudge — verify both exist                                                                                                |
| Unlock track    | Real ladder only (Sage L3, widget II L4, Ice L5, crest icon L7, celebration L9, flair L10, Copper L13). "Golden Wrench" style inventions get deleted                         |
| Sigils          | Construction law: simple geometric marks (shield, orb, ensō, three bars, peaks, hex-dot), 24dp grid, 2dp stroke. "Greatsword" is too busy — restyle task lands in P6         |
| Ember           | Constant in both themes; Frost is the only swappable slot; **red never appears on Today** (misses = neutral card + `MISSED YESTERDAY` meta)                                  |
| Templates       | Spot-check the 40+: all 8 categories covered, cadence variety, domains auto-set                                                                                              |
| pubspec         | `flutter pub outdated                                                                                                                                                        | head`— confirm the version upgrade actually took (the old resolve happened before implementation) and`sqlite3_flutter_libs`isn't the EOL line (current drift wants`drift_flutter`) |

### P0.3 — Structural spot-checks

- **Drift:** `schemaVersion = 1`, `MigrationStrategy` stub present, generated `*.g.dart` committed, table columns match the architecture doc §4.1 (XpEvent `UNIQUE(type, ref)` especially — it's your idempotency guarantee).
- **Riverpod 3:** compile errors will surface legacy `StateNotifier`/`ChangeNotifier` patterns; also check no `ref` is used after widget disposal (v3 is stricter).
- **Manifest:** no `INTERNET` permission, `allowBackup="true"`.
- **Fonts:** all three families actually bundled in pubspec assets (not silently falling back to Roboto — the report _claims_ mono typography, verify a `FontFamily('JetBrainsMono')` actually resolves).

**Gate:** every grep clean or its fix merged; drift column list matches §4.1; manifest correct. Only then proceed — everything after this assumes the foundation is real.

---

# P1 — Debug Clock + Data Inspector (half a day)

**Goal:** the QA multiplier. Every time-dependent behavior (rollover, freezes, settlement, the calendar gauntlet, Comeback) becomes manually testable in seconds instead of days. This is _only_ cheap because P0 confirmed clock injection — if the agent says it's hard, that's the diagnostic telling you P0.1 failed.

**Spec:**

- **Entry:** hidden — long-press the version number in Settings → About (5s), or `--dart-define=DEBUG_CLOCK` gating.
- **Controls:** `+1d`, `+7d`, `+30d`, jump-to-date picker, reset to real time. Overrides the same clock provider production code reads — no separate code path, or it tests nothing.
- **Data inspector** (same screen, read-only): current effective today, both settlement markers, freeze wallet balance, last 10 ledger events, active seen-flags. A DB tail viewer costs an hour and makes every future bug report self-explanatory.

**Gate:** advance +1d while the app is open → the Today header date flips, no restart, no manual refresh.

---

# P2 — The Engine Test Suite (1–2 days — the core deliverable of the whole roadmap)

**Goal:** replace 19 render-checks with the ~40 behavioral tests that can actually fail. All pure Dart, injected clock, hand-computed expectations. Grouped, with expected values:

### A. Recurrence properties

| Case                       | Expected                                                       |
| -------------------------- | -------------------------------------------------------------- |
| MWF rule over a full year  | Never yields Sat/Sun; exactly ~156 days                        |
| `every_day` over a year    | 365 (366 leap)                                                 |
| Interval n=3, anchored     | Scheduled exactly every 3rd day from anchor                    |
| 2nd Tuesday                | Exactly one day per month                                      |
| `day_of_month: 31` in June | Fires June 30 (clamped, not vanished)                          |
| Feb 29 in non-leap year    | Fires Feb 28                                                   |
| `last_day`                 | Correct for Feb 28/29, 30/31-day months                        |
| Week of Dec 29–Jan 4       | One period key, correct for both week-start settings           |
| 5th-Friday rule            | Most months: zero scheduled Fridays — and zero possible misses |

### B. Streak money tests

| Case                                                | Expected                                                                                                      |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| MWF, complete Mon+Wed, skip Tue                     | Streak = 2; Tuesday registers as nothing at all                                                               |
| New quest, 3 uncompleted days                       | Grace: no miss, no red, no streak                                                                             |
| Pause spanning a full week                          | Neutral — streak intact, week invisible                                                                       |
| Freeze consumed on miss, streak evaluated **twice** | Consumed exactly once (re-read test — this is the UNIQUE-constraint test)                                     |
| Backfill into a repaired period                     | Repair row deleted, freeze refunded to wallet                                                                 |
| Miss definition                                     | Only scheduled + active + closed + insufficient — assert misses never appear for grace/pause/nonexistent days |

### C. XP math (lock the rounding mode: Dart `.round()`, half-away-from-zero)

| Case                             | Expected                                                                                                                                                                         |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Gym ×3/week medium, 3 increments | 18 / 17 / 18 — invariant: **sum = round(35 × 1.5) = 53**                                                                                                                         |
| 4th increment                    | ≈ +13 (quarter-rate **per extra unit**). ⚠️ Note: the arch doc's inline formula expressed quarter-rate per progress-_fraction_ — lock the per-unit semantics, they're the intent |
| Cap                              | 2 extra units max, period total = round(1.5 × 52.5) = 79; a 3rd extra unit pays 0                                                                                                |
| Partial week, 2 of 3 sessions    | Sum = round(52.5 × 2/3) = 35                                                                                                                                                     |
| Off-schedule completion          | Logged in the DB, scores 0 XP                                                                                                                                                    |
| All values                       | Integers, no exceptions thrown for edge rounding                                                                                                                                 |

### D. Settlement (the deepest group)

| Case                                        | Expected                                                                     |
| ------------------------------------------- | ---------------------------------------------------------------------------- |
| `settle()` twice, back to back              | Ledger **byte-identical** (count per type+ref equal)                         |
| Complete → undo                             | Ledger empty, markers rolled back                                            |
| Perfect week closes                         | One event **+75** AND wallet +1                                              |
| Perfect day with zero scheduled essentials  | No event, and the meta-streak does not break                                 |
| Milestone                                   | Fires when the 7th unit _closes_; still banked if the streak breaks on day 8 |
| Toggle Essential on an old quest, re-settle | History unchanged — the snapshot law                                         |
| Week-start setting changed, re-settle       | No double-granted weeks (range dedup)                                        |

### E. Progression

| Case                                          | Expected                                               |
| --------------------------------------------- | ------------------------------------------------------ |
| cumXP(2)=100, cumXP(6)=1,000, cumXP(10)=2,700 | Exact                                                  |
| Unlock gates at L3/L5/L13                     | Eligibility flips at exactly those thresholds          |
| Title bands                                   | L7 → band rung, L30 → "Legend"                         |
| Affinity                                      | Percentages sum to 100, chosen-calling bar full-weight |

### F. Insights

Coach triggers at >90% / <50% over 14 days; 30-day cooldown enforced; insight rotation deterministic by ISO week (same week → same card).

### G. Widget + golden

The 9 QuestRow states render correctly; golden tests lock tokens for 2 themes × 2 accents.

**Gate (the mutation check — this is how you grade an agent-authored suite):** deliberately break an engine — change 75 to 50 in the perfect-week constant, or break the UNIQUE constraint — and confirm tests **fail**. A suite that survives mutation isn't a suite. Restore, re-run green. That's the difference between this phase and the report's "19 tests passed."

---

# P3 — Manual QA pass (half a day + fix time)

Run the 60-minute script from two turns back (now with the debug clock, so the freeze/rollover/gauntlet items are actually executable). Log every defect with severity, fix, re-run. Additional checks now unlocked:

- Calling ceremony fires exactly once at L2, never again after restart (seen-flag persistence)
- Undo past 5s offers nothing; undo inside 5s returns XP exactly
- Exactly one `perfect_day` event per date after multiple writes (idempotency in the real flow, not just the test)
- Cadence edit → warning; confirm → streak resets
- Ivory theme is warm paper; Ember identical in both; locked swatches refuse with the L-badge toast
- Export → wipe → import (if import exists yet) → identical derived state, no re-celebrations

**Gate:** script passes end-to-end with zero open defects. _This is the moment the app becomes trustworthy._

---

# P4 — The glue, in risk order (½–1 day each)

### 4a. Rollover & lifecycle

Ticker armed to the next reset boundary; **app-resume re-arms and re-invalidates** (Drift watches tables, not time — this is the one manual invalidation); at-risk flips at 18h into the effective day.
**Gate:** app open across a debug-clock midnight → Today flips; app backgrounded 3 "days" and resumed → everything recomputes.

### 4b. Notifications

The reconciler (desired set = digest + per-quest reminders; cancel-all-and-reschedule on every quest CRUD, settings change, completion, and cold start); POST_NOTIFICATIONS ask **at onboarding exit** with one context line (journey discovery #1); SCHEDULE_EXACT_ALARM with inexact fallback; reboot re-arm; tap → `questlog://today`; copy law enforced — factual, never streak-fear.
**Gate:** digest fires at the set time; completing a quest cancels today's reminder; permission denial = quiet blocked state and nothing else changes; after a device reboot, reminders exist.

### 4c. Import (the missing half of backup)

Parse → validate (schema version ≤ app, integrity, `UnsupportedRule` tolerated) → stage in memory → **transactional swap**; seen-flags and settlement markers travel so nothing re-celebrates; failure = data untouched + error snackbar.
**Gate:** export → wipe → import round-trip yields identical level/streaks/wallet/badge count with zero re-toasts; feeding it a hand-corrupted JSON fails cleanly with the DB intact.

### 4d. Widget bridge

Snapshot push (essentials list, counts, theme colors) on every write/settlement/rollover via `home_widget`; style I ships free, II–IV gated; tap deep-links.
**Gate:** completing a quest updates the widget within seconds; theme change reflects; survives reboot.

---

# P5 — Guardrails & the seven journey deltas (half a day)

The findings from the user-journey walkthrough, plus the two guardrails — all small, all load-bearing for the _feel_:

1. Cadence-edit streak warning (if not already verified in P0)
2. Essential-overload nudge ("start this Monday instead?")
3. `STREAK SAVED · ❄` meta line for one day after a freeze consumption — the rescue must be _perceived_ once
4. Welcome-back CoachCard after 14+ days away ("Away 30 days — today is unwritten") — one-shot, one row in the cooldown store
5. Red-never-on-Today as an enforced law, not an implication
6. Settings → Data sub-line: "Your log survives reinstall on this device"
7. Notification ask at onboarding exit (done in 4b)

**Gate:** each item has a two-minute manual test; all pass.

---

# P6 — Identity & assets (1 day)

- **Launcher icons:** the default quest-marker (filled Ember diamond on Onyx, one `Path`), plus 6 crest variants — adaptive icons with foreground/background/**monochrome** layer, glyph inside the 66dp safe zone, strokes _bolder_ than UI glyphs (a 2dp stroke dies at 48dp). `flutter_launcher_icons` config + generated PNGs.
- **L7 runtime icon switch:** `activity-alias` entries for all 7 pre-declared, enabled/disabled at runtime — with a confirm dialog, because the switch briefly restarts the app.
- **Sigil restyle** (if P0 confirmed drift): back to the construction law — shield, orb, ensō, three bars, peaks, hex-dot; sibling-test each against a Material Symbol at the same size.
- **Sounds:** 3 OGGs, setting default **off**, audioplayers wired.
- **Splash:** Android 12+ derives from the launcher icon — verify it on both wallpapers.

**Gate:** icon renders on the launcher; themed (monochrome) icon works on 13+; the L7 switch works after confirm + restart.

---

# P7 — Release hardening (1 day)

- `flutter analyze` zero issues; full suite green
- `flutter build appbundle --release --analyze-size` — **test the release build by hand**: R8 stripping plugin classes is the classic debug-works-release-crashes trap (local_notifications and home_widget usually ship consumer rules — verify)
- Size gate: warn 25MB, fail 35MB
- Accessibility: quest-row semantics ("Practice guitar, daily quest, essential, streak 23, not completed"), TalkBack live region announces level-ups, 48dp targets, reduced-motion honored
- Performance: seed a 10k-completion DB, confirm Today stays jank-free (the 400-day watch recompute is the risk)
- Deep link cold-start _and_ warm-start both land on Today
- Re-verify manifest in the release artifact: no INTERNET, allowBackup on

---

# P8 — Dogfood (2–4 weeks, the real QA)

Use it daily. Keep a defect log. Weekly, run the debug clock through edge scenarios (a missed month, a freeze economy cycle, a return-from-absence). Watch the two flagged economics: perfect-day inflation at low essential counts (discovery #4) and the freeze asymmetry for heavy users (discovery #5) — both are one constant away from changing if they feel wrong in practice.

Then decide distribution: Play Store (needs listing + privacy policy URL even for a zero-data app) or personal sideload.

---

## Commissioning protocol (how to hand this to the agent)

One phase at a time, and every commission ends with the same three requirements: **(1)** paste the actual command output — `flutter test` summary, grep results, build log — not a summary of it; **(2)** state which acceptance-gate items were _not_ met, explicitly; **(3)** for test suites, expect a mutation check — I'll hand you a deliberately-broken constant to inject and the suite must catch it. Claims are worthless; outputs are the contract.

## Definition of done (v1)

All gates green · engine suite passing + mutation-proof · the five flows (cold start, completion, rollover, undo, import) verified end-to-end · both themes locked by goldens · release APK under 25MB · no INTERNET permission in the shipped manifest · 2 weeks of dogfood with no open P0/P1 defects.

## Parked (explicitly not now)

Multiclass L15, self-authored commitments, merge-on-import, sync — all v1.5/v2 by prior ruling.

---
