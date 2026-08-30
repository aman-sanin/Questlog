# QUESTLOG — Design Document v3.0 "Onyx & Ivory"

**Companion to Architecture Doc v1.0 · Supersedes v2.0 ("Void & Paper") · Themes: Onyx (dark) / Ivory (light)**

**Philosophy — Sacred Progress.** The interface is a gallery and a logbook. Information is treated as a rare commodity: hyper-minimal, high-contrast, flat. Neo-brutalist skeleton (hard edges, hairlines, pure void) with premium-minimalist restraint (generous space, warm ivory, nothing decorative). **Color is a chromatic event** — it appears only when the user earns it, so its appearance is a psychological trigger of value. The app opens as a dark gallery and, as the day is completed, **gilds itself in Ember**. That is the entire experience design in one sentence.

---

## §1 — Design Laws (the constitution)

1. **The chromatic law — three roles plus failure.** **Ivory/Onyx = the machine** (text, borders, structure, in-progress state). **Frost = motion** (incomplete but progressing: fills, arcs, at-risk, focus). **Ember = arrival** (completed, earned, unlocked, celebrated). **Muted red = the one failure state** (missed essentials only). _Frost means moving; Ember means done; ivory means everything else._ This sentence settles every future color argument.
2. **One shape event.** All containers are sharp rectangles. Circles exist only where geometry demands (checkbox ring, progress rings). The 12-lobe burst exists only in the three ceremonies.
3. **Flat only.** No shadows, no glows, no gradients, no blur — ever. Elevation is 1dp hairlines (two strengths) plus one tonal step.
4. **The interface wakes where you touch it.** Resting borders are faint (20%/10%); interaction snaps them to full. The resting state is a quiet gallery; touch is the light switch.
5. **Structure replaces decoration.** Hierarchy from grouping, weight, rhythm, and mono metadata. Icons only where semantic.
6. **One red thing.** Missed essentials — and only the control ring, never the card border. Reward is loud (gold border); failure is quiet (red ring, neutral card). The asymmetry is deliberate.
7. **The machine is fast, the ritual is slow.** State changes: 100–150ms linear, mechanical. The three ceremonies: full slow theater.
8. **Numbers are mono, tabular, integers, and honest.** Every stat, count, streak, and XP numeral in the app is JetBrains Mono. Data never lies and never jitters.

---

## §2 — Tokens

### 2.1 Color

| Token            | Onyx      | Ivory                      | Role                                                                            |
| ---------------- | --------- | -------------------------- | ------------------------------------------------------------------------------- |
| `bg`             | `#000000` | `#FAF7F2`                  | Screen background — the void / the paper                                        |
| `tonal`          | `#121212` | `#FFFCF7`                  | The one elevation step: sheets, dialogs, toasts, pressed fills, progress tracks |
| `textPrimary`    | `#FAF7F2` | `#1A1815`                  | Headlines, quest titles                                                         |
| `textSecondary`  | `#888681` | `#6B675E`                  | Meta, placeholders, inactive nav, streaks                                       |
| `lineRest`       | ivory 20% | ink 10%                    | Resting card/chip/input borders                                                 |
| `lineRule`       | ivory 12% | ink 6%                     | Dividers, section rules, nav rule                                               |
| `lineFull`       | `#FAF7F2` | `#1A1815`                  | Pressed/active borders                                                          |
| `accent` (Frost) | `#4A90E2` | `#0060AC`                  | **Motion** — swappable slot (unlock ladder)                                     |
| `hero` (Ember)   | `#E0A458` | `#A9762B` · text `#8A5A13` | **Arrival** — constant in both themes, never swappable                          |
| `onSolid`        | `#1A1815` | `#FAF7F2`                  | Glyph on solid fills (buttons, completed rings)                                 |
| `miss`           | `#C25B52` | `#A34E46`                  | Missed essentials, destructive actions                                          |
| `scrim`          | 70% black | 55% ink                    | Sheet/dialog overlays                                                           |

**Exhaustive accent map — anything not listed is Structure:**

