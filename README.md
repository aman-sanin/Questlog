# QUESTLOG

> **Your quests. Your cadence. No accounts.**

QUESTLOG is a habit/quest tracker built on a local-first, privacy-respecting architecture. The app requires **no internet permission**, ensuring your personal behavior data never leaves your device. 

---

## ✦ Core Philosophy — Sacred Progress
Information is treated as a rare commodity. The user authors only completions. Everything else—today's list, streaks, levels, badges, and XP—is dynamically derived from those completions and schedule rules at read time. 

BONUS points and milestone grants are materialized into an append-only ledger during an idempotent foreground **settlement** convergence run.

---

## 🛠️ Tech Stack
* **Platform**: Android Only (Offline-first, `allowBackup = true`).
* **Framework**: Flutter
* **State Management**: [Riverpod](https://riverpod.dev)
* **Local Persistence**: [Drift](https://drift.simonbinder.eu) (SQLite ORM)
* **Routing**: [go_router](https://pub.dev/packages/go_router)
* **Clock**: Injected via [clock](https://pub.dev/packages/clock) for 100% deterministic time-travel testing.

---

## 🎨 Design System ("Onyx & Ivory")
Neo-brutalist constraints (hard edges, 1dp hairline borders, zero shadows/gradients). 
* **Onyx (Dark Mode)**: Pure `#000000` background.
* **Ivory (Light Mode)**: Soft `#FAF7F2` warm paper background.
* **Frost (Motion)**: Swappable accent color (Frost, Sage, Ice, Copper) indicating metric progression.
* **Ember (Arrival)**: Hero gold indicating quest completion, milestone achievements, and ceremonies.
* **Muted Red (Failure)**: Quietly displays missed essential quests.

---

## 📂 Project Structure

```
lib/
  main.dart / app.dart / bootstrap.dart        (Initialization & routing)
  data/
    db/          (Drift database, tables, converters)
    dao/         (Data Access Objects)
    backup/      (JSON Import/Export backup utilities)
  domain/        (Pure Dart logic - no Flutter framework imports)
    engine/      (Recurrence, QuestState, Streak, XP, Settlement, Badges)
    model/       (Value types, LocalDate, DateRange)
    constants/   (Tunables and constants)
  app/
    providers/   (Riverpod providers)
    write/       (Transactional complete/undo use cases)
    services/    (Rollover, notifications, widget bridge, haptics)
  ui/
    theme/       (App theme, colors, typography, crest sigils)
    screens/     (Today, Insights, Profile, Recap, Ceremonies)
    widgets/     (QuestRow, CheckboxRing, Stepper, SigilWidget)
```

---

## ⚡ Development & Commands

### 1. Code Generation
Drift uses build generators. If you modify database tables in `lib/data/db/tables.dart`, regenerate files using:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 2. Running Unit Tests
Verify all recurrence rules and walking algorithms:
```bash
flutter test test/recurrence_test.dart
```

---

## 🔒 Privacy & Security
QuestLog is fully self-contained. The Android manifest declares **no internet access permissions**, rendering the app physically incapable of sending metrics, diagnostics, or tracking data anywhere.
