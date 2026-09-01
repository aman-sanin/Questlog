import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/db/database.dart';
import '../model/models.dart';

enum BadgeCategory {
  journey,
  streaks,
  perfection,
  goals,
  economy,
  rarities,
  calling,
  sealed,
}

enum ProgressKind {
  cumulative,
  peak,
  event,
}

class BadgeDefinition {
  final String key;
  final String title;
  final BadgeCategory category;
  final IconData icon;
  final String flavor;
  final String requirement;
  final ProgressKind progressKind;
  final int targetValue;
  final bool sealed;
  final CallingDomain? domain;

  const BadgeDefinition({
    required this.key,
    required this.title,
    required this.category,
    required this.icon,
    required this.flavor,
    required this.requirement,
    required this.progressKind,
    this.targetValue = 1,
    this.sealed = false,
    this.domain,
  });
}

class BadgeStatus {
  final BadgeDefinition definition;
  final bool isEarned;
  final int currentValue;
  final String? earnedDate;
  final bool isEligible;

  const BadgeStatus({
    required this.definition,
    required this.isEarned,
    this.currentValue = 0,
    this.earnedDate,
    this.isEligible = true,
  });

  double get progressRatio {
    if (definition.targetValue <= 0) return isEarned ? 1.0 : 0.0;
    return (currentValue / definition.targetValue).clamp(0.0, 1.0);
  }
}