_Frost (motion):_ progress bar/ring fills · at-risk ring outline · level chip arc · XP bar · goal rings · heatmap intensity (20/45/70%) · focus underline on inputs · unlock-track "next" node · today marker on heatmap · active segmented selection is _ivory_ (structure), not Frost.

_Ember (arrival):_ completed control fills · completed card borders + flash · 100% progress tracks and 100% goal rings · perfect-day heatmap squares · XP toasts and bonus numerals · milestone streak flashes · Perfect Day banner · ceremonies (burst content, sigil, unlock lines, "+250 XP") · crest everywhere (a rank icon) · unlock-track earned nodes · overachievement "+2" chips.

**Unlockable functional accents** (swap the Frost slot only; Ember and all other tokens untouched): **Frost** (default) · **Sage** `#9CAF9C`/`#5F7A66` (L3) · **Ice** (L5) · **Copper** (L13 — deliberately far so it never sits beside Ember and muddles the law).

### 2.2 Typography — the Technical-Humanist stack

| Style     | Font           | Spec                  | Use                                           |
| --------- | -------------- | --------------------- | --------------------------------------------- |
| Display   | Space Grotesk  | 48/700, −0.02em       | Ceremony level numbers, recap hero            |
| Headline  | Space Grotesk  | 32/600                | Screen titles, ceremony names                 |
| HeadlineM | Space Grotesk  | 28/600                | App-bar date, mobile page titles              |
| Title     | Space Grotesk  | 24/500                | Goal titles, section-scale headers            |
| RowTitle  | Space Grotesk  | 18/600                | Quest titles, card titles                     |
| BodyLG    | Geist          | 18/400, 1.6 lh        | Onboarding copy, empty states, dialog intros  |
| Body      | Geist          | 16/400, 1.5 lh        | Meta sentences, dialog copy, coach cards      |
| Label     | JetBrains Mono | 12/500, +0.10em, CAPS | Chips, section headers, and **every numeral** |

Three jobs, three fonts, no overlap: Grotesk speaks, Geist reads, Mono counts. All SIL OFL, all variable; Geist bundled from Vercel's GitHub (Inter is the drop-in fallback if sourcing it ever fails). Subset to latin + digits + punctuation: ~450–550KB total.

### 2.3 Shape

| Token    | Value                | Applied to                                                                                                                                       |
| -------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `sharp`  | 0dp                  | Cards, sheets, dialogs, inputs, buttons, chips, toggles, steppers, segmented controls, toasts, badges, heatmap dots, stat cards, FAB, level chip |
| `circle` | —                    | Checkbox ring, progress/completion rings, crest container                                                                                        |
| `burst`  | 12-lobe stroked path | The three ceremonies only                                                                                                                        |

The FAB is a **56dp sharp ivory square — the monolith**: solid ivory, ink glyph, no border. The most brutalist object in the app, floating in the nav notch.

### 2.4 Spacing & layout

4dp baseline grid. Screen margin 20 · card padding 16 · container padding (sheets, dialogs, ceremonies) 24 · card gap 10 · stacks: 8 / 16 / 32 · app bar 64 · nav bar 64 + notch · content max-width 800dp centered. Individual cards separated by gutters — never grouped lists — so each quest reads as a monolith.

### 2.5 Elevation

| Level                                   | Recipe                                                |
| --------------------------------------- | ----------------------------------------------------- |
| L0 — base                               | `bg`                                                  |
| L1 — resting container                  | `bg` + 1dp `lineRest` border                          |
| L2 — active/pressed                     | `tonal` fill + 1dp `lineFull` border                  |
| L3 — floating (sheets, dialogs, toasts) | `tonal` + 1dp `lineRest` border                       |
| Inverted — primary action               | Solid `textPrimary` fill + `onSolid` glyph, no border |

### 2.6 Iconography & sigils

Material Symbols **Outlined**, wght 400 — the sharp geometry matches the corners. FILL axis 0→1 for toggle states (essential star, active nav, banner sparkle). Watermarks: single glyph or sigil, wght 200, 4–5% opacity, up to 400dp. Six crest sigils are Path-drawn (2dp stroke, round caps, 24dp grid), Ember-stroked, drawable-on, watermarkable. Zero raster assets in the UI.

