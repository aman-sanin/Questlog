# QuestLog — TODO (from P7: feature wave + ship)

Status: P0–P6 complete (debug clock, glue, guardrails, assets verified per
feature inventory). Protocol unchanged: one phase at a time · paste real
command output, not summaries · every new suite must fail on an injected
mutation before it counts.

---

# P7 — Accent system + drift closure (~½–1 day) — NOW

**Goal:** fix Frost rendering as Ember's gold, add the gold as a proper
prestige unlock, close the two outstanding spec drifts, and confirm the
engine suite is real.

### 7.1 Frost hex fix — `lib/ui/theme/tokens.dart`

- [ ] Frost accent: Onyx `#4A90E2` · Ivory `#0060AC`
- [ ] Hero (Ember) untouched: Onyx `#E0A458` · Ivory graphics `#A9762B` ·
      Ivory text `#8A5A13`
- [ ] Hardcoding sweep: `grep -rn "E0A458\|A9762B\|4A90E2\|0060AC" lib/` —
      every hit routes through tokens, none inline
- [ ] Settings copy: "Frost (Default neutral gold)" → "Frost (Default)"
- [ ] Gate: progress ring, XP bar, level chip arc, at-risk ring render
      BLUE in both themes; gold appears only on completion/arrival surfaces

### 7.2 Ember as unlockable accent — L16

- [ ] `Accent.ember` resolves to the hero values (same hexes both themes —
      no new colors; contrast already validated)
- [ ] `unlock_schedule.dart`: append `L16 · Ember accent` after Copper L13
- [ ] Settings: 5th swatch with `L16` lock badge; locked tap → toast
      "UNLOCKS AT LEVEL 16"
- [ ] Profile unlock track: L16 node
- [ ] Treatment rules (distinction survives hue unification — comment in code):
      at-risk = gold OUTLINE vs completed = gold FILL · heatmap 100% day =
      solid + `lineFull` border vs opacity steps below · progress hitting
      100% = existing border flash

### 7.3 Drift closure

- [ ] Title ladder: 8 rungs — Recruit · Squire · Soldier · Veteran ·
      Champion · Warlord · Paragon · Legend (then Legend ★N) — all six
      callings; boundary tests at L1/L2/L4/L7/L11/L16/L21/L30/L31
- [ ] Perfect Week: **+75 XP AND freeze grant**; test: exactly one event
      (amount 75, UNIQUE ref) + wallet +1; settle-twice idempotent
- [ ] Verify the P2 engine suite exists and passed a mutation check —
      if not, it gates P13 at minimum

### 7.4 Tests + goldens + docs

- [ ] `accent != hero` assertion for Frost/Sage/Ice/Copper — write BEFORE
      the fix merges and demonstrate it failing (locks out the bug class)
- [ ] Ember-mode treatment tests: outline ≠ fill; 100% square has border,
      70% does not
- [ ] Regenerate goldens deliberately: 2 themes × {Frost, Ember} — expect
      diffs from the gold era, approve consciously, never blind
- [ ] Design doc §2.1 addendum: hero constant for arrival; Ember accent =
      sanctioned unification, L16, prestige semantics

**Gate:** blue Frost everywhere structural; L30 = Legend; a closed perfect
week grants exactly 75 + 1 freeze; mutation check on the new tests.

---

# P8 — N-times daily + interval exposure (~½ day)

**Ruling: a target, not a schedule rule.** "3 glasses daily" = day-scheduled
rule + counter target — no new rule mode, engine already supports it.

- [ ] Editor: TARGET section (✓ Done / ⊕ Counter + N + unit) selectable for
      ALL cadences; expose the Daily **Every-N-days** mode (schema has it)
- [ ] Today row: stepper, 3dp track, meta `DAILY · 2/3 TODAY`; at-risk at
      18h when count < N
- [ ] XP: increments = shares of `round(10 × difficulty)` — medium 3×/day
      pays 5/5/5, sum 15; quarter-rate overachievement, 1.5× cap
- [ ] Streak: satisfied = count ≥ N at day close; partial day = miss;
      essential counter counts only at full N
- [ ] Tests: incremental-sum invariant on the daily period · partial day =
      miss · overachievement cap · grace · pause neutrality
- [ ] Compose check: "3× per day on MWF" = weekdays + counter, no new rule

**Gate:** a "3 glasses, weekdays" quest creates, renders, and its test
suite passes with the sum invariant.

---

# P9 — Quest detail sheet + year heatmap (~1–1.5 days)

**Goal:** the read surfaces — Today is currently write-only.

