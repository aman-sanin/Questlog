# QuestLog — The Keeper

**keeper.md · v3 · the Kiko totem · supersedes v2 (face) · post-queue slot (parallel-safe)**
**~1.5–2 days · zero new tables · zero engine changes · all state derived**

Concept: **the app's face.** Not a creature living in the app — the logbook
itself, looking back at you. A face of big pixel eyes and a mouth, floating
in the void. One-liner for every future argument: _a face in the void that
watches you quest, glances at what you complete, and beams only when the
day is earned._

This is the first Keeper design that breaks **zero** design laws: square
blocks on the 4dp grid, 2dp stroke mouths, flat, monochrome, and the
reference aesthetic (white shapes on black) is literally the Onyx theme.

---

## 1 · Keeper laws (the constitution)

1. **Three parts.** Two eyes, one mouth. No body, no container — the
   background is the body. Nothing else is ever drawn.
2. **No reachable shame state.** The classifier's signature cannot express
   disappointment. Frowns, tears, crying, anger, X_X do not exist in the
   vocabulary. Missed days map to `asleep`, never to sadness. The Keeper
   mirrors presence, never absence.
3. **It cannot be harmed.** No feeding, decay, energy, sick states. It
   only grows.
4. **No alert duty.** At-risk belongs to quest rings. The Keeper brightens;
   it never points, never turns Frost, never doubles a signal.
5. **No unearned color.** Features wear `textPrimary` at mood alphas.
   Ember appears exactly twice: the gild flash (shared with the Perfect
   Day banner) and permanent growth trim (Legend). Frost never touches it.
6. **The D-smile is earned.** Flat and small-smile are daily states; the
   open `D` mouth renders only on Perfect Days, celebrations, and petting.
7. **Liveliness lives in the eyes and mouth-sync.** The face has two idle
   motions and nothing else.
8. **Missable by design.** Reactions are small enough to not demand
   attention; noticing them is a reward for attention.
9. **No wall-clock in the painter.** Phase time is a parameter; goldens
   are deterministic. The expression sheet IS the golden test matrix.

## 2 · Anatomy — 12-unit grid (`u = S/12`, S = render size)

| Part            | Spec                                                                                                                                                                     | Channels                                                                                                                                                        |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Eye**         | Two filled sharp rectangles, **3.2u × 4u**, centers at ±2.2u x, −1.5u y (~63% of face width — big, per the references)                                                   | blink = block squashes to 0.15u line (120ms) · half-lid = bg block slides over top 45% (150ms) · wide = ×1.12 · eye-smile = block morphs to a ∪ arc (2dp, 3.2u) |
| **Pupil**       | bg-colored square, 1.6u, default low-center                                                                                                                              | gaze = slides ±0.8u · dilate ×1.4 · pinpoint ×0.5 — this is where "watching" lives                                                                              |
| **Mouth**       | 2dp round-cap strokes, ~3.5u, centered at +2.5u y                                                                                                                        | five shapes (§3) · mouth-sync (§4)                                                                                                                              |
| **Class glyph** | 2dp-stroke mark floating 2.5u above the eye-top, offset-phase bob: Sage 4-point star · Warrior chevron · Monk open ring · Bard three bars · Ranger peaks · Artificer hex | opacity follows mood                                                                                                                                            |
| **Z-motes**     | Mono `z` ~10dp, one per 2.5s, rising 6dp and fading, phase-offset                                                                                                        | asleep, ≥64dp only                                                                                                                                              |
| **Sparkle**     | 1.2u 4-point star at the eye's upper-outer corner                                                                                                                        | celebrating, milestone                                                                                                                                          |
| **Ring ping**   | Hairline circle from face center, 20%→0% ivory, 400ms                                                                                                                    | the entire ambient-light menu, with the gild flash                                                                                                              |

**Sizes:** 28dp Today face (app bar, left of the level chip) · 96dp Profile
face (replaces the static crest circle) · 96dp in the Today empty state.
Glyph renders at all sizes; z-motes at ≥64dp.

**Mood alphas:** quiescent 55% · dormant 35% · attentive 55% · content 85%
· resting 70%.