### 2.7 Haptics & sound

Light impact on completion; medium on level-up and ceremony confirmation. Three opt-in OGGs (check tick, level-up chime, unlock). Sound off by default.

---

## §3 — Motion

| Class                           | Spec                                                                                                                                                                   |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Machine — all state changes** | 100–150ms, linear, no springs: border wake (20→100%), tonal fills, snaps, tab fade-through                                                                             |
| **Press (universal)**           | Scale 0.97 + border snaps full + `tonal` fill, 100ms linear; release snaps back                                                                                        |
| **Completion**                  | Border snaps Ember at 2dp, 200ms, settles to 1dp (the flash); control ring fills Ember; row dims to 55% instantly; rows below close the gap 150ms linear. Haptic light |
| **Sheets/dialogs**              | 280ms slide-up + scrim fade                                                                                                                                            |
| **List enter**                  | 120ms fade, 20ms stagger, max 12 — or nothing                                                                                                                          |
| **Perfect Day banner**          | Slide-down 350ms + settle                                                                                                                                              |
| **Ritual — sigil draw-on**      | PathMetric trim, 600ms linear                                                                                                                                          |
| **Ritual — burst**              | Scale-in 0.6→1 with overshoot, 500ms, then 60s/rev ambient rotation                                                                                                    |
| **Undo**                        | Instant, un-animated — rewind, not animation                                                                                                                           |
| Reduced motion                  | Machine → 0ms; rituals → static final frames; rotation off                                                                                                             |

---

## §4 — Component library (20)

| Component                      | Spec                                                                                                                                                                                                                                                                                                                              |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **QuestRow**                   | L1 monolith: `bg` + 1dp `lineRest`, padding 16, min-height 64, gap-closed by neighbors. Anatomy: leading control 28dp · RowTitle + meta line (Label mono: `DAILY · 23 STREAK · 4 DAYS LEFT`) · trailing EssentialStar (FILL 1, secondary) · 3dp progress track inset along bottom (track `tonal`, fill Frost, tips Ember at 100%) |
| **CheckboxRing**               | 28dp circle, 1.5dp border: pending 40% ivory · at-risk **Frost** · completed **Ember fill + `onSolid` check** (spring-drawn)                                                                                                                                                                                                      |
| **Stepper**                    | Two 48dp sharp squares (`lineRest`, minus/plus) flanking mono 16 count "2/3". Minus disabled at 0; at target plus stays live (overachievement)                                                                                                                                                                                    |
| **CadenceChip**                | Sharp, `lineRest` border, mono caps. Rare cadence due today → Frost text                                                                                                                                                                                                                                                          |
| **LevelChip**                  | 40dp sharp square, `lineRest` border, Frost arc inset 3dp, mono "L7". Tap → Profile                                                                                                                                                                                                                                               |
| **ProgressBar**                | 3dp; `tonal` track, Frost fill, Ember at 100%                                                                                                                                                                                                                                                                                     |
| **CompletionRing**             | CustomPainter arc, Frost on `tonal` track (Ember at 100%). Sizes 16 / 48 / 96 hero                                                                                                                                                                                                                                                |
| **Sigil**                      | Path crest, Ember stroke. Modes: outline · draw-on · watermark 4%                                                                                                                                                                                                                                                                 |
| **StatCard**                   | Sharp L1; value in mono 24/500 + Label caption — the logbook signature                                                                                                                                                                                                                                                            |
| **ActionButton**               | Sharp, 48dp height, Geist 16/500: **Primary** solid ivory/ink, no border · **Secondary** `tonal` + `lineRest` · **Ghost** secondary text, border on press                                                                                                                                                                         |
| **Input**                      | Underline only: 1dp `lineRest` bottom rule, Geist 18, placeholder secondary; focus = **2dp Frost rule**. No boxes                                                                                                                                                                                                                 |
| **SegmentedControl**           | Sharp track `lineRule`; selected segment = solid ivory fill + ink mono glyph                                                                                                                                                                                                                                                      |
| **WeekdayToggles**             | 7 × 40dp sharp squares, `lineRest`; selected = ivory fill + ink mono letter                                                                                                                                                                                                                                                       |
| **RadioRow**                   | Sharp option rows; selected = ivory filled square + Frost check mark                                                                                                                                                                                                                                                              |
| **Burst**                      | 12-lobe path, ivory 30% stroke, content slot, scale-in + slow rotation                                                                                                                                                                                                                                                            |
| **Banner**                     | Full-width `tonal`, `lineRule` bottom: filled sparkle (Ember) + Title ivory + "+15 XP" Ember mono                                                                                                                                                                                                                                 |
| **CoachCard**                  | Sharp L1: icon + Body copy + Primary/Secondary pill actions + dismiss ×                                                                                                                                                                                                                                                           |
| **HeatmapDot**                 | 12dp **square**: Frost 20/45/70% · **full completion = Ember** · miss = red · paused = hollow `lineRule` · off-day = ivory 8% · today = Frost border                                                                                                                                                                              |
| **BadgeTile**                  | 40dp sharp square: earned = `lineRest` border + Ember icon · locked = `lineRule` border + icon 40% + mini lock. Tap → sheet                                                                                                                                                                                                       |
| **EssentialStar / FreezeChip** | Star FILL 1 secondary (editor animates FILL 0↔1). FreezeChip: sharp `lineRest` box, snowflake + mono count                                                                                                                                                                                                                        |

