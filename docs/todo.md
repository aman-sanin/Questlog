# QuestLog — TODO (from P7: feature wave + ship)

---

# P-COACH — Coach Engine Commission (~1 day)

**Goal:** the trigger-action coach system: 10 deterministic detectors, a
cooldown/backoff filter, gain-framed copy, one card slot on Today.
No ML, no new tables, no background work. The only persisted state is a KV
cooldown map. Every card action routes through an EXISTING write use-case —
the coach advises; the guardrails still govern.

**Slot:** after P7 closure; parallelizable with P8–P11. Files touched:
`domain/insights.dart` (detectors, pure), a small app-layer filter, the
Today top slot, KV. **File as P12b in todo.md.**

**Prerequisites to confirm first:** `insights.dart` is pure (no Flutter,
no `DateTime.now()` — injected clock only), KV store exists, CoachCard
component exists.

---

## 1. Current state → delta

| Exists (verify)                                              | Build                                                                                                                |
| ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| Mastery detector, aggregate load detector, welcome-back card | `stale`, `zombie`, `essential_stumble`, `milestone_near`, `perfect_week_near`, `backup_nudge` + load's same-rule cap |
| Coach cards on Insights                                      | **Move to Today top slot** (ruling §8)                                                                               |
| Nothing                                                      | KV cooldown system, dismissal backoff, dedup keys, triage sheet, copy bible, copy lint                               |

## 2. Pipeline

```
LOG + QUESTS + SETTINGS + CLOCK (injected)
  ① DETECTORS   pure functions in domain/insights.dart → CoachSignal
  ② RANKING     deterministic (§4)
  ③ COOLDOWN    app-layer KV filter (§5) — the only stateful stage
  ④ THE CARD    existing CoachCard, Today top slot, max one
  ⑤ ACTIONS     existing use-cases: editQuest (safe fields), cadence
                change (fires the streak-warning guardrail), pause,
                archive, export
```

All rates = satisfied scheduled periods ÷ scheduled periods in window,
grace and pause excluded. Health conditions require ≥ 10 scheduled
periods in 14d — this self-gates: **no user is coached in week one.**

## 3. Detector catalog (machine specs)

### Health (per-quest)

| rule                | condition                                                                                 | notes                                               |
| ------------------- | ----------------------------------------------------------------------------------------- | --------------------------------------------------- |
| `mastery`           | rate ≥ 0.90 ∧ ≥ 10 periods in 14d ∧ streak ≥ 7                                            | counter → raise target; checkbox → raise difficulty |
| `rightsize`         | rate < 0.50 ∧ ≥ 10 periods ∧ past grace                                                   | daily → suggest 3×/week; counter → lower target     |
| `stale`             | last completion ≥ 30d ∧ active ∧ ≥ 1 completion ever                                      | "has history" distinguishes it from zombie          |
| `zombie`            | created ≥ 14d ∧ zero completions ever                                                     |                                                     |
| `essential_stumble` | ≥ 3 consecutive closed unsatisfied essential units (grace/pause excluded by constitution) | care check-in, 14d cooldown (not 30)                |

### Momentum (positive, informational — no state-changing actions)

| rule                | condition                                                                                        | notes                                                                                                                                       |
| ------------------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `milestone_near`    | currentStreak ∈ {6, 29, 99, 364} ∧ current unit unsatisfied                                      | XP per copy: 7→+50, 30→+150, 100→+500, 365→+2000. **Dedup: fires once EVER per (quest, milestone N)** — key `coach:milestone:<questId>:<N>` |
| `perfect_week_near` | calendar days to week-window close ≤ 1 ∧ exactly 1 unsatisfied essential unit in the open window |                                                                                                                                             |

### Safety & system

