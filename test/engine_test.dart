import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/domain/constants/titles.dart';
import 'package:questlog/domain/constants/unlock_schedule.dart';
import 'package:questlog/domain/constants/xp_constants.dart';
import 'package:questlog/domain/engine/insights.dart';
import 'package:questlog/domain/engine/progression.dart';
import 'package:questlog/domain/engine/schedule_rule.dart';
import 'package:questlog/domain/engine/settlement.dart';
import 'package:questlog/domain/engine/streak.dart';
import 'package:questlog/domain/engine/xp.dart';
import 'package:questlog/domain/model/models.dart';

void main() {
  group('Group B: Streak Money Tests', () {
    test('MWF quest: complete Mon + Wed, skip Tue -> Streak = 2, Tuesday registers nothing', () {
      final rule = const DailyWeekdaysRule(days: [1, 3, 5]); // Mon, Wed, Fri
      final monday = const LocalDate(2025, 1, 6);
      final wednesday = const LocalDate(2025, 1, 8);
      final thursday = const LocalDate(2025, 1, 9); // evaluation day

      final completions = {
        monday: 1,
        wednesday: 1,
      };

      final result = StreakEngine.calculate(
        rule: rule,
        targetValue: 1,
        completionValues: completions,
        existingRepairs: {},
        today: thursday,
        weekStart: WeekStart.monday,
        firstCompletionDate: monday,
      );

      expect(result.streak, equals(2));
      expect(result.newlyConsumedRepairs, isEmpty);
    });

    test('New quest, 3 uncompleted days: Grace -> no miss, no red, no streak', () {
      const rule = DailyEveryDayRule();
      final today = const LocalDate(2025, 1, 4);

      final result = StreakEngine.calculate(
        rule: rule,
        targetValue: 1,
        completionValues: {},
        existingRepairs: {},
        today: today,
        weekStart: WeekStart.monday,
        firstCompletionDate: null, // never completed
      );

      expect(result.streak, equals(0));
      expect(result.bestStreak, equals(0));
      expect(result.newlyConsumedRepairs, isEmpty);
    });

    test('Pause spanning a full week: neutral -> streak intact, week invisible', () {
      const rule = WeeklyTimesRule(times: 3);
      final w1 = const LocalDate(2025, 1, 6);  // Mon week 1
      final w2 = const LocalDate(2025, 1, 13); // Mon week 2 (paused)
      final w3 = const LocalDate(2025, 1, 20); // Mon week 3 (today)

      final completions = {
        w1: 3,
        w3: 3,
      };

      final result = StreakEngine.calculate(
        rule: rule,
        targetValue: 3,
        completionValues: completions,
        existingRepairs: {},
        today: w3,
        weekStart: WeekStart.monday,
        firstCompletionDate: w1,
        pausedUntil: const LocalDate(2025, 1, 19), // paused through week 2
      );

      expect(result.streak, equals(2)); // Week 1 + Week 3
    });

    test('Freeze consumed on miss, streak evaluated twice: consumed exactly once (UNIQUE constraint test)', () {
      const rule = DailyEveryDayRule();
      final day1 = const LocalDate(2025, 1, 1);
      final day2 = const LocalDate(2025, 1, 2); // missed
      final day3 = const LocalDate(2025, 1, 3); // today, completed

      final completions = {
        day1: 1,
        day3: 1,
      };

      // Evaluation 1: with 1 freeze available in wallet
      final eval1 = StreakEngine.calculate(
        rule: rule,
        targetValue: 1,
        completionValues: completions,
        existingRepairs: {},
        today: day3,
        weekStart: WeekStart.monday,
        firstCompletionDate: day1,
        availableFreezeWallet: 1,
      );

      expect(eval1.streak, equals(2));
      expect(eval1.newlyConsumedRepairs, equals(['2025-01-02']));

      // Evaluation 2: rerun after repair has been recorded in database
      final eval2 = StreakEngine.calculate(
        rule: rule,
        targetValue: 1,
        completionValues: completions,
        existingRepairs: {'2025-01-02'},
        today: day3,
        weekStart: WeekStart.monday,
        firstCompletionDate: day1,
        availableFreezeWallet: 0,
      );

      expect(eval2.streak, equals(2));
      expect(eval2.newlyConsumedRepairs, isEmpty); // no double-consume
    });
  });

  group('Group C: XP Arithmetic', () {
    test('Gym ×3/week medium (base=35, mult=1.5): increments pay 18 / 17 / 18, sum = 53', () {
      const rule = WeeklyTimesRule(times: 3);

      final inc1 = XpEngine.calculateIncrementalXp(
        rule: rule,
        difficulty: Difficulty.medium,
        target: 3,
        previousCount: 0,
        newCount: 1,
        isScheduled: true,
      );

      final inc2 = XpEngine.calculateIncrementalXp(
        rule: rule,
        difficulty: Difficulty.medium,
        target: 3,
        previousCount: 1,
        newCount: 2,
        isScheduled: true,
      );

      final inc3 = XpEngine.calculateIncrementalXp(
        rule: rule,
        difficulty: Difficulty.medium,
        target: 3,
        previousCount: 2,
        newCount: 3,
        isScheduled: true,
      );

      expect(inc1, equals(18));
      expect(inc2, equals(17));
      expect(inc3, equals(18));
      expect(inc1 + inc2 + inc3, equals(53));
    });

    test('4th increment pays +13 (quarter-rate per extra unit); cap is 2 extra units (79 XP max); 3rd extra pays 0', () {
      const rule = WeeklyTimesRule(times: 3);

      // 4th increment (1st extra unit)
      final inc4 = XpEngine.calculateIncrementalXp(
        rule: rule,
        difficulty: Difficulty.medium,
        target: 3,
        previousCount: 3,
        newCount: 4,
        isScheduled: true,
      );
      expect(inc4, equals(13)); // 66 - 53 = 13

      // 5th increment (2nd extra unit -> caps at 79)
      final inc5 = XpEngine.calculateIncrementalXp(
        rule: rule,
        difficulty: Difficulty.medium,
        target: 3,
        previousCount: 4,
        newCount: 5,
        isScheduled: true,
      );
      expect(inc5, equals(13)); // 79 - 66 = 13

      // 6th increment (3rd extra unit -> 0 XP)
      final inc6 = XpEngine.calculateIncrementalXp(
        rule: rule,
        difficulty: Difficulty.medium,
        target: 3,
        previousCount: 5,
        newCount: 6,
        isScheduled: true,
      );
      expect(inc6, equals(0)); // capped at 79

      // Cumulative for 6 completions
      final total6 = XpEngine.calculatePeriodXp(
        cadence: Cadence.weekly,
        difficulty: Difficulty.medium,
        target: 3,
        count: 6,
      );
      expect(total6, equals(79));
    });

    test('Partial week: 2 of 3 sessions = 35 XP', () {
      final total2 = XpEngine.calculatePeriodXp(
        cadence: Cadence.weekly,
        difficulty: Difficulty.medium,
        target: 3,
        count: 2,
      );
      expect(total2, equals(35));
    });

    test('Off-schedule completion scores 0 XP', () {
      const rule = DailyWeekdaysRule(days: [1, 3, 5]); // Mon, Wed, Fri
      final inc = XpEngine.calculateIncrementalXp(
        rule: rule,
        difficulty: Difficulty.medium,
        target: 1,
        previousCount: 0,
        newCount: 1,
        isScheduled: false, // completed on Tuesday
      );
      expect(inc, equals(0));
    });
  });

  group('Group D: Settlement Engine', () {
    test('settle() twice back-to-back: byte-identical & idempotent', () {
      final monday = const LocalDate(2025, 1, 6);
      final sunday = const LocalDate(2025, 1, 12);
      final nextMon = const LocalDate(2025, 1, 13);

      final questsData = [
        {
          'id': 'q-1',
          'essential': true,
          'rule': const DailyEveryDayRule(),
          'targetValue': 1,
        }
      ];

      final completionsByQuest = {
        'q-1': {
          for (int d = 6; d <= 12; d++) LocalDate(2025, 1, d): 1,
        }
      };

      // Settlement 1
      final res1 = SettlementEngine.settle(
        questsData: questsData,
        completionsByQuest: completionsByQuest,
        profileSettledThrough: null,
        today: nextMon,
        weekStart: WeekStart.monday,
        existingEventRefs: {},
      );

      expect(res1.newEvents.length, equals(8)); // 7 perfect days + 1 perfect week
      final existingRefs = res1.newEvents.map((e) => e.ref).toSet();

      // Settlement 2: rerun with existingRefs populated
      final res2 = SettlementEngine.settle(
        questsData: questsData,
        completionsByQuest: completionsByQuest,
        profileSettledThrough: sunday,
        today: nextMon,
        weekStart: WeekStart.monday,
        existingEventRefs: existingRefs,
      );

      expect(res2.newEvents, isEmpty);
    });

    test('Perfect Week closes -> grants +75 XP', () {
      final monday = const LocalDate(2025, 1, 6);
      final nextMon = const LocalDate(2025, 1, 13);

      final questsData = [
        {
          'id': 'q-1',
          'essential': false,
          'rule': const DailyEveryDayRule(),
          'targetValue': 1,
        }
      ];

      final completionsByQuest = {
        'q-1': {
          for (int d = 6; d <= 12; d++) LocalDate(2025, 1, d): 1,
        }
      };

      final res = SettlementEngine.settle(
        questsData: questsData,
        completionsByQuest: completionsByQuest,
        profileSettledThrough: null,
        today: nextMon,
        weekStart: WeekStart.monday,
        existingEventRefs: {},
      );

      final perfectWeekEvent = res.newEvents.firstWhere((e) => e.type == XpEventType.perfectWeek);
      expect(perfectWeekEvent.amount, equals(75));
    });

    test('Perfect Day with zero scheduled essentials -> no event awarded', () {
      final day = const LocalDate(2025, 1, 6);
      final nextDay = const LocalDate(2025, 1, 7);

      final questsData = [
        {
          'id': 'q-1',
          'essential': false, // non-essential
          'rule': const DailyEveryDayRule(),
          'targetValue': 1,
        }
      ];

      final completionsByQuest = {
        'q-1': {day: 1}
      };

      final res = SettlementEngine.settle(
        questsData: questsData,
        completionsByQuest: completionsByQuest,
        profileSettledThrough: null,
        today: nextDay,
        weekStart: WeekStart.monday,
        existingEventRefs: {},
      );

      expect(res.newEvents.where((e) => e.type == XpEventType.perfectDay), isEmpty);
    });
  });

  group('Group E: Progression Engine', () {
    test('Cumulative XP formula exact values: cumXP(2)=100, cumXP(6)=1,000, cumXP(10)=2,700', () {
      expect(ProgressionEngine.cumulativeXpForLevel(1), equals(0));
      expect(ProgressionEngine.cumulativeXpForLevel(2), equals(100));
      expect(ProgressionEngine.cumulativeXpForLevel(6), equals(1000));
      expect(ProgressionEngine.cumulativeXpForLevel(10), equals(2700));
    });

    test('levelFromXp thresholds', () {
      expect(ProgressionEngine.levelFromXp(0), equals(1));
      expect(ProgressionEngine.levelFromXp(99), equals(1));
      expect(ProgressionEngine.levelFromXp(100), equals(2));
      expect(ProgressionEngine.levelFromXp(999), equals(5));
      expect(ProgressionEngine.levelFromXp(1000), equals(6));
      expect(ProgressionEngine.levelFromXp(2700), equals(10));
    });

    test('Unlock gates at L3 (Sage), L5 (Ice), L13 (Copper), L16 (Ember)', () {
      final l3Unlocks = UnlockSchedule.unlocksForLevel(3);
      expect(l3Unlocks.any((u) => u.key == 'sage_accent'), isTrue);

      final l5Unlocks = UnlockSchedule.unlocksForLevel(5);
      expect(l5Unlocks.any((u) => u.key == 'ice_accent'), isTrue);

      final l13Unlocks = UnlockSchedule.unlocksForLevel(13);
      expect(l13Unlocks.any((u) => u.key == 'copper_accent'), isTrue);

      final l16Unlocks = UnlockSchedule.unlocksForLevel(16);
      expect(l16Unlocks.any((u) => u.key == 'ember_accent'), isTrue);
    });

    test('Title ladder 8 rungs boundary tests at L1/L2/L4/L7/L11/L16/L21/L30/L31', () {
      // Generic ladder
      expect(CallingTitles.titleFor(calling: null, level: 1), equals('Recruit'));
      expect(CallingTitles.titleFor(calling: null, level: 2), equals('Squire'));
      expect(CallingTitles.titleFor(calling: null, level: 4), equals('Soldier'));
      expect(CallingTitles.titleFor(calling: null, level: 7), equals('Veteran'));
      expect(CallingTitles.titleFor(calling: null, level: 11), equals('Champion'));
      expect(CallingTitles.titleFor(calling: null, level: 16), equals('Warlord'));
      expect(CallingTitles.titleFor(calling: null, level: 21), equals('Paragon'));
      expect(CallingTitles.titleFor(calling: null, level: 30), equals('Legend'));
      expect(CallingTitles.titleFor(calling: null, level: 31), equals('Legend ★1'));

      // Sage calling ladder
      expect(CallingTitles.titleFor(calling: CallingDomain.sage, level: 1), equals('Student'));
      expect(CallingTitles.titleFor(calling: CallingDomain.sage, level: 2), equals('Scholar'));
      expect(CallingTitles.titleFor(calling: CallingDomain.sage, level: 4), equals('Librarian'));
      expect(CallingTitles.titleFor(calling: CallingDomain.sage, level: 7), equals('Sage'));
      expect(CallingTitles.titleFor(calling: CallingDomain.sage, level: 11), equals('Master Scholar'));
      expect(CallingTitles.titleFor(calling: CallingDomain.sage, level: 16), equals('Arch-Scholar'));
      expect(CallingTitles.titleFor(calling: CallingDomain.sage, level: 21), equals('Oracle'));
      expect(CallingTitles.titleFor(calling: CallingDomain.sage, level: 30), equals('Archmage'));
      expect(CallingTitles.titleFor(calling: CallingDomain.sage, level: 35), equals('Archmage ★5'));
    });

    test('Domain affinity percentages sum to 1.0 (100%)', () {
      final prog = ProgressionEngine.calculate(
        totalXp: 1500,
        chosenCalling: CallingDomain.warrior,
        domainXp: {
          CallingDomain.warrior: 600,
          CallingDomain.sage: 300,
          CallingDomain.monk: 100,
        },
      );

      double sum = 0.0;
      for (final val in prog.domainAffinity.values) {
        sum += val;
      }
      expect(sum, closeTo(1.0, 0.001));
    });
  });

  group('Group F: Insights Engine', () {
    test('Deterministic weekly insight rotation based on ISO week (same week -> same card)', () {
      final monday1 = const LocalDate(2025, 1, 6);   // ISO week 2
      final thursday1 = const LocalDate(2025, 1, 9); // ISO week 2

      final insight1 = InsightsEngine.getWeeklyInsight(
        completionsByDate: {},
        today: monday1,
        totalXp: 1000,
      );
      final insight2 = InsightsEngine.getWeeklyInsight(
        completionsByDate: {},
        today: thursday1,
        totalXp: 1000,
      );

      expect(insight1.headline, equals(insight2.headline));
      expect(insight1.stat, equals(insight2.stat));
    });

    test('Coach triggers at >=90% and <50% over 14 days, honors 30-day cooldown', () {
      // High performance (>90%) with low quest count
      final coach1 = InsightsEngine.evaluateCoachCard(
        fourteenDayRate: 0.95,
        activeQuestsCount: 3,
        isCooldownActive: false,
      );
      expect(coach1, isNotNull);
      expect(coach1!.title, equals('Mastery in Motion'));

      // Low performance (<50%) with high quest count
      final coach2 = InsightsEngine.evaluateCoachCard(
        fourteenDayRate: 0.40,
        activeQuestsCount: 6,
        isCooldownActive: false,
      );
      expect(coach2, isNotNull);
      expect(coach2!.title, equals('Focus Your Energy'));

      // In cooldown -> null
      final coachCooldown = InsightsEngine.evaluateCoachCard(
        fourteenDayRate: 0.95,
        activeQuestsCount: 3,
        isCooldownActive: true,
      );
      expect(coachCooldown, isNull);
    });
  });
}
