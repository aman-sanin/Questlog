# QuestLog — Badge Registry

**badges.md · v2 · 100 badges · feeds P9b (badge screen) and P10 (The Path trials)**

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
RARITIES · CALLING · KEEPER · SEALED** (fixed; sections are the filter, no
filter controls). Tiles: earned = `lineRest` + Ember icon · locked =
`lineRule` + 40% icon + mini lock · sealed = `lineRest` + `?`.
Header: `BADGES · n/100` + thin Frost bar.

Within each section grid, **unearned badges render first** (current pursuits
on top), earned sink to the bottom; catalog order is kept within each group.
Quest lists follow the same law on Today and in goal sheets: incomplete
quests on top, completed sink to the bottom (essentials, rare cadences, then
title within each group).

Sealed behavior: tiles show as `?` with count ("12 SEALED"); tap → one static
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

## 7 · ECONOMY — the freeze economy (8)

Grants derive from the log via `FreezeEngine` (see §16): 2 per perfect
daily/weekly week, 1 per essentials-only week; wallet capped at 5, repairs
spend automatically (essentials first). Ledger perfect-week events are
XP-only and not counted here.

| key            | name           | icon               | criteria                                                                | flavor                       |
| -------------- | -------------- | ------------------ | ----------------------------------------------------------------------- | ---------------------------- |
| first_freeze   | First Freeze   | ac_unit            | ≥ 1 freeze granted                                                      | You banked your first mercy. |
| full_pantry    | Full Pantry    | inventory_2        | wallet replay ever reaches 2 (grants +, repairs −, ordered, cap 5)      | Two mercies in reserve.      |
| grace_thrice   | Grace Thrice   | volunteer_activism | COUNT(streak_repairs) ≥ 3                                               | Rescued, and rescued again.  |
| first_grace    | First Grace    | handshake          | COUNT(streak_repairs) ≥ 1                                               | The first rescue.            |
| grace_fivefold | Grace Fivefold | diversity_3        | COUNT(streak_repairs) ≥ 5                                               | Five streaks preserved.      |
| grace_tenfold  | Grace Tenfold  | volunteer_activism | COUNT(streak_repairs) ≥ 10                                              | Ten times spared.            |
| mercy_five     | Five Mercies   | ac_unit            | ≥ 5 freeze grants                                                       | Five mercies banked.         |
| mercy_ten      | Ten Mercies    | inventory          | ≥ 10 freeze grants                                                      | A full winter of mercy.      |

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

**Count check:** 11 + 12 + 11 + 8 + 8 + 11 + 17 + 10 + 12 = **100**.
Header math uses 100; while The Scribe is dormant (pre-P12) it still counts
toward 100 (the SEALED count reads 12 either way).

---

## 11 · Eligibility query specs (implementation notes)

- Counts are simple `COUNT`s over completions (domain-filtered via the quest
  join; goal counts via `goals.completed_at`).
- Streak criteria call the existing streak engine (max streak per quest,
  cadence-aware) — never a reimplementation.
- `perfect_month`: iterate calendar months; eligible day = has ≥ 1 scheduled
  essential day-unit; month qualifies when all eligible days satisfied and
  eligible ≥ 20 (excludes sparse early months).
- `full_pantry`: replay wallet timeline — per-week grants from `FreezeEngine`
  (+2 / +1 / 0, closed weeks only), repairs −1 (`streak_repairs` by appliedAt,
  ties toward grants) — badge on first time balance = 2, cap 5. Derived, not
  stored.
- `first_perfect_week`: closed weeks granting exactly 2 (derived, same helper).
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

- Registry integrity: 100 entries, unique keys, all fields present, category
  set matches section list, sealed count = 12
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
where the name differs. Icons may repeat across sections (a few do), but none
may be a UI-grammar icon already carrying meaning elsewhere (check,
star, snowflake).

_The Keeper keeps the sealed shelf. The ledger is never touched._

---

## 15 · v2 additions (50 badges: +5 per section, +10 KEEPER)

