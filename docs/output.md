# QuestLog: User Features & Sheet Inventory

This document details all user-facing functions, sheets, screens, and interactive capabilities available in QuestLog.

---

## 1. Sheets & Modal Dialogs

### `QuestEditorSheet` (Author & Edit Quest)
- **Primary Trigger**: Tap the bottom navigation Rune (`+`) button or tap any existing quest row to edit.
- **Functions Available to User**:
  - **Quest Title**: Input and edit the quest title.
  - **Cadence Selection**: Switch between **Daily**, **Weekly**, **Monthly**, and **Yearly** cadences.
    - *Cadence Streak Guardrail*: Changing the cadence of an active quest prompts a confirmation warning explaining that the streak will reset.
  - **Daily Schedule Sub-options**: Choose between **Every Day** or specific **Weekdays** (interactive Monday–Sunday toggles).
  - **Weekly Schedule Sub-options**: Configure target times per week (1× to 7× per week).
  - **Calling Domain Alignment**: Tag the quest with one of the 6 RPG Calling Domains (**Warrior**, **Sage**, **Monk**, **Bard**, **Ranger**, **Artificer**).
  - **Difficulty Setting**: Select **Easy** (1.0× XP), **Medium** (1.5× XP), or **Hard** (2.0× XP).
  - **Essential Toggle**: Designate a quest as an **Essential Daily Quest** (required for Perfect Day bonuses).
    - *Essential Load Guardrail*: Adding a 6th essential triggers a reminder alerting the user to potential daily overload.
  - **Archive Quest**: Safely archive an existing quest without deleting historical completions or XP ledger records.

---

### `GoalEditorSheet` (Author & Edit Goal)
- **Primary Trigger**: Tap the author goal button or edit action within goal headers.
- **Functions Available to User**:
  - **Goal Title & Description**: Set overarching life or habit goals.
  - **Emoji Icon Picker**: Assign a signature emoji to visually categorize the goal.
  - **Archive Goal**: Archive the goal when completed or retired.

---

### `GoalDetailSheet` (Goal Overview & Attached Quests)
- **Primary Trigger**: Tap any goal section header on the Today screen.
- **Functions Available to User**:
  - **Progress Ring**: View visual completion percentage for quests attached to this goal.
  - **Quest List**: Inspect all attached quests, their individual streak counts, and period completion statuses.
  - **Goal Quick Actions**: Edit the goal details or archive the goal.

---

### `DaySheet` (Historical Day Inspector)
- **Primary Trigger**: Tap any square on the 35-day Monthly Heatmap grid in the Insights tab.
- **Functions Available to User**:
  - **Day Summary**: View exact date, completion count, and target count for that specific day.
  - **Status Indicators**: See whether the day was **Perfect**, **Normal**, **Saved by Freeze (❄)**, or **Missed**.
  - **Quest Audit**: Inspect which specific quests were completed on that day.

---

### `BadgeSheet` (Unlocks & Milestone Inspector)
- **Primary Trigger**: Tap any milestone icon or level unlock swatch on the Profile screen.
- **Functions Available to User**:
  - **Unlock Detail**: View name, level requirement, and description of cosmetic rewards (e.g., *Sage Accent* at L3, *Ice Accent* at L5, *Copper Accent* at L13).
  - **Status**: Inspect whether the reward is currently unlocked or locked behind a future level.

---

### `CallingSelectionSheet` (Calling Selection Ceremony)
- **Primary Trigger**: Automatically presented upon reaching **Level 2**.
- **Functions Available to User**:
  - **Domain Exploration**: Browse the 6 Calling Domains with their descriptions and sigils:
    - ⚔️ **Warrior**: Discipline, physical mastery, strength.
    - 📜 **Sage**: Knowledge, intellect, study, research.
    - 🧘 **Monk**: Mindfulness, inner balance, meditation.
    - 🎭 **Bard**: Creativity, expression, community, art.
    - 🏹 **Ranger**: Adventure, exploration, outdoors, habit navigation.
    - ⚒️ **Artificer**: Craftsmanship, building, code, engineering.
  - **Affirm Calling**: Confirm chosen calling to unlock domain title progressions.

---

### `LevelUpCeremonyDialog` (Level-Up Celebration)
- **Primary Trigger**: Automatically fires when cumulative XP crosses a level threshold.
- **Functions Available to User**:
  - **Celebration Display**: Displays newly achieved level, updated calling title, and unlocked cosmetics/milestones.
  - **Dismiss**: Single tap to close and resume questing.

---

## 2. Core User Screens & Features