**QuestRow states (complete):**

| State                                 | Ring               | Card                                                     |
| ------------------------------------- | ------------------ | -------------------------------------------------------- |
| Pending                               | 40% ivory          | L1, full opacity                                         |
| At-risk (18h in, day-scheduled, open) | Frost outline      | L1, full                                                 |
| Completed                             | Ember fill + check | **Ember 1dp border**, 55% dim                            |
| Missed essential                      | `miss` 1.5dp       | L1 neutral border, full opacity, meta "MISSED YESTERDAY" |
| Missed non-essential                  | 25% ivory          | 85% dim                                                  |
| Paused                                | Inert              | 50% + "PAUSED UNTIL JUN 20" mono chip                    |
| Grace (never completed)               | 25% ivory          | Meta "STARTS WITH FIRST COMPLETION"                      |
| Overachieved                          | Ember fill         | "+2" Ember mono chip                                     |
| Legacy (UnsupportedRule)              | —                  | Read-only, "LEGACY" chip                                 |

---

## §5 — Screens

### 5.1 Onboarding (3 steps, ~30 seconds)

**Welcome** — centered sharp L1 card on `bg`, giant `auto_awesome` watermark (wght 200, 4%) behind. Wordmark QUESTLOG (Headline, Grotesk) · "Your quests. Your cadence. No accounts." (BodyLG, secondary) · Primary monolith **Begin**.
**Name** — one underline input, "What should we call you? (optional)", equal-weight Skip / Continue.
**Starter quests** — category chip row (single-select, scroll: FITNESS · MIND · LEARNING · CRAFT · HOME · CREATIVE · SOCIAL · RANGER) filtering template cards (sharp L1: title, cadence chip, mini sigil). Tap toggles an **Ember check** at the row's trailing edge. Footer mono: "3 SELECTED — CHANGE ANYTHING LATER." Button **Start** / **Start anyway**. No calling choice — that is the L2 ceremony.

### 5.2 Today (home)

