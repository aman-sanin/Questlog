# QUESTLOG — Architecture Document

**Version 1.0 (pre-implementation) · Android only · Flutter · Fully local**

**Constraints of record:** 70MB size ceiling (projected ~20MB), no backend, no accounts, no network permission, no background jobs beyond OS-scheduled notifications, offline-first forever.

---

## 1. System Overview

QUESTLOG is a habit/quest tracker built on one architectural idea:

> **The user authors only completions. Everything else — today's list, streaks, XP, levels, badges, insights — is derived from those completions plus schedule rules, computed on read. The only other persistent writes are irreversible consumptions (freeze repairs) and materialized bonus events (settlement).**

```
USER ACTION                PERSISTENT STATE              DERIVED AT READ
────────────              ─────────────────              ───────────────
complete quest  ──────►   Completion (append-only)  ──►  today list, progress,
backfill        ──────►   XpEvent (ledger, append)       streaks, freeze wallet,
edit quest      ──────►   StreakRepair (consumption)     levels, titles, badges,
choose calling  ──────►   SeenMoment (flags)             affinity, heatmap,
                                                           insights, recaps

SETTLEMENT (idempotent convergence job, foreground):
  materializes period-close bonuses into the ledger exactly once
```

**Why this shape:** zero background processing (no midnight reset service — "today" is a pure function of the clock), full offline operation, trivially testable engines (pure functions + injected clock), and undo/archival become data operations rather than logic inversions.

**Non-goals (v1):** sync, accounts, social, ML, spending economy, XP penalties, per-quest notification spam. See §15.

---

## 2. Stack & Dependencies

| Package                                   | Role                                    | Notes                                           |
| ----------------------------------------- | --------------------------------------- | ----------------------------------------------- |
| Flutter (stable)                          | framework                               |                                                 |
| Riverpod                                  | state + DI                              | streams → derived providers → UI                |
| Drift (+ drift_dev, sqlite3_flutter_libs) | SQLite ORM                              | reactive `watch()`, type converters, migrations |
| go_router                                 | navigation                              | 3 tabs, sheets, deep links (`questlog://today`) |
| flutter_local_notifications (+ timezone)  | digest & reminders                      | reconciler model, §6.4                          |
| home_widget                               | home-screen widget                      | snapshot push, §6.5                             |
| clock                                     | injectable time                         | test determinism, §11                           |
| uuid                                      | row IDs                                 | TEXT UUIDs — future-proof for sync/merge        |
| material_symbols_icons                    | icon font                               | Rounded variant, tree-shaken via const refs     |
| share_plus / file_picker                  | recap image share, backup import/export |                                                 |
| path_provider, collection                 | utilities                               |                                                 |

**Bundled assets:** one subset variable font (Inter, ~150KB, tabular numerals), icon font subset (~100KB), 6 rasterized sigil PNGs for adaptive launcher (~50KB), 3 opt-in OGG sounds (~30KB). No google_fonts runtime fetching; no Lottie; no illustrations; no network.

---

## 3. Project Structure

```
lib/
  main.dart / app.dart / bootstrap.dart        (init db, run migrations, root overlay+router)
  data/
    db/    database.dart, tables.dart, converters.dart, migrations.dart
    dao/   quests.dart, completions.dart, goals.dart, ledger.dart, moments.dart, kv.dart
    backup/ export.dart, import.dart, backup_schema.dart
  domain/                       ← PURE DART, no Flutter imports (lint-enforced)
    engine/
      schedule_rule.dart        sealed classes + JSON codec (+ UnsupportedRule)
      recurrence.dart           isScheduledOn, periodKey, periodOf, clamps, nth-weekday
      quest_state.dart          due-today, progress, at-risk, visual state enum
      streak.dart               the walk, freezes, repairs
      xp.dart                   formula + incremental event math
      settlement.dart           convergence job, markers, undo cascade
      progression.dart          levels, unlock eligibility, titles, affinity
      calling.dart              domains, calling defs
      badges.dart               eligibility computations
      moments.dart              transition detection + priority
      insights.dart             coach checks, insight rotation, recap stats
    model/                      enums, value types, QuestState
    templates.dart              40–60 starter templates
    constants/  xp_constants.dart, unlock_schedule.dart, titles.dart, tunables.dart
  app/
    providers/                  riverpod graph (§6.1)
    write/                      use-cases: complete, undo, backfill, quest CRUD,
                                guardrails, goal completion, calling choose/respec
    services/  rollover.dart, notifications.dart, widget_bridge.dart, haptics.dart
  ui/
    theme/    tokens.dart, app_theme.dart, shapes.dart, sigils.dart
    screens/  today, insights, profile, recap, settings, onboarding, ceremonies
    sheets/   quest_editor, goal_editor, day_sheet, badge_sheet
    widgets/  quest_row, completion_ring, stepper, sigil, morph_button, ...
```

