# QuestLog — Badge Registry

**badges.md · v1 · 50 badges · feeds P9b (badge screen) and P10 (The Path trials)**

Couplings: the 12 CALLING trials are the single shared registry consumed by both
the badge screen and The Path. The Scribe requires P12 (completion notes) — it
ships dormant until then. Everything here is **derived at read** — the badge
system writes nothing but `seen_moments` reveal flags. The XP ledger is never
touched. Badges pay 0 XP by law: levels are the economy, badges are the trophy
case.

---

## 1 · Registry laws

1. **Deterministic only.** Every badge is a pure function of the completion log
   (+ tables that already exist). Sealed badges hide _information_, never
   _odds_ — no randomness anywhere. (This is what separates them from the
   rejected loot-box pattern.)
2. **Earnable through normal play.** Criteria reward questing, logging, and
   honest upkeep — never menu-fiddling or self-sabotage.
3. **Secrets are positive or whimsical.** Nothing shames the user. The app
   never ambushes.
4. **Sticky.** Earned is earned — reveal once (seen flag), and the tile stays
   earned forever. Imports carry seen flags; nothing re-reveals.
5. **Progress where honest.** Non-sealed locked badges show live progress in
   their detail sheet. Event badges (Leap Day) show none.
6. **Keys are permanent.** The `key` becomes `badge:<key>` in seen_moments and
   in every backup ever exported. Renaming a key after ship orphans history.

## 2 · Entry shape

```dart
class BadgeDef {
  final String key;          // stable id, snake_case
  final String name;         // display
  final String category;     // section (see §3 ordering)
  final String icon;         // Material Symbols Outlined name — VERIFY
                             // each against the symbol set before build
  final String flavor;       // one line, logbook voice
  final BadgeCriteria criteria; // machine spec (§6)
  final ProgressKind progress;  // cumulative | peak | event
  final bool sealed;            // true → SEALED section until revealed
}
```

Screen order: **JOURNEY · STREAKS · PERFECTION · GOALS · ECONOMY ·
RARITIES · CALLING · SEALED** (fixed; sections are the filter, no
filter controls). Tiles: earned = `lineRest` + Ember icon · locked =
`lineRule` + 40% icon + mini lock · sealed = `lineRest` + `?`.
Header: `BADGES · 14/50` + thin Frost bar.

Sealed behavior: tiles show as `?` with count ("7 SEALED"); tap → one static
line for all: _"Sealed by the Keeper. Keep questing."_ On earn: tile migrates
to its home category; reveal toast via moment queue, 3.5s, "SEALED BADGE —
REVEALED" + icon draw-in. Not a ceremony (the three stay three). After
reveal: name/flavor/criteria/earned date, fully open.

---

## 3 · JOURNEY — lifetime completion counts (6)

Progress kind: cumulative (n / threshold). Icons verified against Material
Symbols before build.

| key          | name         | icon              | criteria               | flavor                          |
| ------------ | ------------ | ----------------- | ---------------------- | ------------------------------- |
| first_step   | First Step   | directions_walk   | COUNT(completions) ≥ 1 | The log begins.                 |
| tenfold      | Tenfold      | filter_10         | ≥ 10                   | Ten entries in the book.        |
| half_century | Half-Century | timeline          | ≥ 50                   | Fifty acts, recorded.           |
| century      | Century      | workspace_premium | ≥ 100                  | A hundred proofs of showing up. |
| millennial   | Millennial   | emoji_events      | ≥ 1,000                | The log outgrew its shelf.      |
| long_log     | The Long Log | history_edu       | ≥ 5,000                | A life, kept in entries.        |

## 4 · STREAKS — in scheduled periods (7)