### 🌟 Today Screen (`/today`)
- **Daily Progress Bar**: Live visual meter showing completed vs. total scheduled quests for the day.
- **Perfect Day Banner**: Celebratory indicator when all essential daily quests are completed (+15 XP).
- **Interactive Quest Rows**:
  - **Checkbox Tap**: Instant 1-tap completion with haptic feedback and sound.
  - **Stepper Tap**: Multi-unit completion increment (`+` / `-`) for quantitative quests.
  - **Visual States**: Distinct styling for Pending, Completed, Overachieved, At-Risk (past 18:00), Paused, and Streak-Saved (`STREAK SAVED · ❄`).
  - **5-Second Undo Grace**: Undo snackbar appears immediately after completion to revert accidental taps with exact XP restoration.
- **Goal Groupings**: Quests organized under their respective goals with mini completion rings.
- **Streak Freeze Indicator**: Displays active streak freeze wallet capacity ($0 / 2$) and freeze rescue status.

---

### 📊 Insights Screen (`/insights`)
- **Deterministic Rotating Insight Card**:
  - **Weekday Momentum**: Compares weekday vs. weekend consistency percentages.
  - **Consistency Score**: Highlights 7-day adherence rhythm.
  - **Tempo & XP Gain**: Tracks cumulative XP accumulation rate.
- **Coach Recommendation Cards**:
  - **Mastery in Motion**: Triggered when 14-day completion is $>90\%$ to suggest difficulty upgrades.
  - **Focus Your Energy**: Triggered when completion is $<50\%$ with high quest count to suggest pausing or switching to weekly windows.
  - **Welcome Back**: Triggered when returning after 14+ days away.
- **Monthly Heatmap Grid**: 35-day interactive completion matrix with color-coded intensity levels.
- **Domain Affinity Bar**: Percentage breakdown of XP earned across Warrior, Sage, Monk, Bard, Ranger, and Artificer quests.
- **Monthly Recap Access**: Card leading into the full monthly review.

---

### 📅 Monthly Recap Screen (`/recap`)
- **Month-over-Month Trends**: Overall completion rate comparison against the previous month.
- **Key Metrics**: Total XP earned, Perfect Days count, and Freezes saved.
- **Highlights**: Most active Calling Domain and most completed quest of the month.

---

### 👤 Profile Screen (`/profile`)
- **Identity & Name Editing**: Edit adventurer name.
- **Progression Overview**: Current level rung, total lifetime XP, and progress bar to next level.
- **Title Band**: Dynamic title based on level and chosen Calling (e.g., *Recruit* $\rightarrow$ *Knight* $\rightarrow$ *Legendary Warlord*).
- **Milestone & Unlock Grid**: Visual badges for level milestones ($L_3, L_5, L_{13}$, etc.).
- **Lifetime Statistics**: Longest streak achieved and total completions logged.
- **Settings Gear**: Quick entry to application settings.

---

### ⚙️ Settings Screen (`/settings`)
- **Appearance Mode**:
  - **Onyx (Dark)**: Deep pure dark mode.
  - **System**: Automatically matches device theme.
  - **Ivory (Light)**: Warm paper light mode.
- **Motion Accent Palette**:
  - **Frost** (Default neutral gold).
  - **Sage** (Unlocks at Level 3).
  - **Ice** (Unlocks at Level 5).
  - **Copper** (Unlocks at Level 13).
- **Cadence & Day Boundaries**:
  - **Midnight (00:00)**: Day rolls over at standard midnight.
  - **Late Night (04:00 AM)**: Night owl mode where the day rolls over 4 hours after midnight.
- **Week Start**: Toggle between **Monday** and **Sunday** as the start of the week.
- **Data & Privacy**:
  - **Export Backup**: Exports all quests, history, XP events, and settings into a `.json` file attachment via the native share sheet.
  - **Import Backup**: Restores log data from any QuestLog `.json` backup file via the native file picker with atomic transactional safety.
- **Debug Entry**: Discreet entry into the Time Machine & Data Inspector.

---

### 🧪 Debug Inspector Screen (`/debug`)
- **Debug Time Travel**:
  - Jump `+1 Day`, `+7 Days`, `+30 Days`, or pick an exact simulated date.
  - Instantly test rollover, freeze consumption, and weekly settlement.
  - Reset back to real device time with 1 tap.
- **Force Settlement Trigger**: Manually execute settlement engine across closed periods.
- **Live Ledger Tail**: Real-time log viewer displaying recent XP events and streak repair transactions.

---

## 3. Background & System Integrations

- **Local Notifications**:
  - **Daily Digest**: Morning notification summarizing scheduled quests.
  - **Per-Quest Reminders**: Notification at custom reminder minutes (e.g. 08:30 AM).
  - **Boot Re-Arming**: Restores alarms automatically upon device reboot.
  - **Deep Linking**: Tapping any notification opens the app directly to `questlog://today`.
- **Home Screen Widget (`HomeWidget`)**:
  - Live home screen widget snapshot displaying essential quests, remaining due count, and streak count.
  - Automatic updates on quest completion, settlement, and day rollover.
- **Lifecycle Invalidation**:
  - Automatically checks and rolls over dates when the app is resumed from background.