**Dependency rule:** `ui → app → domain ← data`. Domain never imports Flutter.

---

## 4. Data Layer

### 4.1 Schema (complete)

```sql
profile (single row, id=1)
  name TEXT?, calling INTEGER?, calling_chosen_at DATETIME?,
  reset_minute INTEGER DEFAULT 0,          -- day boundary; 0=midnight, 240=04:00
  week_start INTEGER DEFAULT 1,            -- ISO weekday: 1=Mon, 7=Sun
  theme_mode INTEGER, accent TEXT,
  digest_enabled BOOL DEFAULT 1, digest_minute INTEGER DEFAULT 540,
  settled_through TEXT?                    -- global bonus settlement marker (date)

goals
  id TEXT PK, title TEXT, emoji TEXT, note TEXT?,
  created_at DATETIME, archived_at DATETIME?, completed_at DATETIME?

quests
  id TEXT PK, title TEXT, note TEXT?,
  rule TEXT,                               -- JSON schedule rule (§5.1)
  target_type INTEGER,                     -- checkbox | counter
  target_value INTEGER DEFAULT 1, unit TEXT?,
  difficulty INTEGER,                      -- easy|medium|hard
  essential BOOL DEFAULT 0,
  goal_id TEXT? FK, domain INTEGER?,       -- calling domain enum
  reminder_minute INTEGER?,
  paused_until TEXT?,                      -- local date
  settled_through TEXT?,                   -- per-quest settlement marker
  created_at DATETIME, archived_at DATETIME?

completions
  id TEXT PK (uuid), quest_id TEXT FK,
  local_date TEXT,                         -- 'YYYY-MM-DD', the SCORING date
  value INTEGER DEFAULT 1,                 -- counter rows are per-increment (value 1);
                                           -- backfill may write value N
  note TEXT?, timezone TEXT,               -- IANA at write time
  created_at DATETIME                      -- wall-clock, for undo window only
  INDEX (quest_id, local_date)

xp_events                                  -- append-only ledger; lifetime XP = SUM(amount)
  id TEXT PK,
  type INTEGER,                            -- quest | perfect_day | perfect_week | milestone | goal
  ref TEXT,                                -- quest: completionId · milestone: 'questId|N'
                                           -- perfect_day: date · perfect_week: 'start..end' · goal: goalId
  period_ref TEXT?,                        -- quest rows: 'questId|periodKey'
  amount INTEGER, local_date TEXT, created_at DATETIME
  UNIQUE (type, ref)                       -- DB-level idempotency
  INDEX (local_date), INDEX (period_ref)

streak_repairs                             -- consumed freezes (irreversible consumptions)
  id TEXT PK, quest_id TEXT, period_key TEXT, applied_at DATETIME
  UNIQUE (quest_id, period_key)

seen_moments                               -- "celebrated once" flags
  key TEXT PK, seen_at DATETIME
  -- keys: 'level:8' | 'unlock:accent_iii' | 'badge:centurion' | 'calling' | 'onboarding'

kv                                         -- misc: coach cooldowns, widget snapshot cache
  key TEXT PK, value TEXT (JSON)
```

**Derived, never stored:** first completion (birth-grace anchor, `MIN(local_date)`), streaks, freeze wallet, level, titles, affinity, badge eligibility, today's list, progress. **Freeze wallet** = `min(CAP, COUNT(perfect_week events) − COUNT(streak_repairs))`.

### 4.2 Conventions

- All scoring dates are **local calendar dates as text** — lexicographic order = chronological order; timezone is recorded per completion; wall-clock time exists only at the edges (reset boundary, at-risk, reminders).
- Cadence is **not a column** — it's a getter on the parsed rule. One source of truth.
- Unknown rule JSON (backup from a newer app version) parses to `UnsupportedRule`: quest renders as read-only "legacy," never crashes.
- Migrations: `MigrationStrategy` with `schemaVersion = 1` from day one; on schema bump, write step-by-step migrations; import validates `schemaVersion ≤ app`.