- [ ] **Quest detail sheet** (tap a quest row): current/best streak · total
      completions · XP earned · 5-week per-quest mini heatmap (existing dot
      grammar) · recent completions list · Edit button
- [ ] **Year heatmap** (Insights Month/Year toggle): GitHub-style columns of
      weeks, 12 months scrollable; tap any square = existing DaySheet; today
      ring; same grammar — Frost intensity, Ember 100%, red miss, hollow
      pause, 8% off-day
- [ ] Tests: aggregation queries vs hand-computed values on a seeded 60-day
      quest; goldens for both themes

**Gate:** a quest with 60 days of history shows correct streak/stats in
detail; year view renders and scrolls smoothly.

---

# P10 — The Path — progression tree (~1–1.5 days)

**Goal:** visualize the job tree. Everything derived — zero new tables,
zero writes. One pure function: `domainStats()` (per-domain lifetime XP,
completion counts, trial badges).

- [ ] Insights "THE PATH" card → full-screen route
- [ ] Radial mini-map (~280dp): central crest, 6 branches at 60°, tap a
      branch → jumps to its row below
- [ ] Six domain rows: sigil · name · mono XP · 14dp node squares · thin
      Frost bar to next node
- [ ] Nodes per branch: milestones at **250 / 1,000 / 5,000 domain XP**
      (SAGE I / II / III — numeric, no per-domain titles) + the 2 class
      trials as secondary nodes
- [ ] Styling per law: branches = 1dp hairlines · earned = **Ember fill** ·
      next = Frost outline + faint pulse · locked = 25% · chosen branch =
      `lineFull` line + Ember sigil, others `lineRest`
- [ ] Sigil draw-on (600ms, existing code) on first screen open — the one
      sanctioned flourish; no burst (data surface, not ceremony)
- [ ] **Multiclass teaser row:** `MULTICLASS · SECOND CALLING — L15`
      locked, 25%, lock icon
- [ ] Ruling: purely informational — no XP, no unlocks, no gates

**Gate:** chosen branch visually distinct without color legend-hunting;
L15 row visible; ledger provably untouched after viewing; tests: aggregation
sums, threshold flips at exact values, goldens 2 themes.

---

# P11 — Quest packs (~1.5–2 days)

**Goal:** bulk import/export as JSON "quest packs" — one format, designed
for authoring and sharing; strictly separate from backups (pack = content,
backup = state).

- [ ] **Format:** `{"format":"questlog-pack","version":1,"name":…}` with
      `goals[]` and `quests[]`; **title is the only required field** — all
      else defaults (daily · every_day · checkbox · easy · non-essential);
      per-cadence optional fields mirror the editor exactly; quests
      reference goals by title
- [ ] **Validation matrix:** wrong format/version → reject file cleanly ·
      bad rows (empty title, target < 1, days out of 1–7, invalid combos) →
      row-level reject, shown with reason, rest imports · unknown fields →
      UnsupportedRule "legacy" import · caps 200 quests / 500KB · duplicate
      titles → flagged, deselected by default · unresolvable goal ref →
      quest imports unassigned
- [ ] **Pack preview screen** (the real deliverable): every quest rendered
      with defaults made explicit, per-row include toggles, rejected rows
      with reasons, aggregate warning if pack sets **>5 essential dailies**
- [ ] **Import:** one transaction; failure = zero rows; 5s undo snackbar
      (we know the created IDs; grace-state quests are safe to delete);
      auto-detect pack vs backup vs garbage by discriminator
- [ ] **Export-as-pack:** Settings → Data → multi-select quests → goals
      auto-embed → share sheet
- [ ] **Example pack as the template:** "Get pack template" ships an
      importable example (daily-counter, weekly-times, monthly-nth-weekday,
      one embedded goal) — learning by importing beats a field reference
- [ ] Optional: "IMPORT PACK" button on onboarding step 3 (migration moment)
- [ ] Privacy line near the buttons: "Packs contain quest setups only —
      your history stays on your device."
- [ ] **Tests:** validation matrix cases · mid-pack failure = zero rows ·
      defaults resolution (title-only quest) · goal embedding/resolution ·
      duplicate flag-and-deselect · caps · pack-vs-backup detection ·
      round-trip (export 5 → import → identical definitions) ·
      UnsupportedRule degradation · >5-essentials warning

**Gate:** round-trip passes; a hand-corrupted file fails cleanly with the
DB intact; grace means imported quests show no streak/red until first
completion.

---

# P12 — Micro batch (~1 day)

- [ ] **Templates in the editor:** "New from template" reusing onboarding
      step-3 UI verbatim (the 40-template library currently dies after
      onboarding)