Sections are now JOURNEY 11 · STREAKS 12 · PERFECTION 11 · GOALS 8 ·
ECONOMY 8 · RARITIES 11 · CALLING 17 · **KEEPER 10** · SEALED 12 = **100**.
All icons verified against `material_symbols_icons-4.2960.0`; a few repeat
across sections (allowed since v2).

| key | name | icon | criteria | flavor |
| --- | ---- | ---- | -------- | ------ |
| twenty_five | Twenty-Five | tag | COUNT(completions) ≥ 25 | A quarter of a hundred. |
| quarter_thousand | Quarter Thousand | layers | ≥ 250 | Two hundred fifty, kept. |
| half_thousand | Half Thousand | library_books | ≥ 500 | A small library of days. |
| two_thousand | Two Thousand | menu_book | ≥ 2,000 | Volumes, plural. |
| ten_thousand | Ten Thousand | castle | ≥ 10,000 | A fortress of entries. |
| fortnight_fire | Fortnight Fire | bolt | any streak ≥ 14 | Fourteen, burning. |
| fifty_stack | Fifty Stack | inventory | any streak ≥ 50 | Fifty high. |
| double_century | Double Century | shield | any streak ≥ 200 | Two hundred deep. |
| twelve_weeks | Twelve Weeks | calendar_view_week | weekly streak ≥ 12 | A quarter of weeks. |
| half_year_moons | Half-Year Moons | nightlight | monthly streak ≥ 6 | Six moons honored. |
| perfect_silver | Perfect Silver | thumb_up | ≥ 25 perfect days | Twenty-five clean pages. |
| perfect_two_hundred | Perfect Two Hundred | hotel_class | ≥ 200 perfect days | Two hundred flawless. |
| perfect_year | Perfect Year | stars | ≥ 365 perfect days | A year of clean pages. |
| flawless_week | Flawless Week | task_alt | 7 consecutive perfect days | Seven in a row, perfect. |
| flawless_season | Flawless Season | spa | 30 consecutive perfect days | Thirty days, no asterisks. |
| second_chapter | Second Chapter | book | 2 goals completed | Two chapters closed. |
| trilogy | Trilogy | library_books | 3 goals completed | Three, beginning to end. |
| lucky_seven_goals | Lucky Seven | casino | 7 goals completed | Seven ventures finished. |
| fifteen_halls | Fifteen Halls | corporate_fare | 15 goals completed | Fifteen halls walked. |
| silver_library | Silver Library | local_library | 25 goals completed | Twenty-five chapters. |
| first_grace | First Grace | handshake | COUNT(streak_repairs) ≥ 1 | The first rescue. |
| grace_fivefold | Grace Fivefold | diversity_3 | ≥ 5 repairs | Five streaks preserved. |
| grace_tenfold | Grace Tenfold | volunteer_activism | ≥ 10 repairs | Ten times spared. |
| mercy_five | Five Mercies | ac_unit | ≥ 5 freeze grants | Five mercies banked. |
| mercy_ten | Ten Mercies | inventory | ≥ 10 freeze grants | A full winter of mercy. |
| spring_equinox | Spring Equinox | eco | completion dated Mar 20 | Day and night, balanced. |
| autumn_equinox | Autumn Equinox | forest | completion dated Sep 22 | The light turns. |
| hallows | Hallows | skull | completion dated Oct 31 | Kept on the thin night. |
| yule | Yule | redeem | completion dated Dec 25 | A gift to the log. |
| hearts_day | Hearts' Day | favorite | completion dated Feb 14 | Kept with love. |
| first_tribute | First Tribute | swords | ≥ 1 pledged-calling completion (pledge required) | The first offering. |
| oathkeeper | Oathkeeper | gavel | ≥ 25 pledged-calling completions | Twenty-five, in your colors. |
| paragon | Paragon | anchor | ≥ 250 pledged-calling completions | Two hundred fifty, unwavering. |
| unbending | Unbending | account_balance | streak ≥ 60 on pledged-calling quest | Sixty periods, unbroken. |
| full_circle | Full Circle | all_inclusive | completions in all six callings | Every road, walked once. |
| keeper_first_day | First Day Together | pets | ≥ 1 distinct active day | It watched its first day happen. |
| keeper_first_watch | First Watch | visibility | ≥ 1 perfect day | The first perfect day, witnessed. |
| keeper_waking | Waking | alarm | ≥ 10 perfect days (= growthWaking) | Ten perfect days. It stirs. |
| keeper_adorned | Adorned | candle | ≥ 30 perfect days (= growthAdorned) | Thirty. It shines a little. |
| keeper_trimmed | Trimmed | bolt | ≥ 100 perfect days (= growthTrimmed) | A hundred. Ember at the edges. |
| keeper_company_week | A Week of Company | groups | ≥ 7 distinct active days | Seven days kept company. |
| keeper_company_season | A Season of Company | calendar_month | ≥ 30 distinct active days | Thirty days together. |
| keeper_company_year | A Year of Company | public | ≥ 365 distinct active days | A full year, side by side. |
| keeper_level_ten | Level Ten | trending_up | player level ≥ 10 | Double digits. It stands taller. |
| keeper_legend | Legend | hotel_class | player level ≥ 30 (= gildLevel) | Level thirty. The golden face. |
| nightcap | Nightcap | moon_stars | completion hour ∈ [22, 24) · sealed | One last entry before sleep. |
| high_noon | High Noon | light_mode | completion hour = 12 · sealed | Kept at midday. |
| century_backfill | Century Backfill | update | ≥ 100 backfilled completions · sealed | A hundred honest corrections. |
| annalist | Annalist | border_color | ≥ 250 completion notes · sealed | Two hundred fifty entries with words. |
| grand_marathon | Grand Marathon | rocket_launch | ≥ 25 completions on one date · sealed | Twenty-five in a single day. |