```
┌──────────────────────────────────┐
│ Thu, Jun 12                 [L7] │  HeadlineM date · LevelChip; tap → Profile
│ ──────────────────────────────── │  lineRule
│  ✦ PERFECT DAY · +15 XP          │  Banner (earned today only; sparkle+XP in Ember)
│                                  │
│ ◔ LEARN GUITAR ────────────────  │  16dp Frost ring + mono header, lineRule underline
│ ┌──────────────────────────────┐ │
│ │ ○ ★ Practice 20 min          │ │  ring 28 · star secondary · Grotesk 18
│ │     DAILY · 23 STREAK         │ │  mono meta
│ └──────────────────────────────┘ │  ← 10dp gutters between monoliths
│ ┌──────────────────────────────┐ │
│ │ ♪   One new chord    − 2/3 + │ │  steppers 48dp sharp
│ │     WEEKLY · 4 DAYS LEFT      │ │
│ │ ▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░ │ │  3dp Frost track
│ └──────────────────────────────┘ │
│ GENERAL ──────────────────────   │  mono header, no icon
│ ┌──────────────────────────────┐ │
│ │ ●   Vitamins                 │ │  completed: Ember ring, Ember border, 55%
│ └──────────────────────────────┘ │
│  (coach card slot, max 1)        │
│ [Today][Insights]  ( ⊕ )  [Prof] │  4-slot nav, FAB monolith in notch
└──────────────────────────────────┘
```

- **Sections:** one per goal (16dp Frost ring = 7-day rate), then GENERAL. Sort within: essentials first, rare-first among them (a yearly quest due today floats to the top — the unmissable day), then due-ness.
- **The gilding:** as quests complete, their borders turn Ember — the screen visibly gilds through the day.
- **Interactions:** tap row → editor sheet · tap control → complete/increment · long-press → context menu (sharp L3 list: Edit · Log past date · Pause · Archive). No swipe-to-complete; no pull-to-refresh (watch-driven).
- **Coach card:** top slot, one at a time, 30-day cooldown per quest/rule.
- **Empty state:** sigil watermark 4% + "Your day is unwritten." (BodyLG) + Primary **Add first quest**.

### 5.3 Quest editor (bottom sheet, `tonal`, sharp, scrim 70%)

Scrollable, in order, every section headed by a mono Label:

1. **Title** — underline input, autofocus on create
2. **CADENCE** — segmented: DAILY · WEEKLY · MONTHLY · YEARLY
3. **SCHEDULE** (contextual, never blurred):
   - Daily: RadioRow _Every day_ / _Certain days_ → WeekdayToggles / _Every N days_ → stepper + anchor note
   - Weekly: RadioRow _N times per week_ → stepper 1–7 / _On days_ → WeekdayToggles
   - Monthly: _N times_ 1–28 / _Day [15]_ / _[2nd] [Tuesday]_ / _Last day_
   - Yearly: date picker / _N times_ 1–12
4. **TARGET** — segmented ✓ Done / ⊕ Counter → stepper + unit underline input ("glasses", "pages")
5. **GOAL** — dropdown (bottom list sheet: None + goals + "New goal…")
6. **DOMAIN** — six mini-sigil chips, single-select, optional (auto-set from templates)
7. **Row: ★ Essential toggle · Difficulty segmented E/M/H**
8. **REMINDER** — dropdown: Off / 09:00 / custom wheel
9. **Save** — Primary; disabled until title valid

**Edit-mode footer:** Pause until [date] · Log for a past date (picker, 30-day cap) · Archive (confirm dialog). **Warnings:** cadence/schedule change on live quest → "This ends your 11-week streak — continue?" (Continue in `miss`). Sixth essential daily → "That's a lot for today — start this Monday instead?" (non-blocking).

### 5.4 Goal editor (sheet)

Emoji grid (24) · title underline input · one-line note · Primary Save. Goals stay conceptual.

### 5.5 Goal detail

Header: emoji 48 · goal Title · hero 96dp CompletionRing (Frost → Ember at 100%). Three StatCards (mono values): completion rate · best streak · total XP. Quest list (live QuestRows, same states as Today). Footer: Secondary **Mark goal complete**; the 90%/8-week trigger adds a Frost border pulse. Completion → goal ceremony.

### 5.6 Insights