Progress: peak (best relevant streak / threshold). All streaks count
**scheduled periods** per cadence (a weekly quest's 30 = 30 weeks), engine
semantics unchanged.

| key              | name           | icon                  | criteria                          | flavor                    |
| ---------------- | -------------- | --------------------- | --------------------------------- | ------------------------- |
| weeks_worth      | A Week's Worth | local_fire_department | any quest streak ≥ 7              | Seven in a row.           |
| month_iron       | Month of Iron  | fort                  | any quest streak ≥ 30             | Thirty periods, unbroken. |
| streak_centurion | Centurion      | military_tech         | any quest streak ≥ 100            | One hundred periods deep. |
| long_year        | The Long Year  | event_available       | any quest streak ≥ 365            | A year without a miss.    |
| thirty_weeks     | Thirty Weeks   | date_range            | any **weekly** quest streak ≥ 30  | Thirty faithful weeks.    |
| dozen_moons      | A Dozen Moons  | dark_mode             | any **monthly** quest streak ≥ 12 | Twelve moons honored.     |
| three_ages       | Three Ages     | hourglass_top         | any **yearly** quest streak ≥ 3   | Three annual returns.     |

## 5 · PERFECTION (6)

Perfect Day/Week definitions are the settlement engine's (≥1 scheduled
essential day-unit, all satisfied; weeks gate windows). Progress: cumulative
for counts, peak for runs.

| key                | name               | icon                | criteria                                                                                                 | flavor                       |
| ------------------ | ------------------ | ------------------- | -------------------------------------------------------------------------------------------------------- | ---------------------------- |
| perfect_ten        | Perfect Ten        | auto_awesome        | ≥ 10 perfect days                                                                                        | Ten days without a miss.     |
| fifty_flawless     | Fifty Flawless     | verified            | ≥ 50 perfect days                                                                                        | Fifty clean pages.           |
| perfect_hundred    | Perfect Hundred    | diamond             | ≥ 100 perfect days                                                                                       | A hundred flawless entries.  |
| first_perfect_week | First Perfect Week | check_circle        | ≥ 1 perfect week                                                                                         | One whole week, kept.        |
| flawless_fortnight | Flawless Fortnight | done_all            | 14 consecutive perfect days                                                                              | Fourteen days, no asterisks. |
| perfect_month      | The Perfect Month  | calendar_view_month | every eligible day of a calendar month perfect (≥ 20 eligible days; day-units only — windows gate weeks) | A month without a blemish.   |

## 6 · GOALS (3)

| key         | name        | icon         | criteria           | flavor                      |
| ----------- | ----------- | ------------ | ------------------ | --------------------------- |
| goal_getter | Goal Getter | flag         | 1 goal completed   | First chapter closed.       |
| polymath    | Polymath    | psychology   | 5 goals completed  | Five chapters closed.       |
| decathlon   | Decathlon   | sports_score | 10 goals completed | A shelf of finished things. |

## 7 · ECONOMY — the freeze economy (3)

| key          | name         | icon               | criteria                                                               | flavor                       |
| ------------ | ------------ | ------------------ | ---------------------------------------------------------------------- | ---------------------------- |
| first_freeze | First Freeze | ac_unit            | ≥ 1 perfect-week grant exists (ledger)                                 | You banked your first mercy. |
| full_pantry  | Full Pantry  | inventory_2        | wallet timeline replay (grants +1, repairs −1, ordered) ever reaches 2 | Two mercies in reserve.      |
| grace_thrice | Grace Thrice | volunteer_activism | COUNT(streak_repairs) ≥ 3                                              | Rescued, and rescued again.  |

## 8 · RARITIES — calendar events (6)