**Idle (the full motion budget):** bob ±2.5dp / 2400ms ease-in-out ·
pulse scale 1.00→1.02 / 4s (2.5s in anticipation). All off under reduced
motion (static expression); controllers mute offstage.

## 3 · The expression sheet — the core artifact

Default mouth is the **design flat-topped open smile** (the HTML default in
`code.html`, and every awake state's standing mouth). Remaining shapes:
`‿` small smile (3u chord, 0.8u rise) · **`D` open smile (3.5u × 1.8u, FILLED
— the reference's semicircle, earned only)** · `o` small circle outline
(1.5r, 2dp) · `〜` wavy (three 1u segments) · squiggle / frown-crescent /
chevron for skeptical / sad / grumpy.

**Banned, explicitly:** frown, tears, cry-waves, anger, X_X. The
constitution filters the reference sheet; the face's range is
positive/neutral only.

| Expression                | Eyes                       | Pupils                       | Mouth                       | Renders when                                              |
| ------------------------- | -------------------------- | ---------------------------- | --------------------------- | --------------------------------------------------------- |
| **asleep**                | closed lines + z-motes     | —                            | tiny dot                    | dormant (quests due, zero completions)                    |
| **waking**                | lines → open, double-blink | pinpoint                     | design smile              | app open, 250ms                                           |
| **attentive** _(default)_ | open                       | low-center, gaze drift ±0.8u | design smile               | day in progress                                           |
| **anticipating**          | ×1.12                      | ×1.15                        | design smile               | one essential left — brightens, never points              |
| **content**               | ∪∪                         | —                            | `‿`                         | essentials done                                           |
| **resting**               | half-lid                   | —                            | `‿`                         | dayFraction > 0.75, held day                              |
| **gilded** ⭐             | ∪∪ + sparkle               | ×1.4                         | **`D`** + Ember flash 600ms | Perfect Day (hold 4s)                                     |
| **surprised**             | ×1.15                      | pinpoint ×0.5                | `o` + ring ping             | yearly quest completion, rare events                      |
| **celebrating**           | ∪∪ + corner sparkles       | ×1.4                         | `D`                         | level-up, 4s                                              |
| **petted**                | ∪∪                         | ×1.4                         | `D` + wiggle ±3°            | tap on Profile                                            |
| **glance**                | (overlay)                  | → (dx,dy) clamp ±0.8u/±0.6u  | unchanged                   | any completion: 300ms travel, 500ms hold, blink on return |
| **quiescent**             | open, slight-side          | offset x                     | `〜`                        | zero active quests / nothing due — the empty-state face   |

## 4 · Mouth-sync (the liveliness multiplier)

We own the painter, so sound syncs to the face for ~free:

| Sound                        | Mouth                                        |
| ---------------------------- | -------------------------------------------- |
| `keeper_chirp` (completion)  | flat → small `D` 150ms → back (it pops open) |
| `keeper_trill` (Perfect Day) | `D` + 300ms squash-bounce                    |
| `keeper_purr` (petting)      | tiny quiver on `‿` (±0.3u, 400ms)            |

A face that moves its mouth when it speaks reads as alive at a level no
idle animation reaches.

## 5 · Moods, modifier, poses

Classifier (pure, `domain/`, injected clock — no-shame is in the signature):

```dart
enum KeeperMood { quiescent, dormant, attentive, content, resting }

KeeperMood keeperMoodFor({
  required bool anythingDue,      // any quest due today
  required int completionsToday,
  required bool essentialsDone,
  required double dayFraction,    // effective-day, reset-relative
}) {
  if (!anythingDue) return KeeperMood.quiescent;
  if (completionsToday == 0) return KeeperMood.dormant;
  if (essentialsDone) {
    return dayFraction > 0.75 ? KeeperMood.resting : KeeperMood.content;
  }
  return KeeperMood.attentive;
}
```

**Modifier — anticipation** (exactly one essential remains, derived):
attentive + wide ×1.12 + pupils ×1.15 + pulse quickens 2.5s.

**Pose resolver:** transient expressions overlay the mood base —
`gilded` (600ms flash + 4s hold) · `celebrating` (4s after level-up
dismiss) · `surprised` (500ms) · `petted` (400ms) · `glance` (pupil
overlay only). Poses come from the moment queue / event stream; moods
derive from state. The painter receives a frozen `KeeperRenderState`
(mood, modifier?, pose?, phase, glanceTarget).

## 6 · Reactions & plumbing

| Event                  | Face                                                | Sound                                                  |
| ---------------------- | --------------------------------------------------- | ------------------------------------------------------ |
| Quest complete (daily) | glance at the row, blink on return                  | chirp + mouth-pop                                      |
| Weekly                 | 1dp squash + glance + dilate 150ms                  | chirp                                                  |
| Monthly / yearly       | bounce + **surprised** + ring ping                  | chirp                                                  |
| Counter increment      | quick downward glance                               | —                                                      |
| Perfect Day            | **gilded**: Ember flash + ∪∪ + `D` + sparkle        | trill                                                  |
| Milestone              | sparkle + dilate                                    | —                                                      |
| App open               | waking sequence                                     | —                                                      |
| Profile visit          | looks up at you (pupils up-center), blinks, settles | —                                                      |
| **Pet** (tap, Profile) | ∪∪ + `D` + wiggle                                   | purr + **haptic purr** (two light impacts, 90ms apart) |
| Long-press             | opens the Keeper sheet                              | —                                                      |

**Plumbing:** poses consume the existing post-write event stream (same
sink as the toast queue). Glances are UI-emitted: the quest row's tap
handler calls `keeperController.glanceAt(screenPos)` beside the write
call. This `(dx, dy)` clamp is the only new architecture in the feature.

## 7 · Sounds & haptics

Three assets, mirroring the app's three, behind the existing opt-in sound
toggle (default off): `keeper_chirp` (two-tone blip, <300ms, ~8KB) ·
`keeper_trill` (ascending triplet) · `keeper_purr` (soft low rumble
~400ms). The haptic purr works with sounds off and stays worth fighting
for.

## 8 · Growth, respec, summoning

| Stage        | Trigger (derived)            | Change                                               |
| ------------ | ---------------------------- | ---------------------------------------------------- |
| 0 · Summoned | calling chosen (L2 ceremony) | face + glyph, drowsy                                 |
| 1 · Waking   | 10 perfect days              | full idle set                                        |
| 2 · Adorned  | 30 perfect days              | glyph gains a second detail                          |
| 3 · Trimmed  | 100 perfect days             | **glyph turns Ember**                                |
| 4 · Gilded   | L30 · Legend                 | **the golden face** — all features permanently Ember |

**Pre-calling:** Profile shows the unsummoned Keeper — 20% opacity, no glyph.
The eyes still follow the mood: closed lines only while the day is untouched,
so a single completion today opens them even before summoning. The L2 ceremony
summons it with the class glyph.
**Respec (free):** glyph swaps, growth persists — _the witness changes
robes, never self._ Optional flourish: the face renders beside the burst
in the level-up dialog, celebrating.

## 9 · Placement

- **Today:** 28dp face, app bar, left of the level chip — glances, blinks,
  gaze run here; z-motes don't
- **Profile:** 96dp face in the header. Tap = pet · long-press = sheet
- **Today empty state:** the quiescent face at 96dp beside "Your day is
  unwritten." — the empty state is the Keeper's stage, redesigned for free

## 10 · The Keeper sheet

Sharp `tonal` sheet: face at 96dp in current mood · **Journal** (derived):
days kept company (`COUNT(DISTINCT local_date)`) · perfect days witnessed
· goals seen completed · favorite quest (longest current streak) ·
**Growth track** in unlock-track styling · flavor lines:

> It keeps the sealed shelf.
> It has watched {n} perfect days happen.
> It likes {favorite} best.
> It cannot be harmed. It only grows.

Tagline: **"The log remembers; the Keeper reads it."**

## 11 · Implementation map

```
lib/domain/keeper/    classifier.dart · expressions.dart · growth.dart (pure)
lib/app/providers/    keeper_provider.dart (mood/modifier from today providers)
lib/ui/widgets/       keeper_widget.dart (controller + painter, frozen state)
lib/ui/sheets/        keeper_sheet.dart
assets/sounds/        keeper_chirp.ogg · keeper_trill.ogg · keeper_purr.ogg
```

**Fork port list** (the fork's structure survives almost wholesale — this
design is its lineage): eyes + pupils + lids + mouth arcs, bob controller,
z-particle concept, mood-palette structure. Changes: circle eyes → square
blocks · bezier body → nothing (deleted) · hardcoded `Colors.black` →
tokens · `withOpacity` → `withValues(alpha:)` · z `TextPainter` cached,
rising-and-fading · reduced-motion branch · new: expression sheet,
mouth-sync, glance channel, classifier replacement.

## 12 · Tunables (`tunables.dart` — nothing hardcoded)

`bobMs 2400 · bobAmpDp 2.5 · pulseMs 4000 · pulseScale 1.02 ·
blinkMinMs 3000 · blinkMaxMs 7000 · doubleBlinkP 0.10 ·
gazeMinMs 3000 · gazeMaxMs 8000 · gazeAmpU 0.8 ·
glanceTravelMs 300 · glanceHoldMs 500 · dilate 1.4 · pinpoint 0.5 ·
wide 1.12 · pingMs 400 · gildFlashMs 600 · gildHoldMs 4000 ·
mouthPopMs 150 · petWiggleMs 400 ·
growth: 10 / 30 / 100 perfect days · gildLevel 30`

## 13 · Tests (mutation-checked — the suite must FAIL on each)

- Classifier truth table incl. quiescent + **exhaustive no-shame proof**
  (no input combination yields anything but the five moods; there is no
  frown branch to reach — assert the enum's full domain)
- Expression resolver: every mood / modifier / pose → its sheet row
- **Golden matrix = the expression sheet:** all 12 expressions × both
  themes, plus all six glyphs at attentive stage 1 (~30 goldens);
  painter never exceeds S bounds
- Glance: synthetic offset → identical rendered sequence, twice
- Mouth-sync: chirp triggers the mouth-pop state for 150ms
- Growth thresholds flip at exact counts; respec preserves stage
- Reduced motion: static expression asserted
- Pet → haptic purr fired exactly twice, 90ms apart; sounds gated by toggle
- **Mutations to inject:** delete the eye-smile arc draw · remap
  attentive→dormant in the classifier · delete the reduced-motion branch ·
  growth 10→5 · delete the mouth-sync hook

## 14 · Acceptance gates (manual, two minutes each)

1. Complete a quest while watching the app bar → glance at the row, blink
   on return, mouth pops open (sounds on)
2. Perfect Day → 600ms Ember flash + `D` smile held 4s + trill
3. Debug clock past midnight with a pending essential → asleep (closed
   lines), never sad; Profile shows z-motes
4. Empty Today → the quiescent `〜` face beside "Your day is unwritten."
5. Pet on Profile → wiggle + double haptic + ∪∪ + `D`
6. One essential left → wider eyes, quicker pulse — no pointing
7. Reduced motion (OS setting) → fully static, mood expression only
8. Pre-L2 Profile → 20% silhouette that opens its eyes once a quest is
   completed today (no glyph); after the calling ceremony → summoned with glyph
9. Yearly quest completes → surprised face + ring ping

## 15 · Deliverables (protocol)

(1) Paste actual `flutter test` output. (2) State unmet gates explicitly.
(3) Run the five mutations, paste failing output, restore, paste green.
Claims are worthless; outputs are the contract.

---

## v3 · the Kiko totem (in-place upgrade, §1–§15 apply unchanged where silent)

Adopts the Kiko reference (nine emotion states, gaze tracking, boop / tickle /
stroke gestures, thought bubbles) as a **monochrome affect layer on the shared
face** — no fork, no `/kiko` route, same `KeeperWidget`. The day-derived mood
stays the honest five states from §5; the new range is *affect, not blame*:
no plain mood can reach a sad, grumpy, or skeptical face. That is the one
veto-carried interpretation from the Kiko PRD.

### §7 · Emotions (affect, above the §3 sheet)

**Face geometry is the Kiko design** (`assets/msc/code.html`,
`screen.png`): the white-on-OLED companion whose 64px capsule eyes and 64×40
mouth block were transcribed into the painter. Each expression draws its
design SVG exactly — the happy 28×44 capsule (`rx=14`) and flat-topped open
smile, the love heart silhouette and soft smile, the cheeky wink-crescent +
smirk + tongue, the ecstatic filled dome + highlight + wide-open mouth, the
skeptical slanted squint slits + squiggle, the shocked ring-and-core eye +
round `O`, the sad droop triangles + filled frown, the grumpy storm-blob
eyes + notched chevron, the sleepy half-lid + dormant oval. The design's
eye gap matches too: `gap-16` by default, `gap-14` for skeptical / shocked /
grumpy, `gap-20` for sad. Rendered **white-only**: hearts, z's, and highlights
all stay monochrome (no pink/cyan). Two deliberate, user-approved deviations
from the reference: the eye centers sit **8% closer** than the design gap
(`_eyeSpread = 0.92`), and the class sigil rides **0.4u higher** (`cy - 4.4u`,
its halo ring clips ~1px at adorned+). Gaze translates the whole eye capsule and
slides the mouth at half travel (design parallax); the double-blink is the
design's `scaleY(0.08)` squash; the love pose floats white hearts where the
design spawns particles.

**The sheet respects system insets** (`keeper_sheet.dart`): `show()` captures the
status-bar inset before `showModalBottomSheet` strips it from the sheet's
MediaQuery, then a `ConstrainedBox` caps the whole panel to `height - topInset`
so a full journal + growth track never reaches the notification bar; a bottom
`SafeArea` keeps content above gesture/3-button nav bar, with a `16` minimum gap
for legacy nav where the bottom inset is `0`. The root nav bar
(`root_scaffold.dart`) similarly sits in `SafeArea(top: false)`, so with
3-button navigation the bar clears the buttons instead of sliding under them.
Covered by `test/system_insets_test.dart` (root bar + Keeper sheet, injected
padding, 48 bottom / 56 top and zero-inset controls).

Nine surface expressions (`KeeperExpression`: happy, ecstatic, inLove, cheeky,
skeptical, shocked, sad, grumpy, sleepy) resolved pure in
`expressions.dart`: `resolveKeeperExpression({poses, mood})` — transient
`KeeperPose`s win in fixed priority order (grumpy > sad > skeptical > shocked >
cheeky > inLove > ecstatic), otherwise `resting`/`dormant` → sleepy, else happy.
The classifier's domain is untouched (§5 no-shame proof still exhaustive).

| Pose                 | Reached by                                                                                     |
| -------------------- | ---------------------------------------------------------------------------------------------- |
| ecstatic             | Perfect Day (holds gildHold + 1s)                                                             |
| inLove               | stroking past the affection threshold                                                         |
| cheeky               | a rapid tap burst (tickle); grumpy after repeated tickling                                     |
| skeptical            | counter decrement (null cadence); after a hover that lingers without a gesture            |
| shocked              | weekly / monthly / yearly / single completion (replaces the old ping-`o`)                      |
| sad                  | a run of boops (never from a mood) — teases close in, it always recovers                        |
| grumpy               | repeated tickling over the multi-burst window                                                  |
| sleepy               | mood baseline when resting / dormant                                                           |

### §7 · Gestures & gaze (touch + desktop hover)

- **Tap = boop**: recoil dip-and-squash `boopSinkPx`/`boopSquash` + a
  `surpriseWide` eye-widen (`surpriseWide` channel on eyeWide) + `playBoop`.
- **Rapid taps = tickle** (`ticklesRequired` in `tickleWindowMs`): `dizzy`
  wobble channel in `_wobble` + cheeky pose + `playGiggle`; `grumpyTickles`
  bursts in `grumpyWindowMs` → grumpy. A `boopSadCount` run of boops → sad.
- **Drag / hover = stroke**: drags past `kTouchSlop` (touch) and desktop
  hovers (`PointerHoverEvent` via `onPointerHover`) feed a purr-throttled
  `_stroke`; affection accumulates toward inLove (decays slowly).
- **Gaze**: `_gazeTargetPx` eased by `gazeSpringK`, clamped by `gazeFollowU`;
  mouse enter/exit arms/walks the gaze; `skepticalHoverMs` of idle hover
  reads as skeptical.
- **Long-press** on the face opens the Keeper sheet everywhere (replaces the
  old tap-to-pet on screens).

### §7 · Thought bubbles ("Kiko Thinks")

`KeeperThought.pick(expression, index)` rotates line sets per expression
(`KeeperThoughtCarousel`, 7s cadence). Mounted above the face on **Today**
(companion panel, ambient) and in the **Keeper sheet**. The face reports its
live expression via `onExpressionChanged`; parents apply it via a
post-frame `setState` (the callback fires during the child's build).

### §7 · Sound additions (assets keep the curated opt-in toggle)

`keeper_boop.ogg` (0.18s chirp) · `keeper_giggle.ogg` (0.9s triplet) ·
`keeper_sigh.ogg` (1.05s descent). Petting purrs even under reduced motion
(no motion decision — only haptics + sound fire), per §8.

### §11 · Map changes

`expressions.dart` (pure resolver + thought catalog) · `thought_bubble.dart`
(carousel + bubble) in `lib/ui/widgets/` · `sound_service.dart` gains
`playBoop`/`playGiggle`/`playSigh` · gestural chassis (Listener + MouseRegion,
`kTouchSlop`-striped `_stroke`, `_dizzy`/`_recoil`/`_surpriseWide` controllers)
lives in `keeper_widget.dart`.

### §13 · Tests added

- `expressions_test.dart`: pose×mood exhaustive, **no-shame by construction**
  (no plain mood → sad/grumpy), all nine reachable, pose priority, rotation.
- `keeper_render_test.dart`: nine per-expression dark goldens
  (`keeper_expr_*.bin`) + bounds guarantee under pose; blink-squash and
  love-heart-zmote visual gates; gestures group
  (boop recoil, tickle dizzy+cheeky, stroke→inLove, hover gaze follow/settle,
  long-press-not-boop, reduced-motion pet); thought-bubble group (line shown +
  rotation + live-face reporting).
- **New mutations to inject:** delete any one expression's eye-or-mouth branch
  (its golden flips) · force `_blinkY` to 1.0 (blink-squash test dies) ·
  drop the `inLove` branch in `_drawZmote` (love-hearts test dies) · remap
  `sad` before `grumpy` in the resolver (truth table fails) · drop the
  `onPointerHover` registration (hover gaze test dies) · drop the affection
  threshold in `_stroke` (stroke test dies) · delete a `KeeperThought._lines`
  row (bubble test fails).

### §14 · Acceptance gates (added)

10. Tap the Today face three times fast → cheeky + wobble; keep petting →
    heart eyes; hover-over it with a mouse → pupil tracks; rare-cadence
    completion → shocked + ping; 4+ boops → a sigh and a sad face that recovers.
11. Today + sheet show a thought bubble keyed to the face's live expression,
    rotating every ~7s — still strictly white/monochrome. The face is the
    Kiko design: capsule eyes and per-emotion mouths, love pose drifting white
    hearts, gaze parallax and the 0.08 squash blink — all white-on-dark.

---

## todo.md stub

- [x] **P-KEEPER v4 — Kiko-design face (done)** — painter rewritten to the
      `code.html` geometry: 64×64 capsule eyes (`gap-16`/`gap-14`/`gap-20`),
      per-expression design mouths, whole-eye gaze parallax + half-travel
      mouth, `scaleY(0.08)` squash blink, love-pose white heart particles —
      white-on-dark only. Goldens regenerated (render tests 24→26 with
      blink + heart mutation gates), mutation-checked, docs updated. (#waifu)
- [ ] **P-KEEPER v3 — the Kiko totem (in-place)** — nine-expression affect
      layer (resolver + per-expression goldens, no plain mood can go sad) ·
      boop / tickle+dizzy / stroke→inLove / hover-gaze gestures · thought
      bubbles on Today + sheet (rotates, live-keyed) · boop/giggle/sigh
      sounds · reduced-motion pet keeps purring · mutations per §13.
- [ ] **P-KEEPER v2 — the face (~1.5–2 days, post-queue or parallel)** —
      two big pixel eyes (3.2×4u blocks, sliding pupils, lids) + five
      mouth shapes · 12-expression sheet (= golden matrix) · mouth-sync ·
      glance plumbing (dx,dy from rows) · class glyph · growth
      10/30/100/L30 (golden face) · petting + haptic purr · 3 opt-in
      sounds · Keeper sheet w/ derived journal · quiescent empty-state
      face · no-shame proof + 5 mutations
