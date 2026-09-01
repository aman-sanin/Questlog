# QUESTLOG

> **Your quests. Your cadence. No accounts.**

QUESTLOG is a habit/quest tracker built on a local-first, privacy-respecting architecture. The app requires **no internet permission**, ensuring your personal behavior data never leaves your device.

---

## ✦ Core Philosophy — Sacred Progress
Information is treated as a rare commodity. The user authors only completions. Everything else—today's list, streaks, levels, badges, insights, and XP—is dynamically derived from those completions and schedule rules at read time.

BONUS points and milestone grants are materialized into an append-only ledger during an idempotent foreground **settlement** convergence run.

---

## ⚔️ Key Features

- **Trigger-Action Coach Engine (P12b)**: 10 deterministic detectors (Mastery, Right-size, Stale, Zombie, Essential Stumble, Milestone Near, Perfect Week Near, Backup Nudge, Load Triage, Welcome Back) with gain-framed personalized advice and exponential KV cooldown backoff ($30 \to 60 \to 90$ days).
- **50-Badge Achievement Registry**: Complete 50-badge system across 8 categories (*Journey*, *Streaks*, *Perfection*, *Goals*, *Economy*, *Rarities*, *Calling*, *Sealed*) with secrecy dialogs and Calling trials.
- **Calling System & The Path**: Choose from 6 domains (*Warrior*, *Sage*, *Monk*, *Bard*, *Ranger*, *Artificer*) with domain crest sigils, leveling ladder ranks, and XP curves.
- **Flexible Cadences**: Support for Daily, Weekly, Monthly, Yearly, and **Single (Non-Repeating)** quests with target dates and counter/checkbox scoring modes.
- **First-Launch Onboarding**: 3-step setup wizard with Adventurer Name oath and starter quest suggestions.
- **Tactile Audio & Haptics**: Persistent sound effects toggle and haptic feedback on completions, checkoffs, and ceremonies.
- **Quest Packs & Backup**: Export/Import encrypted or raw JSON backups and standalone shareable Quest Packs.

---

## 🛠️ Tech Stack
* **Platform**: Android Only (Offline-first, `allowBackup = true`).
* **Framework**: Flutter
* **State Management**: [Riverpod](https://riverpod.dev)
* **Local Persistence**: [Drift](https://drift.simonbinder.eu) (SQLite ORM)
* **Routing**: [go_router](https://pub.dev/packages/go_router)
* **Clock**: Injected for 100% deterministic time-travel and settlement testing.

---

## 🎨 Design System ("Onyx & Ivory")
Neo-brutalist constraints (hard edges, 1dp hairline borders, zero shadows/gradients).
* **Onyx (Dark Mode)**: Pure `#000000` background.
* **Ivory (Light Mode)**: Soft `#FAF7F2` warm paper background.
* **Frost (Motion)**: Swappable accent color (Frost, Sage, Ice, Copper, Ember) indicating metric progression.
* **Ember (Arrival)**: Hero gold indicating quest completion, milestone achievements, and ceremonies.
* **Muted Red (Failure)**: Quietly displays missed essential quests.

---

## 📂 Project Structure

```
lib/
  main.dart / app.dart / bootstrap.dart        (Initialization & routing)
  data/
    db/          (Drift database, tables, converters)
    dao/         (Data Access Objects: Quests, Completions, Ledger, Profile, Goals)
    backup/      (JSON Import/Export backup utilities)
    packs/       (Quest pack import/export service)
  domain/        (Pure Dart logic - no Flutter framework imports)
    engine/      (Recurrence, QuestState, Streak, XP, Settlement, Badges, Coach, Insights)
    model/       (Value types, LocalDate, DateRange, Cadence, CallingDomain)
    constants/   (Tunables, XP Constants, Unlock Schedule, Titles)
  app/
    providers/   (Riverpod providers for UI and business logic)
    write/       (Transactional complete/undo, profile, quest, and goal actions)
    services/    (Rollover, notifications, widget bridge, haptics, sound)
  ui/
    theme/       (App theme, tokens, typography, crest sigils)
    screens/     (Today, Insights, Profile, Badges, Settings, Onboarding, Recap, Ceremonies)
    sheets/      (Quest Editor, Goal Editor, Triage Sheet, Badge Sheet, Day Sheet)
    widgets/     (CoachCard, QuestRow, CheckboxRing, Stepper, SigilWidget, HeatmapGrid)
```

---

## ⚡ Development & Commands

### 1. Running Tests
Run the complete automated test suite (pure engine, mutation checks, and widget flows):
```bash
flutter test
```

### 2. Code Generation
If you modify database tables in `lib/data/db/tables.dart`, regenerate files using:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 🔒 Privacy & Security
QuestLog is fully self-contained. The Android manifest declares **no internet access permissions**, rendering the app physically incapable of sending metrics, diagnostics, or tracking data anywhere.