---

## 5. Domain Engines

All engines are pure functions of `(rules, completions, settings, now)` — clock injected.

### 5.1 Recurrence engine

**Rule taxonomy (JSON):**

| Cadence | Modes                                                                     |
| ------- | ------------------------------------------------------------------------- |
| daily   | `every_day` · `weekdays:[1,3,5]` · `interval:{n,anchor}`                  |
| weekly  | `times:{n}` (window-scoring) · `on_days:[…]`                              |
| monthly | `times:{n}` · `day_of_month:{d}` · `nth_weekday:{n,weekday}` · `last_day` |
| yearly  | `date:{month,day}` · `times:{n}`                                          |

**Interface (sealed classes):**

```dart
abstract class ScheduleRule {
  Cadence get cadence;
  bool isScheduledOn(LocalDate d);
  String periodKey(LocalDate d, WeekStart ws);
  DateRange periodOf(LocalDate d, WeekStart ws);
  bool get isWindowScheduled;   // times-mode → window scoring
}
```

**Core rulings:**

- Two scoring kinds: **day-scheduled** (each scheduled day is a unit; miss = a closed scheduled day without completion) and **window-scheduled** (the period is the unit; miss = a closed window with `count < times`). "Gym MWF" ≠ "gym 3×/week" — different miss semantics, same engine.
- nth weekday: `d.weekday == weekday && (d.day - 1) ~/ 7 == n - 1`. Last day: `d.day == daysInMonth(d)`.
- Impossible dates clamp: day 31 → month's last day; Feb 29 → Feb 28.
- Weeks key off `week_start` setting; changing it re-keys all historical weeks (completions don't move, groupings do — warned in Settings).
- `targetFor` = `times` (window) or `target_value` (day); `progress = completionsInPeriod / target` — one number feeds engine, XP, and UI bars.

### 5.2 Quest state engine

Per quest per day produces `QuestState`:

```dart
class QuestState {
  Quest quest; bool dueToday; double progress; int streak;
  QuestVisual state;   // pending | atRisk | completed | missedEssential |
                       // missedNonEssential | paused | grace | overachieved
  WindowInfo? window;  // count/target/daysLeft for window quests
}
```

- **dueToday:** day-scheduled → `isScheduledOn(today)`; window → every day of the open window.
- **at-risk:** 18h into the effective day (§6.3), day-scheduled, uncompleted.
- **grace:** before first-ever completion (derived `MIN(local_date)`) — no streak, no red.
- **paused:** `paused_until ≥ today` — inert, neutral, never a miss.
- **missed** = scheduled + active + period closed + insufficient. Only that. (Birth grace and pauses can't miss; non-existent scheduled days — fifth Friday — can't miss.)

### 5.3 Streak engine (the walk)

```
streak(quest, completions, repairs, today):
  for unit in scheduledUnitsBackward(from: today):     // days, or week/month/year windows
    if unit.isOpen: continue
    if unit.end < firstCompletion: break                // birth grace
    if unit.overlapsPausedRange: continue               // neutral
    if satisfied(unit): count++
    else if repairs.has(quest, unit.key): continue      // already consumed
    else if wallet > 0: consume + write StreakRepair; continue
    else break
  return count
```

- Streaks count **scheduled units** (weekly quest "12" = twelve weeks).
- Wallet is global, capacity 2; walk processes quests in deterministic order (essentials first, then `created_at`) so multi-quest misses consume deterministically.
- Backfilling into a period that had a repair **deletes the repair** — the wallet is derived, so the freeze refunds itself.

### 5.4 XP engine

```
periodXP = round( base(cadence) × difficulty ×
                  min(progress, 1 + 0.25·max(0, progress−1)) )   // capped at 1.5×base×difficulty
```

- base: daily 10 · weekly 35 · monthly 120 · yearly 400. difficulty: ×1.0 / ×1.5 / ×2.0.
- **Incremental events:** each completion writes `amount = round(periodXP(currentCount)) − grantedSoFar(period)` — self-correcting rounding; invariant `SUM(events per period) = round(periodXP(final))`.
- **XP accrues only within scheduled periods.** Off-schedule completions are logged (honest log) but score zero.
- Priority never multiplies XP; streaks never scale XP (milestone bonuses carry the dopamine); integers only.

### 5.5 Settlement engine (final spec — was sketch-level)

**Purpose:** derived bonuses must fire _exactly once_ and be _immune to later edits_ — so they're materialized into the ledger at period close. The ledger, not derivation, is the source of lifetime XP.

**Semantics:** settlement is a **convergence job** — for all periods closed after the marker, it makes stored events match derived expectations. Idempotent by construction (UNIQUE(type, ref) + diff-before-write).

```
settle(now):
  // per quest (incl. newly archived, bounded by archived_at):
  for each closed period P where P.end > quest.settled_through:
      ensure quest-events match completions in P          (backfill case: add missing)
      if streakEndingAt(P) ∈ {7,30,100,365}: ensure milestone event 'questId|N'
  // global:
  for each closed day D > profile.settled_through:
      if perfectDay(D): ensure event ref=D
  for each closed week W:
      if perfectWeek(W): ensure event ref='start..end'    (dedup by range — survives week re-keying)
  advance markers to end of last closed period
```

**Definitions (operationalized):**

- **Perfect Day** = ≥1 _day-scheduled_ essential unit that day, all satisfied. (Window quests don't gate days — they gate weeks.)
- **Perfect Week** = every essential unit scheduled that week satisfied (day units + window targets), ≥1 required.
- **Neutral** day/week = no scheduled essential units → no bonus, no grant, **doesn't break the meta-streak**.

**Triggers:** app foreground, after every write/undo/backfill/edit, after import, on rollover timer. Runs synchronously (sub-millisecond at this scale).

**Undo cascade** — the only retroactive door:

```
undo(completion):
  tx:
    delete completion row
    delete xp_events where ref = completion.id
    roll quest.settled_through back to period start of that completion's date
    roll profile.settled_through back to that date
  settle(now)      // re-converges: retracts stale perfect-day/week & milestone
                   // events in the re-settled window, re-materializes
```

Because markers only roll back via undo (and import), **editing the Essential flag or difficulty never rewrites history** — the snapshot principle holds; retraction only ever happens inside windows the undo itself opened.

### 5.6 Progression engine

- **Levels:** `cumXP(L) = 100(L−1) + 25(L−1)(L−2)`; current level derived from `SUM(xp_events)`. Spending doesn't exist; leveling is monotonic.
- **Unlocks:** eligibility = level threshold (L2 calling, L3 accent II, L4 widget II, L5 accent III, L7 crest launcher icon, L9 celebration II, L10 crest flair, L13+ tail). Cosmetic-only by law. "Celebrated" via `seen_moments`.
- **Callings:** Warrior/Sage/Monk/Bard/Ranger/Artificer, each with domain tags, an 8-rung title ladder in level bands (1 / 2–3 / 4–6 / 7–10 / 11–15 / 16–20 / 21–29 / 30+ → Legend, then ★N), 2 class trials. Zero XP effects. Free respec anytime.
- **Affinity:** lifetime XP share per domain (join events → current quest domain — it's a mirror, not history; accepted). Respec suggestion when a non-chosen domain >50%.

### 5.7 Badge engine

~14 general + 12 trial badges, all computed at read: First Step, Century, Millennial, per-cadence streak badges (7/30/100/365), Perfect Ten, Comeback (return after 30+ days away — reward return, never punish absence), Goal Getter, Polymath, + trials. "Seen" flags → toasts fire once. Import carries flags so nothing re-fires.

### 5.8 Insights engine

- **Coach checks:** >90% over 2 weeks → raise-target card; <50% over 2 weeks → right-size card. Cooldown: one card per (quest, rule-type) per 30 days, persisted in KV; dismissal = same cooldown.
- **Insight rotation:** deterministic pick by ISO-week hash from a computed pool (weekday vs weekend rates, best month, etc.).
- **Recap stats:** monthly aggregates for the recap screen.

### 5.9 Moment queue

**Detection = diff between derived state and `seen_moments`:**

- level: `currentLevel > maxSeenLevel` → enqueue (collapse gaps: one dialog shows final level + stacked unlock list)
- calling: `level ≥ 2 ∧ calling == null ∧ !seen('calling')` → full-screen ceremony
- unlocks: eligible ∧ unseen → toast
- badges: eligible ∧ unseen → toast

**Presentation:** serial drain through a root overlay router, priority level-up → calling → unlock → badge. Survives restarts for free (re-derives). Perfect Day banner is _not_ queued — it's today-only display state.

---

## 6. Application Layer

### 6.1 Provider graph

```
db ──┬─ activeQuestsStream ─────────┐
     ├─ completionsWindowStream ────┼──► todayListProvider ──► Today UI
     │   (last 400 days, indexed)   │        │
     ├─ goalsStream ────────────────┘        └─ questStateProvider (family, pure engine calls)
     ├─ ledgerSumStream ──► progressionProvider ──► Profile, level chip, unlock gates
     └─ seenMomentsStream ─► momentQueueProvider ──► root overlay
settingsStream ──► theme, weekStart, reset (params into every engine call)
todayTicker ──► todayProvider ──► invalidates all date-dependent providers
```

Drift `watch()` gives reactivity; engines are invoked inside providers as pure transforms; **no manual refresh anywhere.** Lifetime aggregates (XP, affinity) run as indexed SUMs, separate from the 400-day UI window.

### 6.2 Write use-cases (all transactional, all followed by `settle()` + notification reconcile + widget push)

| Use-case                             | Behavior                                                                                                                                                                                                                                                   |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `complete(quest, value, date?)`      | validate (active, not paused) → write Completion + quest XpEvent (incremental amount)                                                                                                                                                                      |
| `undo(lastCompletion)`               | §5.5 cascade; snackbar window 5s                                                                                                                                                                                                                           |
| `backfill(quest, date ≤ 30d, value)` | same as complete with explicit `local_date`; may refund a repair                                                                                                                                                                                           |
| `quest CRUD`                         | safe fields (title/note/goal/essential/difficulty/reminder/target_value) edit freely — no history effects; cadence/rule edit → streak-reset warning dialog; creating essential daily while ≥5 essentials due → gentle "start Monday?" nudge (non-blocking) |
| `pause / archive`                    | pause sets `paused_until`; archive settles-through then stamps `archived_at` (no hard delete in v1); goal completion offers to archive child quests, +250 event, ceremony                                                                                  |
| `chooseCalling / respec`             | writes profile; free, anytime                                                                                                                                                                                                                              |
| `export / import`                    | §6.6                                                                                                                                                                                                                                                       |

### 6.3 Clock & rollover

`todayProvider` = effective today, computed from injected clock + `reset_minute` (at 04:00 reset, 02:00 belongs to yesterday). A ticker timer arms to the next boundary; **app lifecycle resume re-arms and re-validates** (Drift watches tables, not time — this is the one manual invalidation). At-risk = 18h into the effective day.

### 6.4 Notification reconciler

Desired set = digest (if enabled, daily at `digest_minute`) + per-quest reminders (active quests, at `reminder_minute`). **Reconcile = cancelAll + reschedule** — idempotent, cheap at dozens of notifications. Runs on: app start, quest CRUD, settings change, every completion write (so completing a quest cancels its reminder for today). Android: POST_NOTIFICATIONS runtime permission (13+), SCHEDULE_EXACT_ALARM flow (12+, inexact fallback), re-arm after reboot via cold-start reconcile. Honest limitation: phone off at digest time → no digest that day. Copy law: factual only ("3 quests due today · 2 essential"), never streak-fear.

### 6.5 Widget bridge

On every write / settlement / rollover: push JSON snapshot (essentials list + counts + current theme colors) via `home_widget`; tap deep-links to Today. Widget styles 1–4 gated by unlock ladder.

### 6.6 Backup & restore

Export: single JSON — schemaVersion, profile, goals, quests, completions, xp_events, streak_repairs, seen_moments, kv. Import: parse → validate (version, integrity, UnsupportedRule tolerated) → stage in memory → **transactional swap** (replace semantics in v1; merge-by-uuid is a v1.5 concern — UUIDs already make it possible). Seen flags and settlement markers travel with the backup so ceremonies never re-fire. Android `allowBackup` covers OS-level Drive backup of the SQLite file.

---

## 7. Presentation Layer (interface to the design doc)

- **Routing:** go_router — 3 tabs (Today / Insights / Profile), modal sheets (quest editor, goal editor, day, badge), full-screen routes (calling ceremony, recap, settings, onboarding), root overlay for the moment queue, `questlog://today` deep link.
- **Theming:** two `ThemeData` builds (dark `#121212` family, warm light `#FAF7F2` family) + `ThemeExtension<AppTokens>` carrying all tokens from the UI spec; unlocked accent variants swap the accent slot at runtime (eligibility enforced by progression provider — locked swatches show level badges). Shapes: `RoundedSuperellipseBorder` 20dp cards / 28dp sheets, `StadiumBorder` pills, press-morph 20→12, the single burst `Path` for ceremonies. Material Symbols Rounded, FILL-axis toggles. Haptics: light on completion, medium on level-up.
- **The UI contract:** every screen consumes _only_ engine outputs (`QuestState`, progression, moments) — no screen computes logic. The 15-component library and screen specs live in the design doc (next document), fed by the UI spec + mockup audit (adopt: `#ffbf70` dark accent, Inter, vertical unlock timeline; enforce: neutral essential star, monochrome nav, no strikethrough, no shadows, 48dp targets).

---

## 8. Key Runtime Flows

**1 · Cold start:** open DB → migrate → `settle(now)` → rollover check (re-arm ticker; recompute effective today) → notification reconcile → widget push → providers prime → moment queue drains (backlogged ceremonies collapse) → Today renders.

**2 · Completion (the main flow):** tap check → `complete()` transaction (completion row + incremental XpEvent) → `settle()` (may materialize perfect-day event, milestones) → Drift watch fires → `todayListProvider` recomputes (row dims, streak +1, progress bar, possibly Perfect Day banner) → XP toast → undo snackbar (5s) → notifications reconcile (cancel today's reminder) → widget push → `progressionProvider` recomputes → if level crossed, moment queue enqueues ceremony → dialog after snackbar clears.

**3 · Rollover (04:00 with reset 04:00):** ticker fires → `todayProvider` changes → yesterday's uncompleted essential flips to `missedEssential` (rendered only in history/heatmap — Today shows the new day) → streak walk now sees yesterday's unit → freeze may auto-consume (StreakRepair written lazily at read… **final ruling: repairs are written by the first streak evaluation that needs them, in the same transaction as nothing else — safe because UNIQUE(quest_id, period_key) makes it idempotent**) → digest was pre-scheduled by reconciler.

**4 · Undo:** snackbar action → cascade (§5.5) → re-settle → UI snaps back instantly (undo is un-animated by design — it should feel like rewind).

**5 · Backfill:** day sheet or editor → date picker (≤30d) → identical to a completion with explicit date → settlement converges the reopened period (possible repair refund, possible new perfect-day event).

**6 · Cadence edit:** warning dialog ("ends your 11-week streak") → confirm → rule replaced → streak re-derives from new rule (history intact — completions are immutable; only groupings change).

**7 · Level-up cascade:** write → ledger sum crosses threshold → level provider ticks → moment diff detects uncelebrated level → ceremony (burst, sigil draw, new rung) → unlock toasts for the crossed threshold(s) → seen flags written.

**8 · Import:** file picked → validated → transactional swap → all streams fire once → settlement converges any open periods → nothing re-celebrates.

---

## 9. Invariants (the logic constitution)

1. Completions are the only user-authored truth; append-only; immutable outside the 5s undo window.
2. Everything else derives at read, or is materialized by idempotent settlement.
3. XP accrues only within scheduled periods; the ledger is the sole source of lifetime XP; leveling is monotonic.
4. Irreversible consumptions persist (StreakRepair); grants persist (ledger events); re-settle windows open only via undo/import.
5. A miss requires scheduled + active + closed + insufficient. Birth grace and pauses are neutral. Streaks count scheduled units.
6. Settlement converges stored events to derived expectations; running it twice changes nothing.
7. Engines are pure functions with injected clock; no Flutter imports in `domain/`.
8. Scoring uses local dates + IANA tz; wall-clock exists only at reset/at-risk/reminder edges.
9. Unknown data degrades (UnsupportedRule, legacy quest), never crashes.
10. Notifications are factual; consequences are visible but never punitive arithmetic.

---

## 10. Error Handling & Degradation

| Failure                        | Behavior                                                                 |
| ------------------------------ | ------------------------------------------------------------------------ |
| Corrupt SQLite                 | Drift open failure → offer restore-from-backup screen (export file)      |
| Backup from newer schema       | refuse with explanation; nothing touched                                 |
| Unsupported rule in backup     | import proceeds; quest renders read-only "legacy"                        |
| Notification permission denied | digest/reminder toggles show quiet "blocked" state; app fully functional |
| Exact-alarm permission denied  | fall back to inexact scheduling                                          |
| Widget host unavailable        | bridge no-ops                                                            |

---

## 11. Testing Strategy

- **Engine units (the bulk):** recurrence generator properties (MWF never yields Saturday; nth-weekday = exactly one day/month; interval = every Nth day from anchor); the money tests (streak survives non-scheduled day; birth grace; pause neutrality; freeze consumed exactly once across re-reads); the calendar gauntlet (day-31, Feb 29, last-day February, fifth-Friday, year-boundary weeks, reset-time 03:59/04:01).
- **Settlement properties:** idempotency (settle twice = identical ledger); undo equivalence (complete → undo = empty ledger); edit-Essential-then-settle = unchanged history (snapshot law); week-rekey no-double-grant.
- **Golden tests:** key screens, both themes, both accents (locks the token system).
- **Widget tests:** all 9 QuestRow states; stepper at/over target.
- **Integration:** onboarding → complete → L2 calling ceremony; export → wipe → import round-trip (byte-equal semantics: same derived level, streak, wallet).
- **CI gate:** `flutter build appbundle --analyze-size` — warn at 25MB, fail at 35MB (ceiling is 70, but the _promise_ is lightweight).

---

## 12. Performance & Size

- Engine cost per recompute: streak walks bounded by 400-day lookback × active quests — microseconds. SQLite stays trivial at habit-app scale (~10k rows/year).
- Watch scoping: UI subscribes to the 400-day window; lifetime aggregates are indexed SUMs.
- No `BackdropFilter`, no shaders, no Lottie — the mockup's WebGL glow is a `RadialGradient`. Animations are CustomPainter/implicit.
- **Budget:** engine+framework ~12–16MB, plugins ~2MB, assets ~350KB → **~18–20MB APK.** Headroom to ceiling: ~50MB, reserved for future features by policy, not by accident.

---

## 13. Privacy & Security

No INTERNET permission in the manifest — the strongest possible "local" claim. No analytics, no crash reporting, no identifiers. Data at rest: OS sandbox + Android auto-backup. Export files contain personal behavior data — the settings screen says so in plain words. Notification content stays generic (lock-screen safe).

---

## 14. Tunables Registry (single source: `tunables.dart`)

| Constant                  | Value                                                                                                                      |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| XP bases (D/W/M/Y)        | 10 / 35 / 120 / 400                                                                                                        |
| Difficulty multipliers    | 1.0 / 1.5 / 2.0                                                                                                            |
| Overachievement           | quarter-rate, cap 1.5× period total                                                                                        |
| Perfect Day / Week / Goal | +15 / +75 (+freeze) / +250                                                                                                 |
| Milestones (periods)      | 7→+50 · 30→+150 · 100→+500 · 365→+2000                                                                                     |
| Level curve               | next(L) = 100 + 50(L−1)                                                                                                    |
| Freeze wallet             | cap 2, grant 1/settled perfect week                                                                                        |
| At-risk                   | 18h into effective day                                                                                                     |
| Undo window               | 5s                                                                                                                         |
| Backfill cap              | 30 days                                                                                                                    |
| Lookback window           | 400 days                                                                                                                   |
| Coach cooldown            | 30d per (quest, rule-type)                                                                                                 |
| Reset time                | default 00:00, options 04:00/custom                                                                                        |
| Digest                    | default 09:00                                                                                                              |
| Unlock ladder             | L2 calling · L3 accent II · L4 widget II · L5 accent III · L7 crest icon · L9 celebration II · L10 crest flair · L13+ tail |
| Multiclass                | L15 (v1.5)                                                                                                                 |

---

## 15. Roadmap & Explicit Non-Goals

**v1:** everything in this document. **v1.5:** self-authored commitments (opt-in stakes), multiclass at L15, merge-on-import. **v2 (only if wanted):** optional PocketBase/Supabase sync toggle (append-only logs make this nearly conflict-free), companion sigil variant. **Never in v1:** accounts, social, ML, spending, penalties, variable-ratio rewards.

---