| rule           | condition                                                                                 | notes                                                                                                                         |
| -------------- | ----------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `backup_nudge` | lifetime completions ≥ 50 ∧ (no export ever ∨ lastExportAt > 45d)                         | **write `lastExportAt` to KV inside the existing export flow** — this is the one production-code touch outside insights/Today |
| `load`         | ≥ 6 active quests with 14d rate < 0.50, **OR** ≥ 3 quests triggering the same health rule | aggregate cap: when ≥ 3 share a rule, their individual cards are suppressed and load represents them                          |
| `welcome_back` | ≥ 14d absence (exists)                                                                    | **add 60d re-fire cooldown** (currently one-shot forever)                                                                     |

## 4. Ranking (deterministic, one card renders)

```
welcome_back > backup_nudge > essential_stumble > load > zombie > stale
            > rightsize > mastery > milestone_near > perfect_week_near
```

Within a class: health → lowest rate first; mastery → highest streak
first; tiebreak `createdAt`. Same inputs must produce the same card,
twice — determinism is tested.

## 5. Cooldown & KV schema

KV map `coach_shown`:

```json
{
  "rightsize:q42": { "last": "2025-06-12", "dismissCount": 1 },
  "coach:milestone:q42:30": { "once": true }
}
```

- Base cooldown: **30 days** per `(ruleType, questId)`; global rules
  (load, backup, welcome_back) keyed `(ruleType)` only.
- Dismissal backoff: `min(30 × 2^dismissCount, 90)` days → 30 → 60 → 90.
- Acceptance mostly self-resolves (raising the target kills the mastery
  condition) — no acceptance tracking.
- `essential_stumble` overrides base to 14d. `welcome_back` re-fire 60d.
- Milestone dedup keys are once-ever.
- Dates stored as local `YYYY-MM-DD` strings per house convention.
- Optional instrumentation: `coach_fire_counts` KV map, incremented when
  a card renders — powers the dogfood rarity audit (§10).

## 6. Copy bible (EXACT strings — do not rewrite, do not "improve")

Placeholders: `{title}`, `{pct}`, `{days}`, `{n}`, `{xp}`. Body = Geist 16,
evidence-first. Actions = existing pill variants. A dismiss `×` on every card.

| rule              | copy                                                          | actions                                                                                |
| ----------------- | ------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| mastery           | "{title} is at {pct}% over two weeks — raise the bar?"        | counter: "{n} → {n+step}" (step = max(1, n ~/ 2)) · checkbox: "Easy → Medium" · "Keep" |
| rightsize         | "{title} is at {pct}% over two weeks — right-size it?"        | daily: "Daily → 3× weekly" · counter: "Lower target" · "Keep"                          |
| stale             | "{title} hasn't been logged in {days} days."                  | "Pause 30 days" · "Archive"                                                            |
| zombie            | "{title} was never started."                                  | "Right-size" · "Archive"                                                               |
| essential_stumble | "Three misses in a row on {title} — still the right quest?"   | "Pause" · "Keep going"                                                                 |
| milestone_near    | "One completion banks a {n}-period milestone — +{xp} XP."     | "Understood"                                                                           |
| perfect_week_near | "One quest from a Perfect Week — +75 XP and a freeze."        | "Understood"                                                                           |
| backup_nudge      | "{n} completions live on this device alone. Export a backup?" | "Export" · dismiss                                                                     |
| load              | "{n} quests are under 50% — time to lighten the load?"        | "Review" · "Keep all"                                                                  |
| welcome_back      | "Away {days} days — today is unwritten."                      | "Continue" · "Review quests"                                                           |

**Copy law (applies to any string the agent must add):**

1. Evidence first — every card opens with a number.
2. Gain-framed, never loss-framed. No streak-fear, ever.
3. The app reports; the user decides. No imperatives without a question
   mark. **No exclamation marks anywhere in coach copy.**
4. Care, not accusation — failure framing is always "maybe the quest is
   wrong," never "maybe you are."
5. Coach cards are monochrome (no `miss` red on cards).

## 7. Actions & triage sheet