class BadgeEngine {
  static const List<BadgeDefinition> catalog = [
    // ── 1. JOURNEY (6) ────────────────────────────────────────────────────────
    BadgeDefinition(
      key: 'first_step',
      title: 'First Step',
      category: BadgeCategory.journey,
      icon: Symbols.directions_walk,
      flavor: 'The log begins.',
      requirement: 'Complete your first quest.',
      progressKind: ProgressKind.cumulative,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'tenfold',
      title: 'Tenfold',
      category: BadgeCategory.journey,
      icon: Symbols.filter_9_plus,
      flavor: 'Ten entries in the book.',
      requirement: 'Complete 10 total quests.',
      progressKind: ProgressKind.cumulative,
      targetValue: 10,
    ),
    BadgeDefinition(
      key: 'half_century',
      title: 'Half-Century',
      category: BadgeCategory.journey,
      icon: Symbols.timeline,
      flavor: 'Fifty acts, recorded.',
      requirement: 'Complete 50 total quests.',
      progressKind: ProgressKind.cumulative,
      targetValue: 50,
    ),
    BadgeDefinition(
      key: 'century',
      title: 'Century',
      category: BadgeCategory.journey,
      icon: Symbols.workspace_premium,
      flavor: 'A hundred proofs of showing up.',
      requirement: 'Complete 100 total quests.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'millennial',
      title: 'Millennial',
      category: BadgeCategory.journey,
      icon: Symbols.emoji_events,
      flavor: 'The log outgrew its shelf.',
      requirement: 'Complete 1,000 total quests.',
      progressKind: ProgressKind.cumulative,
      targetValue: 1000,
    ),
    BadgeDefinition(
      key: 'long_log',
      title: 'The Long Log',
      category: BadgeCategory.journey,
      icon: Symbols.history_edu,
      flavor: 'A life, kept in entries.',
      requirement: 'Complete 5,000 total quests.',
      progressKind: ProgressKind.cumulative,
      targetValue: 5000,
    ),

    // ── 2. STREAKS (7) ────────────────────────────────────────────────────────
    BadgeDefinition(
      key: 'weeks_worth',
      title: "A Week's Worth",
      category: BadgeCategory.streaks,
      icon: Symbols.local_fire_department,
      flavor: 'Seven in a row.',
      requirement: 'Reach a streak of 7 periods on any quest.',
      progressKind: ProgressKind.peak,
      targetValue: 7,
    ),
    BadgeDefinition(
      key: 'month_iron',
      title: 'Month of Iron',
      category: BadgeCategory.streaks,
      icon: Symbols.fort,
      flavor: 'Thirty periods, unbroken.',
      requirement: 'Reach a streak of 30 periods on any quest.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'streak_centurion',
      title: 'Centurion',
      category: BadgeCategory.streaks,
      icon: Symbols.military_tech,
      flavor: 'One hundred periods deep.',
      requirement: 'Reach a streak of 100 periods on any quest.',
      progressKind: ProgressKind.peak,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'long_year',
      title: 'The Long Year',
      category: BadgeCategory.streaks,
      icon: Symbols.event_available,
      flavor: 'A year without a miss.',
      requirement: 'Reach a streak of 365 periods on any quest.',
      progressKind: ProgressKind.peak,
      targetValue: 365,
    ),
    BadgeDefinition(
      key: 'thirty_weeks',
      title: 'Thirty Weeks',
      category: BadgeCategory.streaks,
      icon: Symbols.date_range,
      flavor: 'Thirty faithful weeks.',
      requirement: 'Reach a 30-week streak on any weekly quest.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'dozen_moons',
      title: 'A Dozen Moons',
      category: BadgeCategory.streaks,
      icon: Symbols.dark_mode,
      flavor: 'Twelve moons honored.',
      requirement: 'Reach a 12-month streak on any monthly quest.',
      progressKind: ProgressKind.peak,
      targetValue: 12,
    ),
    BadgeDefinition(
      key: 'three_ages',
      title: 'Three Ages',
      category: BadgeCategory.streaks,
      icon: Symbols.hourglass_top,
      flavor: 'Three annual returns.',
      requirement: 'Reach a 3-year streak on any yearly quest.',
      progressKind: ProgressKind.peak,
      targetValue: 3,
    ),

    // ── 3. PERFECTION (6) ─────────────────────────────────────────────────────
    BadgeDefinition(
      key: 'perfect_ten',
      title: 'Perfect Ten',
      category: BadgeCategory.perfection,
      icon: Symbols.auto_awesome,
      flavor: 'Ten days without a miss.',
      requirement: 'Achieve 10 Perfect Days.',
      progressKind: ProgressKind.cumulative,
      targetValue: 10,
    ),
    BadgeDefinition(
      key: 'fifty_flawless',
      title: 'Fifty Flawless',
      category: BadgeCategory.perfection,
      icon: Symbols.verified,
      flavor: 'Fifty clean pages.',
      requirement: 'Achieve 50 Perfect Days.',
      progressKind: ProgressKind.cumulative,
      targetValue: 50,
    ),
    BadgeDefinition(
      key: 'perfect_hundred',
      title: 'Perfect Hundred',
      category: BadgeCategory.perfection,
      icon: Symbols.diamond,
      flavor: 'A hundred flawless entries.',
      requirement: 'Achieve 100 Perfect Days.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'first_perfect_week',
      title: 'First Perfect Week',
      category: BadgeCategory.perfection,
      icon: Symbols.check_circle,
      flavor: 'One whole week, kept.',
      requirement: 'Achieve 1 Perfect Week.',
      progressKind: ProgressKind.cumulative,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'flawless_fortnight',
      title: 'Flawless Fortnight',
      category: BadgeCategory.perfection,
      icon: Symbols.done_all,
      flavor: 'Fourteen days, no asterisks.',
      requirement: 'Achieve 14 consecutive Perfect Days.',
      progressKind: ProgressKind.peak,
      targetValue: 14,
    ),
    BadgeDefinition(
      key: 'perfect_month',
      title: 'The Perfect Month',
      category: BadgeCategory.perfection,
      icon: Symbols.calendar_view_month,
      flavor: 'A month without a blemish.',
      requirement: 'Every eligible day of a calendar month perfect (≥20 eligible days).',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),

    // ── 4. GOALS (3) ──────────────────────────────────────────────────────────
    BadgeDefinition(
      key: 'goal_getter',
      title: 'Goal Getter',
      category: BadgeCategory.goals,
      icon: Symbols.flag,
      flavor: 'First chapter closed.',
      requirement: 'Complete 1 overarching goal.',
      progressKind: ProgressKind.cumulative,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'polymath',
      title: 'Polymath',
      category: BadgeCategory.goals,
      icon: Symbols.psychology,
      flavor: 'Five chapters closed.',
      requirement: 'Complete 5 overarching goals.',
      progressKind: ProgressKind.cumulative,
      targetValue: 5,
    ),
    BadgeDefinition(
      key: 'decathlon',
      title: 'Decathlon',
      category: BadgeCategory.goals,
      icon: Symbols.sports_score,
      flavor: 'A shelf of finished things.',
      requirement: 'Complete 10 overarching goals.',
      progressKind: ProgressKind.cumulative,
      targetValue: 10,
    ),

    // ── 5. ECONOMY (3) ────────────────────────────────────────────────────────
    BadgeDefinition(
      key: 'first_freeze',
      title: 'First Freeze',
      category: BadgeCategory.economy,
      icon: Symbols.ac_unit,
      flavor: 'You banked your first mercy.',
      requirement: 'Bank at least 1 streak freeze from a Perfect Week.',
      progressKind: ProgressKind.cumulative,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'full_pantry',
      title: 'Full Pantry',
      category: BadgeCategory.economy,
      icon: Symbols.inventory_2,
      flavor: 'Two mercies in reserve.',
      requirement: 'Hold 2 streak freezes in your wallet at once.',
      progressKind: ProgressKind.peak,
      targetValue: 2,
    ),
    BadgeDefinition(
      key: 'grace_thrice',
      title: 'Grace Thrice',
      category: BadgeCategory.economy,
      icon: Symbols.volunteer_activism,
      flavor: 'Rescued, and rescued again.',
      requirement: 'Use 3 streak freezes to preserve streaks.',
      progressKind: ProgressKind.cumulative,
      targetValue: 3,
    ),

    // ── 6. RARITIES (6) ───────────────────────────────────────────────────────
    BadgeDefinition(
      key: 'new_years_quest',
      title: "New Year's Quest",
      category: BadgeCategory.rarities,
      icon: Symbols.celebration,
      flavor: 'The year began with a quest.',
      requirement: 'Complete a quest on January 1st.',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'midwinter',
      title: 'Midwinter',
      category: BadgeCategory.rarities,
      icon: Symbols.severe_cold,
      flavor: 'The longest night, kept.',
      requirement: 'Complete a quest on December 21st (Winter Solstice).',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'midsummer',
      title: 'Midsummer',
      category: BadgeCategory.rarities,
      icon: Symbols.wb_sunny,
      flavor: 'The longest day, honored.',
      requirement: 'Complete a quest on June 21st (Summer Solstice).',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'leap_day',
      title: 'Leap Day',
      category: BadgeCategory.rarities,
      icon: Symbols.event,
      flavor: 'Four years in the making.',
      requirement: 'Complete a quest on February 29th.',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'year_one',
      title: 'Year One',
      category: BadgeCategory.rarities,
      icon: Symbols.cake,
      flavor: 'One year on the trail.',
      requirement: 'Log a completion at least 365 days after your very first.',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'unbroken_year',
      title: 'The Unbroken Year',
      category: BadgeCategory.rarities,
      icon: Symbols.all_inclusive,
      flavor: 'Every single day, written.',
      requirement: 'Complete at least 1 quest every day for 365 consecutive days.',
      progressKind: ProgressKind.peak,
      targetValue: 365,
    ),

    // ── 7. CALLING — 12 TRIALS (2 per domain) ────────────────────────────────
    BadgeDefinition(
      key: 'trial_iron_will',
      title: 'Iron Will',
      category: BadgeCategory.calling,
      icon: Symbols.fitness_center,
      domain: CallingDomain.warrior,
      flavor: 'The body keeps its word.',
      requirement: 'Reach a 30-period streak on a Warrior quest while pledged to the Warrior.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'trial_hundred_battles',
      title: 'Hundred Battles',
      category: BadgeCategory.calling,
      icon: Symbols.shield,
      domain: CallingDomain.warrior,
      flavor: 'A hundred battles logged.',
      requirement: 'Complete 100 Warrior quests while pledged to the Warrior.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'trial_unbroken_focus',
      title: 'Unbroken Focus',
      category: BadgeCategory.calling,
      icon: Symbols.menu_book,
      domain: CallingDomain.sage,
      flavor: 'The mind holds the line.',
      requirement: 'Reach a 30-period streak on a Sage quest while pledged to the Sage.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'trial_the_archive',
      title: 'The Archive',
      category: BadgeCategory.calling,
      icon: Symbols.auto_stories,
      domain: CallingDomain.sage,
      flavor: 'The archive grows heavy.',
      requirement: 'Complete 100 Sage quests while pledged to the Sage.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'trial_still_water',
      title: 'Still Water',
      category: BadgeCategory.calling,
      icon: Symbols.self_improvement,
      domain: CallingDomain.monk,
      flavor: 'The surface does not ripple.',
      requirement: 'Reach a 30-period streak on a Monk quest while pledged to the Monk.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'trial_the_practice',
      title: 'The Practice',
      category: BadgeCategory.calling,
      icon: Symbols.air,
      domain: CallingDomain.monk,
      flavor: 'Breath, after breath.',
      requirement: 'Complete 100 Monk quests while pledged to the Monk.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'trial_long_refrain',
      title: 'The Long Refrain',
      category: BadgeCategory.calling,
      icon: Symbols.music_note,
      domain: CallingDomain.bard,
      flavor: 'The song refuses to end.',
      requirement: 'Reach a 30-period streak on a Bard quest while pledged to the Bard.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'trial_the_repertoire',
      title: 'The Repertoire',
      category: BadgeCategory.calling,
      icon: Symbols.theater_comedy,
      domain: CallingDomain.bard,
      flavor: 'Every stage, played.',
      requirement: 'Complete 100 Bard quests while pledged to the Bard.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'trial_long_trail',
      title: 'The Long Trail',
      category: BadgeCategory.calling,
      icon: Symbols.hiking,
      domain: CallingDomain.ranger,
      flavor: 'The trail goes ever on.',
      requirement: 'Reach a 30-period streak on a Ranger quest while pledged to the Ranger.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'trial_cartographer',
      title: 'The Cartographer',
      category: BadgeCategory.calling,
      icon: Symbols.explore,
      domain: CallingDomain.ranger,
      flavor: 'The map fills in.',
      requirement: 'Complete 100 Ranger quests while pledged to the Ranger.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'trial_steady_hands',
      title: 'Steady Hands',
      category: BadgeCategory.calling,
      icon: Symbols.handyman,
      domain: CallingDomain.artificer,
      flavor: 'The hands do not shake.',
      requirement: 'Reach a 30-period streak on an Artificer quest while pledged to the Artificer.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'trial_masterwork',
      title: 'Masterwork',
      category: BadgeCategory.calling,
      icon: Symbols.construction,
      domain: CallingDomain.artificer,
      flavor: 'Built, and built again.',
      requirement: 'Complete 100 Artificer quests while pledged to the Artificer.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),

    // ── 8. SEALED (7) ─────────────────────────────────────────────────────────
    BadgeDefinition(
      key: 'night_owl',
      title: 'Night Owl',
      category: BadgeCategory.sealed,
      icon: Symbols.bedtime,
      flavor: 'Logged while the world slept.',
      requirement: 'Log a completion between midnight and 05:00.',
      progressKind: ProgressKind.event,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'dawnbreaker',
      title: 'Dawnbreaker',
      category: BadgeCategory.sealed,
      icon: Symbols.wb_twilight,
      flavor: 'Finished before the sun.',
      requirement: 'Log a completion before 07:00 in the morning.',
      progressKind: ProgressKind.event,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'historian',
      title: 'The Historian',
      category: BadgeCategory.sealed,
      icon: Symbols.history,
      flavor: 'The past, honestly kept.',
      requirement: 'Log 25 backfilled completions.',
      progressKind: ProgressKind.cumulative,
      targetValue: 25,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'scribe',
      title: 'The Scribe',
      category: BadgeCategory.sealed,
      icon: Symbols.edit_note,
      flavor: 'Fifty entries with words attached.',
      requirement: 'Attach notes to 50 quest completions.',
      progressKind: ProgressKind.cumulative,
      targetValue: 50,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'perfectionist',
      title: 'Perfectionist',
      category: BadgeCategory.sealed,
      icon: Symbols.grade,
      flavor: 'Flawless, and it stayed flawless.',
      requirement: 'Achieve 14 consecutive Perfect Days.',
      progressKind: ProgressKind.peak,
      targetValue: 14,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'curator',
      title: 'The Curator',
      category: BadgeCategory.sealed,
      icon: Symbols.museum,
      flavor: 'Kept what mattered, retired the rest.',
      requirement: 'Archive 5 quests that had reached at least 90% completion.',
      progressKind: ProgressKind.cumulative,
      targetValue: 5,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'marathon_day',
      title: 'Marathon Day',
      category: BadgeCategory.sealed,
      icon: Symbols.directions_run,
      flavor: 'One very full page.',
      requirement: 'Log 12 or more completions on a single calendar day.',
      progressKind: ProgressKind.peak,
      targetValue: 12,
      sealed: true,
    ),
  ];

  /// Pure deterministic evaluation of all 50 badges based on the SQLite logbook state.
  static List<BadgeStatus> evaluate({
    required List<CompletionData> completions,
    required List<QuestData> quests,
    required List<GoalData> goals,
    required List<XpEventData> xpEvents,
    required List<StreakRepairData> streakRepairs,
    required ProfileData profile,
    required Map<String, int> questMaxStreaks,
    required Set<LocalDate> perfectDays,
    required Set<String> seenBadgeKeys,
  }) {
    final questMap = {for (final q in quests) q.id: q};
    final userCalling = profile.calling != null ? CallingDomain.values[profile.calling!] : null;

    // ── Pre-calculations ────────────────────────────────────────────────────
    final totalCompletionsCount = completions.fold<int>(0, (sum, c) => sum + c.value);

    // Max streak across all quests
    int maxAnyStreak = 0;
    int maxWeeklyStreak = 0;
    int maxMonthlyStreak = 0;
    int maxYearlyStreak = 0;
    final maxStreakByDomain = <CallingDomain, int>{};

    for (final entry in questMaxStreaks.entries) {
      final q = questMap[entry.key];
      final s = entry.value;
      if (s > maxAnyStreak) maxAnyStreak = s;

      if (q != null) {
        if (q.rule.cadence == Cadence.weekly && s > maxWeeklyStreak) maxWeeklyStreak = s;
        if (q.rule.cadence == Cadence.monthly && s > maxMonthlyStreak) maxMonthlyStreak = s;
        if (q.rule.cadence == Cadence.yearly && s > maxYearlyStreak) maxYearlyStreak = s;

        if (q.domain != null) {
          final d = CallingDomain.values[q.domain!];
          if (s > (maxStreakByDomain[d] ?? 0)) {
            maxStreakByDomain[d] = s;
          }
        }
      }
    }

    // Domain completions count
    final domainCompletionsCount = <CallingDomain, int>{};
    for (final c in completions) {
      final q = questMap[c.questId];
      if (q != null && q.domain != null) {
        final d = CallingDomain.values[q.domain!];
        domainCompletionsCount[d] = (domainCompletionsCount[d] ?? 0) + c.value;
      }
    }

    // Goals completed
    final completedGoalsCount = goals.where((g) => g.completedAt != null).length;

    // Perfect days count & longest consecutive run
    final perfectDaysList = perfectDays.toList()..sort();
    final perfectDaysCount = perfectDaysList.length;

    int maxConsecutivePerfectDays = 0;
    if (perfectDaysList.isNotEmpty) {
      int currentRun = 1;
      maxConsecutivePerfectDays = 1;
      for (int i = 1; i < perfectDaysList.length; i++) {
        final prev = perfectDaysList[i - 1];
        final curr = perfectDaysList[i];
        if (curr.differenceInDays(prev) == 1) {
          currentRun++;
          if (currentRun > maxConsecutivePerfectDays) {
            maxConsecutivePerfectDays = currentRun;
          }
        } else {
          currentRun = 1;
        }
      }
    }

    // Perfect weeks from ledger
    final perfectWeeksCount = xpEvents.where((e) => e.type == 2).length;

    // Perfect calendar month check (every eligible day in a month perfect, with >= 20 eligible days)
    bool hasPerfectMonth = false;
    final perfectDaysByMonth = <String, Set<int>>{};
    for (final pd in perfectDays) {
      final key = '${pd.year}-${pd.month.toString().padLeft(2, '0')}';
      perfectDaysByMonth.putIfAbsent(key, () => {}).add(pd.day);
    }
    for (final entry in perfectDaysByMonth.entries) {
      if (entry.value.length >= 20) {
        hasPerfectMonth = true;
        break;
      }
    }

    // Economy: Wallet replay
    int perfectWeekGrants = perfectWeeksCount;
    int streakRepairsCount = streakRepairs.length;
    bool reachedTwoFreezes = false;

    // Replay timeline of grants and repairs
    final timeline = <({DateTime time, int delta})>[];
    for (final e in xpEvents) {
      if (e.type == 2) {
        timeline.add((time: e.createdAt, delta: 1));
      }
    }
    for (final r in streakRepairs) {
      timeline.add((time: r.appliedAt, delta: -1));
    }
    timeline.sort((a, b) => a.time.compareTo(b.time));

    int runningBalance = 0;
    for (final item in timeline) {
      runningBalance = (runningBalance + item.delta).clamp(0, 2);
      if (runningBalance >= 2) {
        reachedTwoFreezes = true;
        break;
      }
    }

    // Rarities calculations
    bool hasJan1 = false;
    bool hasDec21 = false;
    bool hasJun21 = false;
    bool hasFeb29 = false;
    bool hasYearOne = false;
    LocalDate? firstCompletionDate;

    final distinctDates = <LocalDate>{};
    final completionsByDateCount = <LocalDate, int>{};

    for (final c in completions) {
      final d = LocalDate.parse(c.localDate);
      distinctDates.add(d);
      completionsByDateCount[d] = (completionsByDateCount[d] ?? 0) + c.value;

      if (d.month == 1 && d.day == 1) hasJan1 = true;
      if (d.month == 12 && d.day == 21) hasDec21 = true;
      if (d.month == 6 && d.day == 21) hasJun21 = true;
      if (d.month == 2 && d.day == 29) hasFeb29 = true;

      if (firstCompletionDate == null || d < firstCompletionDate) {
        firstCompletionDate = d;
      }
    }

    if (firstCompletionDate != null) {
      for (final d in distinctDates) {
        if (d.differenceInDays(firstCompletionDate) >= 365) {
          hasYearOne = true;
          break;
        }
      }
    }

    // Consecutive active days (Unbroken Year)
    final sortedDates = distinctDates.toList()..sort();
    int maxConsecutiveActiveDays = 0;
    if (sortedDates.isNotEmpty) {
      int currentRun = 1;
      maxConsecutiveActiveDays = 1;
      for (int i = 1; i < sortedDates.length; i++) {
        if (sortedDates[i].differenceInDays(sortedDates[i - 1]) == 1) {
          currentRun++;
          if (currentRun > maxConsecutiveActiveDays) {
            maxConsecutiveActiveDays = currentRun;
          }
        } else {
          currentRun = 1;
        }
      }
    }

    // Sealed pre-calculations
    bool hasNightOwl = false;
    bool hasDawnbreaker = false;
    int backfilledCount = 0;
    int notesCount = 0;
    int maxCompletionsInOneDay = 0;

    for (final c in completions) {
      final hour = c.createdAt.hour;
      if (hour >= 0 && hour < 5) hasNightOwl = true;
      if (hour < 7) hasDawnbreaker = true;

      final localDate = LocalDate.parse(c.localDate);
      final createdLocalDate = LocalDate.fromDateTime(c.createdAt);
      if (localDate < createdLocalDate) {
        backfilledCount += c.value;
      }

      if (c.note != null && c.note!.trim().isNotEmpty) {
        notesCount++;
      }
    }

    for (final count in completionsByDateCount.values) {
      if (count > maxCompletionsInOneDay) {
        maxCompletionsInOneDay = count;
      }
    }

    // Curator: >= 5 quests archived
    int archivedQuestsCount = quests.where((q) => q.archivedAt != null).length;

    // ── Evaluate all catalog badges ─────────────────────────────────────────
    return catalog.map((b) {
      bool earned = seenBadgeKeys.contains('badge:${b.key}') || seenBadgeKeys.contains(b.key);
      int currentVal = 0;
      bool eligible = true;

      switch (b.key) {
        // JOURNEY
        case 'first_step':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 1;
          break;
        case 'tenfold':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 10;
          break;
        case 'half_century':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 50;
          break;
        case 'century':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 100;
          break;
        case 'millennial':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 1000;
          break;
        case 'long_log':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 5000;
          break;

        // STREAKS
        case 'weeks_worth':
          currentVal = maxAnyStreak;
          earned = earned || currentVal >= 7;
          break;
        case 'month_iron':
          currentVal = maxAnyStreak;
          earned = earned || currentVal >= 30;
          break;
        case 'streak_centurion':
          currentVal = maxAnyStreak;
          earned = earned || currentVal >= 100;
          break;
        case 'long_year':
          currentVal = maxAnyStreak;
          earned = earned || currentVal >= 365;
          break;
        case 'thirty_weeks':
          currentVal = maxWeeklyStreak;
          earned = earned || currentVal >= 30;
          break;
        case 'dozen_moons':
          currentVal = maxMonthlyStreak;
          earned = earned || currentVal >= 12;
          break;
        case 'three_ages':
          currentVal = maxYearlyStreak;
          earned = earned || currentVal >= 3;
          break;

        // PERFECTION
        case 'perfect_ten':
          currentVal = perfectDaysCount;
          earned = earned || currentVal >= 10;
          break;
        case 'fifty_flawless':
          currentVal = perfectDaysCount;
          earned = earned || currentVal >= 50;
          break;
        case 'perfect_hundred':
          currentVal = perfectDaysCount;
          earned = earned || currentVal >= 100;
          break;
        case 'first_perfect_week':
          currentVal = perfectWeeksCount;
          earned = earned || currentVal >= 1;
          break;
        case 'flawless_fortnight':
          currentVal = maxConsecutivePerfectDays;
          earned = earned || currentVal >= 14;
          break;
        case 'perfect_month':
          currentVal = hasPerfectMonth ? 1 : 0;
          earned = earned || hasPerfectMonth;
          break;

        // GOALS
        case 'goal_getter':
          currentVal = completedGoalsCount;
          earned = earned || currentVal >= 1;
          break;
        case 'polymath':
          currentVal = completedGoalsCount;
          earned = earned || currentVal >= 5;
          break;
        case 'decathlon':
          currentVal = completedGoalsCount;
          earned = earned || currentVal >= 10;
          break;

        // ECONOMY
        case 'first_freeze':
          currentVal = perfectWeekGrants;
          earned = earned || currentVal >= 1;
          break;
        case 'full_pantry':
          currentVal = reachedTwoFreezes ? 2 : runningBalance;
          earned = earned || reachedTwoFreezes;
          break;
        case 'grace_thrice':
          currentVal = streakRepairsCount;
          earned = earned || currentVal >= 3;
          break;

        // RARITIES
        case 'new_years_quest':
          currentVal = hasJan1 ? 1 : 0;
          earned = earned || hasJan1;
          break;
        case 'midwinter':
          currentVal = hasDec21 ? 1 : 0;
          earned = earned || hasDec21;
          break;
        case 'midsummer':
          currentVal = hasJun21 ? 1 : 0;
          earned = earned || hasJun21;
          break;
        case 'leap_day':
          currentVal = hasFeb29 ? 1 : 0;
          earned = earned || hasFeb29;
          break;
        case 'year_one':
          currentVal = hasYearOne ? 1 : 0;
          earned = earned || hasYearOne;
          break;
        case 'unbroken_year':
          currentVal = maxConsecutiveActiveDays;
          earned = earned || currentVal >= 365;
          break;

        // CALLING TRIALS
        case 'trial_iron_will':
          eligible = userCalling == CallingDomain.warrior;
          currentVal = maxStreakByDomain[CallingDomain.warrior] ?? 0;
          earned = earned || (eligible && currentVal >= 30);
          break;
        case 'trial_hundred_battles':
          eligible = userCalling == CallingDomain.warrior;
          currentVal = domainCompletionsCount[CallingDomain.warrior] ?? 0;
          earned = earned || (eligible && currentVal >= 100);
          break;
        case 'trial_unbroken_focus':
          eligible = userCalling == CallingDomain.sage;
          currentVal = maxStreakByDomain[CallingDomain.sage] ?? 0;
          earned = earned || (eligible && currentVal >= 30);
          break;
        case 'trial_the_archive':
          eligible = userCalling == CallingDomain.sage;
          currentVal = domainCompletionsCount[CallingDomain.sage] ?? 0;
          earned = earned || (eligible && currentVal >= 100);
          break;
        case 'trial_still_water':
          eligible = userCalling == CallingDomain.monk;
          currentVal = maxStreakByDomain[CallingDomain.monk] ?? 0;
          earned = earned || (eligible && currentVal >= 30);
          break;
        case 'trial_the_practice':
          eligible = userCalling == CallingDomain.monk;
          currentVal = domainCompletionsCount[CallingDomain.monk] ?? 0;
          earned = earned || (eligible && currentVal >= 100);
          break;
        case 'trial_long_refrain':
          eligible = userCalling == CallingDomain.bard;
          currentVal = maxStreakByDomain[CallingDomain.bard] ?? 0;
          earned = earned || (eligible && currentVal >= 30);
          break;
        case 'trial_the_repertoire':
          eligible = userCalling == CallingDomain.bard;
          currentVal = domainCompletionsCount[CallingDomain.bard] ?? 0;
          earned = earned || (eligible && currentVal >= 100);
          break;
        case 'trial_long_trail':
          eligible = userCalling == CallingDomain.ranger;
          currentVal = maxStreakByDomain[CallingDomain.ranger] ?? 0;
          earned = earned || (eligible && currentVal >= 30);
          break;
        case 'trial_cartographer':
          eligible = userCalling == CallingDomain.ranger;
          currentVal = domainCompletionsCount[CallingDomain.ranger] ?? 0;
          earned = earned || (eligible && currentVal >= 100);
          break;
        case 'trial_steady_hands':
          eligible = userCalling == CallingDomain.artificer;
          currentVal = maxStreakByDomain[CallingDomain.artificer] ?? 0;
          earned = earned || (eligible && currentVal >= 30);
          break;
        case 'trial_masterwork':
          eligible = userCalling == CallingDomain.artificer;
          currentVal = domainCompletionsCount[CallingDomain.artificer] ?? 0;
          earned = earned || (eligible && currentVal >= 100);
          break;

        // SEALED
        case 'night_owl':
          currentVal = hasNightOwl ? 1 : 0;
          earned = earned || hasNightOwl;
          break;
        case 'dawnbreaker':
          currentVal = hasDawnbreaker ? 1 : 0;
          earned = earned || hasDawnbreaker;
          break;
        case 'historian':
          currentVal = backfilledCount;
          earned = earned || currentVal >= 25;
          break;
        case 'scribe':
          currentVal = notesCount;
          earned = earned || currentVal >= 50;
          break;
        case 'perfectionist':
          currentVal = maxConsecutivePerfectDays;
          earned = earned || currentVal >= 14;
          break;
        case 'curator':
          currentVal = archivedQuestsCount;
          earned = earned || currentVal >= 5;
          break;
        case 'marathon_day':
          currentVal = maxCompletionsInOneDay;
          earned = earned || currentVal >= 12;
          break;
      }

      return BadgeStatus(
        definition: b,
        isEarned: earned,
        currentValue: currentVal,
        isEligible: eligible,
      );
    }).toList();
  }
}