```
│  ‹      JUNE 2025      ›         │  HeadlineM + arrows
│   M  T  W  T  T  F  S           │
│   ▪  ▪  ▪  ▪  ▪  ▪  ▪           │  Frost squares by intensity;
│   ▪  ▪  ▪  ▪  ▪  ▪              │  full days = Ember; red = missed
│   ▪  ▪  ▪  ▪                    │  essential; hollow = paused
│  STREAKS ───────────────────    │
│  Practice 20 min       23 DAYS  │  mono counts, in periods
│  Gym 3×/week          11 WEEKS  │  (❄ freeze chip when wallet > 0)
│  INSIGHT ───────────────────    │
│  Weekdays 91% · Weekends 62%    │  one card, rotates weekly (mono numerals)
│ ┌ MAY RECAP · 4,320 XP       → ┐│  first week of month only
│ └──────────────────────────────┘│
```

Tap a day → **Day sheet** (`tonal`): that date's quests in end-of-day states + **Log for this date** (backfill, 30d cap). Month arrows navigate full history; week layout honors week-start.

### 5.7 Profile

- **Header:** 64dp circle (`lineRest` border) with Ember-stroked crest · Headline rung **"Veteran"** · mono Label "ARTIFICER · LEVEL 7 · 1,842 XP" · 4dp XP bar (Frost on `tonal`) · mono "580 XP TO CHAMPION". Pre-calling (L1): hollow 25% circle, outline sigil, "CALLING AWAITS AT LEVEL 2."
- **Affinity:** rows (mini sigil · name · mono % · 4dp ivory bar — chosen calling full, others 40%). Mismatch line when a non-chosen domain >50%: "Your deeds speak of the Warrior's path —" + Ember **RESPEC**.
- **Trials & badges:** 6-col BadgeTile grid; tap → badge sheet (large icon, name, flavor, earned date or requirement).
- **Unlock track:** vertical `lineRule` rail, sharp 40dp nodes — earned (Ember border + Ember check) / next (Frost border, faint pulse) / locked (`lineRest` + lock 40%). **Real items only:** L3 Sage accent · L4 Widget style II · L5 Ice accent · L7 Crest launcher icon · L9 Celebration style II · L10 Crest flair · L13 Copper accent. Titles are never here.
- **Actions:** two Secondary rows — **Change calling** · **Settings**.

### 5.8 Ceremonies (Ember theater on ivory structure)

**Level-up** (root overlay, scrim, one at a time): Burst (ivory 30%, slow rotation) behind a 96dp circle (1.5dp Ember border, Ember sigil inside) · "LEVEL 8" Display · "→ Soldier" Headline · `lineRule` divider · unlock lines in Ember mono with `lock_open` (stacked if multiple; multi-level crossings collapse to the final level) · Primary **Continue** · medium haptic · tap-anywhere dismiss.
**Calling (L2, full-screen):** "CHOOSE YOUR CALLING" Headline + "It shapes your titles — never your XP." 2×3 grid of sharp L1 cards (sigil ivory · name RowTitle · one-liner Body). Tap → expands: sigil **draws itself in Ember**, 600ms · domain line fades up · Primary **Take up this calling**.
**Goal completion:** Burst + goal Title · three StatCards (completions · best streak · XP) · "+250 XP" Ember Display · crest watermark 4% · Close.

### 5.9 Monthly recap (full-screen)

Crest watermark 4%. Headline "MAY 2025". 2-col StatCard grid (mono values): total XP · perfect days · best streak · completion trend vs. April · busiest domain (mini sigil) · most-completed quest. Quest-of-the-month highlight card. Footer: Secondary **Save as image** (RepaintBoundary → PNG share). In Ivory theme this screen is the _gilt manuscript_ — Ember on paper.

### 5.10 Settings (pushed, sharp groups, `lineRule` dividers)

- **Appearance:** Theme segmented ONYX · SYSTEM · IVORY · Accent — four sharp swatches: Frost (selected: Ember border), Sage/Ice/Copper with mono lock badges L3/L5/L13; locked tap → toast "UNLOCKS AT LEVEL 5"
- **Cadence:** Day resets at — 00:00 / 04:00 / custom · Week starts on — Mon/Sun, sub-line "Changing this re-keys historical weeks"
- **Notifications:** Daily digest toggle + time (default 09:00) · quiet "blocked" state if permission denied
- **Data:** Export backup (→ share JSON) · Import backup (file picker → validate → confirm swap)
- **About:** version · level · "All data lives on this device."