- Target/difficulty edits → `editQuest` safe fields (no streak effects).
- Cadence suggestions (rightsize) → the normal editor flow, which **fires
  the existing cadence-change streak warning** — verify this path works.
- "Review" (load) → **new triage sheet**: bottom sheet, `tonal`, sharp,
  listing the underperforming quests — each row: title + mono 14d rate +
  Pause / Archive. No new mechanics, just a filtered list.
- "Export" (backup_nudge) → existing export flow (which now writes
  `lastExportAt`).

## 8. Placement ruling (reconcile drift)

Coach cards move **Insights → Today, top slot above the first section,
max one, dismissible**. Today is where action happens; the card's buttons
act on quests visible below it. Insights keeps the observational ISO-week
insight rotation card and stats — those never carry actions.

## 9. Tunables (add to `tunables.dart`, nothing hardcoded)

`coachMasteryPct 0.90 · coachMasteryPeriods 10 · coachRightsizePct 0.50 ·
coachStaleDays 30 · coachZombieDays 14 · coachStumbleCount 3 ·
coachStumbleCooldown 14 · coachBackupMinCompletions 50 ·
coachBackupDays 45 · coachLoadQuests 6 · coachLoadCap 3 ·
coachBaseCooldown 30 · coachMaxCooldown 90 · coachWelcomeCooldown 60`

## 10. Tests (mutation-checked — the suite must FAIL on each mutation)

- Each detector: seeded fixture fires / doesn't (96% fires, 89% doesn't;
  3 consecutive misses fires, 2 doesn't; 45d-since-export fires, 44
  doesn't; 34d stale fires, 29 doesn't)
- Cooldown: fires → 30d block; dismissal → 60d; second → 90d cap;
  persists across restart
- Dedup: milestone card fires once for streak-6 approach; never again
  even if streak oscillates 6→7→reset→6
- Aggregate cap: 3 quests on one rule → aggregate only
- Ranking: same inputs → identical card, evaluated twice
- welcome_back re-fires only after 60d
- **Copy lint:** no coach string contains "!" or "should" — naive test,
  worth having
- **Mutations to inject:** mastery 0.90→0.80 · delete the cooldown KV
  read · milestone set {6→5}
- Dogfood audit hook: `coach_fire_counts` — any rule > ~15% of sessions
  means its threshold or cooldown is wrong

## 11. Acceptance gates (manual, two minutes each)

1. Fresh user, week one: **zero coach cards**
2. Seeded 96% quest: mastery card renders on **Today** (not Insights),
   math hand-checked
3. Dismiss → gone; debug clock +60d → returns; dismiss again → 90d
4. Milestone card: fires once, correct XP in copy, correct dedup
5. Rightsize action on a streaked quest → the cadence-warning dialog
   appears (guardrail integration)
6. Export via backup card → `lastExportAt` written; no refire within 45d
7. welcome_back fires once, not again until 60d
8. Copy lint green

## 12. Deliverables (protocol)

(1) Paste actual `flutter test` output — summary lines, not prose.
(2) State which gates were NOT met, explicitly. (3) Run the three
mutations and paste the failing output, then restore and paste green.
Claims are worthless; outputs are the contract.

---

## todo.md stub

- [x] **P12b — Coach engine (~1 day)** — 7 new detectors (stale · zombie ·
      essential_stumble · milestone_near · perfect_week_near ·
      backup_nudge + load cap rule) · KV cooldown w/ dismissal backoff
      (30→60→90) · placement move Insights → Today top slot · triage
      sheet · copy bible verbatim · tunables · copy lint · 3 mutations

One commissioning note before you hand it over: the two highest-drift-risk items are §6 (agents _love_ rewriting copy "for polish" — the strings are verbatim by law) and §8 (the Insights placement already drifted once, so gate #2 exists specifically to catch it regressing). Both have manual gates; hold the agent to them.

---

## P-End — Dogfood (2–4 weeks — the real QA)

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