Progress: **event** (no progress bars — they fire or they don't).

| key             | name              | icon          | criteria                                                                                          | flavor                       |
| --------------- | ----------------- | ------------- | ------------------------------------------------------------------------------------------------- | ---------------------------- |
| new_years_quest | New Year's Quest  | celebration   | completion dated Jan 1                                                                            | The year began with a quest. |
| midwinter       | Midwinter         | severe_cold   | completion dated Dec 21                                                                           | The longest night, kept.     |
| midsummer       | Midsummer         | wb_sunny      | completion dated Jun 21                                                                           | The longest day, honored.    |
| leap_day        | Leap Day          | event         | completion dated Feb 29                                                                           | Four years in the making.    |
| year_one        | Year One          | cake          | completion ≥ 365 days after the log's first                                                       | One year on the trail.       |
| unbroken_year   | The Unbroken Year | all_inclusive | 365 consecutive days each with ≥ 1 completion (log-based — off-schedule counts; scoring does not) | Every single day, written.   |

## 9 · CALLING — the 12 trials (2 per domain)

Cross-listed on The Path (P10) from this same registry. **Eligibility requires
calling == domain** (trials are what make the choice mechanically meaningful).
Structure is deliberately parallel — one query pair parameterized by domain —
with flavor carrying each calling's voice. Progress: peak / cumulative.

| key                   | name             | icon             | domain    | criteria                                         | flavor                       |
| --------------------- | ---------------- | ---------------- | --------- | ------------------------------------------------ | ---------------------------- |
| trial_iron_will       | Iron Will        | fitness_center   | Warrior   | streak ≥ 30 periods on a Warrior-domain quest    | The body keeps its word.     |
| trial_hundred_battles | Hundred Battles  | shield           | Warrior   | ≥ 100 Warrior-domain completions                 | A hundred battles logged.    |
| trial_unbroken_focus  | Unbroken Focus   | menu_book        | Sage      | streak ≥ 30 periods on a Sage-domain quest       | The mind holds the line.     |
| trial_the_archive     | The Archive      | auto_stories     | Sage      | ≥ 100 Sage-domain completions                    | The archive grows heavy.     |
| trial_still_water     | Still Water      | self_improvement | Monk      | streak ≥ 30 periods on a Monk-domain quest       | The surface does not ripple. |
| trial_the_practice    | The Practice     | air              | Monk      | ≥ 100 Monk-domain completions                    | Breath, after breath.        |
| trial_long_refrain    | The Long Refrain | music_note       | Bard      | streak ≥ 30 periods on a Bard-domain quest       | The song refuses to end.     |
| trial_the_repertoire  | The Repertoire   | theater_comedy   | Bard      | ≥ 100 Bard-domain completions                    | Every stage, played.         |
| trial_long_trail      | The Long Trail   | hiking           | Ranger    | streak ≥ 30 periods on a Ranger-domain quest     | The trail goes ever on.      |
| trial_cartographer    | The Cartographer | explore          | Ranger    | ≥ 100 Ranger-domain completions                  | The map fills in.            |
| trial_steady_hands    | Steady Hands     | handyman         | Artificer | streak ≥ 30 periods on an Artificer-domain quest | The hands do not shake.      |
| trial_masterwork      | Masterwork       | construction     | Artificer | ≥ 100 Artificer-domain completions               | Built, and built again.      |

## 10 · SEALED — the seven (criteria hidden until earned)

Laws from §1 apply hardest here: deterministic, earnable by normal play,
positive or whimsical. Progress: **none displayed** — that's the point.

| key           | name          | icon           | criteria (machine)                                            | flavor (post-reveal)                  |
| ------------- | ------------- | -------------- | ------------------------------------------------------------- | ------------------------------------- |
| night_owl     | Night Owl     | bedtime        | ≥ 1 completion whose `created_at` wall-clock ∈ [00:00, 05:00) | Logged while the world slept.         |
| dawnbreaker   | Dawnbreaker   | wb_twilight    | ≥ 1 completion before 07:00                                   | Finished before the sun.              |
| historian     | The Historian | history        | ≥ 25 backfilled completions (local_date < created_at's date)  | The past, honestly kept.              |
| scribe        | The Scribe    | edit_note      | ≥ 50 completion notes — **requires P12**; dormant until then  | Fifty entries with words attached.    |
| perfectionist | Perfectionist | grade          | 14 consecutive perfect days                                   | Flawless, and it stayed flawless.     |
| curator       | The Curator   | museum         | ≥ 5 quests archived with ≥ 90% completion at archive          | Kept what mattered, retired the rest. |
| marathon_day  | Marathon Day  | directions_run | ≥ 12 completions on a single local_date                       | One very full page.                   |

**Count check:** 6 + 7 + 6 + 3 + 3 + 6 + 12 + 7 = **50**.
Header math uses 50; while The Scribe is dormant (pre-P12) it still counts
toward 50 (the SEALED count reads 7 either way).

---

## 11 · Eligibility query specs (implementation notes)

- Counts are simple `COUNT`s over completions (domain-filtered via the quest
  join; goal counts via `goals.completed_at`).
- Streak criteria call the existing streak engine (max streak per quest,
  cadence-aware) — never a reimplementation.
- `perfect_month`: iterate calendar months; eligible day = has ≥ 1 scheduled
  essential day-unit; month qualifies when all eligible days satisfied and
  eligible ≥ 20 (excludes sparse early months).
- `full_pantry`: replay wallet timeline — events ordered by date, grants +1
  (perfect_week ledger refs), repairs −1 (`streak_repairs`) — badge on first
  time balance = 2. Derived, not stored.
- `unbroken_year`: scan distinct completion local_dates; longest run of
  consecutive days; badge when ≥ 365. Log-based (any completion counts,
  including off-schedule) — it is a logging badge, not a scoring one.
- Wall-clock sealed badges use `created_at` with the **injected clock** in
  tests. They are unaffected by the reset-time setting (wall-clock, not
  effective-day).
- `historian`: backfill = `local_date < created_at`'s local date (any positive
  delta counts — covers the backfill flow and legacy data alike).
- Trials: eligibility = `profile.calling == domain` AND criteria met.

## 12 · Moment queue integration

Badge reveals enter the existing queue at badge priority (after level-up and
calling, before… nothing — badges are last). Sealed reveals use the 3.5s
variant with the icon draw-in. `seen_moments` key: `badge:<key>`. Backups
carry seen flags — **no re-reveals after import** (tested).

## 13 · Test table (mutation-checked)

- Registry integrity: 50 entries, unique keys, all fields present, category
  set matches section list, sealed count = 7
- One hand-seeded fixture per criterion (the suite is mostly COUNT
  assertions over seeded logs)
- Sealed: pre-earn, criteria never exposed by any API/surface the UI can
  reach; post-earn, present in home category; reveal fires exactly once
  across re-evaluations and restarts
- Migration: revealed sealed badge renders in its category section
- Backup round-trip: seen flags travel; zero re-reveals
- Edges: Feb 29 leap/non-leap · 13 vs 14 consecutive perfect days ·
  backfill boundary (same-day = not historian) · wallet replay (grant,
  consume, grant → 2) · trial eligibility flips with calling respec
- **Mutation checks (suite must fail):** Perfectionist 14→13 · delete the
  seen-flag write on reveal · flip Leap Day's month check

## 14 · Verification pass (before build)

Every icon name above is a best-guess against Material Symbols Outlined —
verify each in the symbol browser (fonts.google.com/icons) and substitute
where the name differs. No icon may be duplicated within the registry, and
none may be a UI-grammar icon already carrying meaning elsewhere (check,
star, snowflake) — the assignments above already avoid those.

_The Keeper keeps the sealed shelf. The ledger is never touched._

```

Two implementation notes worth surfacing: the `full_pantry` wallet-replay is the only criterion that needs timeline math rather than a plain COUNT (spec'd in §11), and the icon table in §14 is the one place the agent must verify against the real symbol set rather than trusting the doc.

Want the **P9b commission text** next — this registry plus the screen build order (registry → screen → tests) as a paste-ready hand-off?
```