Implementation notes:

- `BadgeEngine.evaluate` takes an optional `playerLevel` (default 1, keeps
  old call sites compiling); `badgesStateProvider` threads the live level
  from `totalXpStreamProvider` via `ProgressionEngine.levelFromXp`.
- The KEEPER screen section sits between CALLING and SEALED; calling trials
  header renamed to `CALLING · THE TRIALS` (17 now, not 12).
- Ordering law (§2): badge grids sort unearned-first (stable,
  `orderBadgesForDisplay` in `badges_screen.dart`); quest lists sort
  incomplete-first (`sortQuestsForToday` in `today_provider.dart`, reused by
  goal sheets).
- Live wiring: grants derive from completions+quests, repairs stream from
  the ledger — the full 100 evaluate live, no ledger event reads.

---

## 16 · Freeze rules v2 (streaks + wallet now live)

- **Perfect week = daily + weekly only.** Monthly/yearly/single quests never
  block one (settlement + `FreezeEngine` share the scope). XP unchanged (+75).
- **Grants (exclusive, no stacking):** perfect daily/weekly week → 2 freezes;
  otherwise an essentials-clean week (≥1 scheduled essential, all satisfied)
  → 1 freeze. Only closed weeks grant. Single source: `FreezeEngine`,
  derived at read time from the log — full history, uniform scope.
- **Wallet cap 5.** Replay is chronological (grants +, repairs −, ties toward
  grants), clamped 0..5.
- **Spending is automatic:** `consumeFreezes` runs on every completion write,
  essentials first then oldest quest, persisting repairs backdated by
  periodKey (conflict-update = no double-spend). Read path needs no wallet —
  persisted repairs display through the existing `existingRepairs` channel.
  A miss with no later write consumes on the next write.
- **`bestStreak` is the true historical max** (survives breaks); `streak`
  stays the current run. Streaks remain derived, never stored.
- Live surfaces: `FreezeChip` count ← `freezeWalletProvider`; Profile
  "FREEZES USED" ← `streak_repairs` length; economy badges + First Perfect
  Week evaluate off the helper (no ledger reads).

```

Two implementation notes worth surfacing: the `full_pantry` wallet-replay is the only criterion that needs timeline math rather than a plain COUNT (spec'd in §11), and the icon table in §14 is the one place the agent must verify against the real symbol set rather than trusting the doc.

Want the **P9b commission text** next — this registry plus the screen build order (registry → screen → tests) as a paste-ready hand-off?
```