- [ ] **Completion notes:** long-press the check → "Log with note" (column
      exists); notes surface in DaySheet and quest detail
- [ ] **Rest day:** row context menu → paused-until-tomorrow; renders as
      the existing hollow heatmap dot; DaySheet says "REST DAY". Honest
      split: **rest = planned, freeze = unplanned** — freezes become
      purely for accidents
- [ ] **Records** (Profile lifetime stats): most XP in one day · best week ·
      current perfect-day meta-streak · freezes used — one query each
- [ ] Tests: records vs hand-computed seeds; rest-day renders neutral;
      note round-trips through backup

**Gate:** each item has a two-minute manual test; all pass.

---

# P13 — Constrained windows (~½ day — REQUIRES mutation-verified suite)

- [ ] Weekly times-mode + optional allowed `days[]`; completions count only
      on allowed days; miss logic unchanged (window scoring — the week is
      still the unit)
- [ ] Editor: optional "allowed days" row on weekly-times; validated
      non-empty if shown
- [ ] Tests (engine-touching — mutation check mandatory): completion on
      disallowed day counts 0 · miss still fires only at week close ·
      allowed-days + interval interplay

**Gate:** "3×/week, weekdays only" behaves exactly as spec — sessions
logged Saturday count toward the log but not the window.

---

# P14 — Release hardening (1 day)

- [ ] `flutter analyze` zero issues; full suite green including P7–P13
- [ ] `flutter build appbundle --release --analyze-size` — **hand-test the
      release build**: R8 stripping plugin classes is the classic
      debug-works-release-crashes trap (local_notifications, home_widget —
      verify consumer rules survive)
- [ ] Size gate: warn 25MB / fail 35MB
- [ ] Accessibility: quest-row semantics; NEW surfaces included — quest
      detail ("Practice guitar, 23-day streak, 62 completions"), Path nodes
      labeled ("Sage, 1,240 XP, second milestone earned"), pack preview
      rows; TalkBack live region announces level-ups; 48dp targets;
      reduced-motion honored (incl. Path pulse + sigil draw)
- [ ] Performance: seed 10k-completion DB → Today, year heatmap, and The
      Path all stay jank-free (the 400-day watch recompute + Path painter
      are the risks)
- [ ] Deep link cold-start AND warm-start land on Today
- [ ] Goldens: 2 themes × {Frost, Ember} across all screens
- [ ] Manifest in the release artifact: no INTERNET, allowBackup on

**Gate:** release APK passes the full 60-minute QA script by hand.

---

# P15 — Dogfood (2–4 weeks — the real QA)

Use it daily. Keep a defect log. Weekly debug-clock edge scenarios (a
missed month, a freeze economy cycle, return-from-absence).

**Watchlist:**

- Original economics: perfect-day inflation at low essential counts ·
  freeze asymmetry for heavy loads — both one constant from changing
- New economics: Path pacing (does 250 domain XP land in 2–3 weeks?) ·
  N-times-daily partial-day fairness (2/3 at close = miss — the law, but
  does it _feel_ fair in practice?) · rest-day discoverability ·
  pack round-trips in real sharing · year-heatmap scroll on low-end devices
- Ember accent: reach L16 honestly (no debug clock) before judging it

Then decide distribution: Play Store (listing + privacy-policy URL even for
a zero-data app) or personal sideload.

---

## Commissioning protocol (unchanged)

One phase at a time. Every commission ends with: **(1)** paste actual
command output — `flutter test` summary, grep results, build logs — not
summaries; **(2)** state which gate items were NOT met, explicitly; **(3)**
for test suites, expect a mutation check — a deliberately-broken constant
injected, and the suite must fail. Claims are worthless; outputs are the
contract.

## Definition of done — v1.1

All gates green · engine suite passing + mutation-proof · flows verified
end-to-end: cold start, completion, rollover, undo, backup import, **pack
round-trip** · goldens lock 2 themes × 2 accents across all screens ·
The Path renders with zero ledger writes · release APK under 25MB · no
INTERNET permission in the shipped manifest · 2 weeks dogfood with no open
P0/P1 defects.

## Parked (explicitly not now)

Multiclass (L15) · self-authored commitments · merge-on-import · sync ·
widget tap-to-complete (feasibility investigation first)

```

One sequencing note baked into the doc that's worth saying out loud: **P13 is the only engine-touching phase left**, which is why it's gated behind the mutation-verified suite — and P7's 7.3 checkbox is the cheap way to confirm that suite is real before you need it. If that check fails, run the full P2 suite from the old roadmap before commissioning P13.

```