---

## §6 — System surfaces

| Surface             | Spec                                                                                          |
| ------------------- | --------------------------------------------------------------------------------------------- |
| **XP toast**        | Bottom-center sharp L3 box: "+18 XP" Ember mono. 1.2s, queued, never overlapping              |
| **Undo snackbar**   | 5s sharp L3: "COMPLETED · +18 XP" ivory mono + **UNDO** ivory action. Undo = instant rewind   |
| **Unlock toast**    | "SAGE ACCENT UNLOCKED" + swatch square; tap → Profile                                         |
| **Badge toast**     | 2.5s: Ember icon + name + flavor                                                              |
| **Warning dialogs** | Sharp `tonal` card, `lineRest` border, scrim; destructive action `miss`; never auto-confirmed |
| **Digest push**     | Factual only: "3 quests due today · 2 essential." Never streak-fear                           |

## §7 — Home-screen widgets

Four styles (I free; II–IV on the ladder), token-aware via pushed snapshot colors, tap → deep link: **Essentials** (checklist) · **Ring** ("3/4 DONE" mono) · **Streak** (perfect-day count) · **List** (next 3 due).

## §8 — Empty & edge states

Today empty (watermark + "Your day is unwritten.") · Insights first-days ("Patterns emerge with time." — heatmap still renders, sparse) · Profile pre-calling · zero-quest goal detail · import failure (error snackbar, data untouched) · permission-denied quiet states · Legacy rows · dynamic type to 1.3× (mono labels truncate gracefully, never wrap).

## §9 — Accessibility

48dp targets throughout · Onyx: ivory-on-void 17:1, secondary ~7:1, Frost ~7.5:1, Ember ~8:1 · Ivory: ink-on-paper ~15:1, secondary ~5.5:1, **Frost-deep `#0060AC` 5.9:1** (why light mode uses the deep variant), Ember text `#8A5A13` (graphics `#A9762B`) · red never signals by color alone (paired with icon + text) · semantics: "Practice guitar, daily quest, essential, streak 23, not completed" · TalkBack live region announces level-ups · full reduced-motion compliance.

## §10 — Implementation wiring

- `ThemeExtension<AppTokens>` carries every token; **`accent` (Frost slot, user-swappable) and `hero` (Ember, constant) are separate** — the swap touches one slot. Two `ThemeData` builds (Onyx/Ivory); golden tests: 2 themes × 2 accents.
- Shape defaults: everything `RoundedRectangleBorder(0)`; press states via `WidgetStateProperty` (scale 0.97 + border wake + tonal fill). The completion flash, sigil draw, and burst are small custom widgets — the only bespoke painting in the app.
- Fonts bundled and subset (Grotesk + Geist + JBM, ~500KB); Material Symbols Outlined tree-shaken via const refs (verify `--analyze-size`). Sigils, burst, watermark: Path painters. **Asset manifest:** fonts ~500KB · icon subset ~100KB · 6 sigil launcher PNGs ~50KB · 3 OGGs ~30KB → app ~20MB vs. 70MB ceiling.
- UI consumes engine outputs only (`QuestState`, progression, moments) — no screen computes logic.

---

## Appendix — What changed from v2 (traceability)

Restyle only; no structural, content, state, or logic changes. **Adopted:** pure `#000000` void · dual accent (Frost motion / Ember arrival) replacing single-accent Ember · three-font stack · everything sharp (pills dead) · underline inputs · resting borders 20% with wake-on-press · mechanical 100–150ms motion · mono numerals everywhere · FAB monolith · heatmap Frost→Ember tip · gilding-the-day. **Killed:** glows, all shadow remnants, blur, strikethrough, Material Symbols Rounded, the unlockable-Ember (now constant), squircles. **Renamed:** themes → Onyx/Ivory; unlock accents → Sage/Ice/Copper.

---
