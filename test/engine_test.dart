import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/domain/constants/titles.dart';
import 'package:questlog/domain/constants/xp_constants.dart';
import 'package:questlog/domain/engine/badges.dart';
import 'package:questlog/domain/engine/progression.dart';
import 'package:questlog/domain/engine/quest_state.dart';
import 'package:questlog/domain/engine/schedule_rule.dart';
import 'package:questlog/domain/engine/streak.dart';
import 'package:questlog/domain/engine/xp.dart';
import 'package:questlog/domain/model/models.dart';

void main() {
  group('XP Engine Tests', () {
    test('Calculates period XP for daily medium quest with 100% progress', () {
      final xp = XpEngine.calculatePeriodXp(
        cadence: Cadence.daily,
        difficulty: Difficulty.medium,
        progress: 1.0,
      );
      // Base: 10 * 1.5 * 1.0 = 15
      expect(xp, 15);
    });

    test('Calculates period XP with overachievement cap', () {
      final xp = XpEngine.calculatePeriodXp(
        cadence: Cadence.daily,
        difficulty: Difficulty.easy,
        progress: 2.0,
      );
      // Base: 10 * 1.0 * (1 + 0.25 * 1) = 10 * 1.25 = 13 (approx)
      expect(xp, 13);
    });

    test('Calculates incremental XP on counter increment', () {
      final rule = const DailyEveryDayRule();
      final incremental = XpEngine.calculateIncrementalXp(
        rule: rule,
        difficulty: Difficulty.hard,
        target: 4,
        previousCount: 0,
        newCount: 2,
        isScheduled: true,
      );
      // Hard = 2.0 * 10 = 20 max; 2/4 = 50% => 10 XP
      expect(incremental, 10);
    });
  });

  group('Progression Engine Tests', () {
    test('Calculates level thresholds accurately', () {
      expect(ProgressionEngine.levelFromXp(0), 1);
      expect(ProgressionEngine.levelFromXp(99), 1);
      expect(ProgressionEngine.levelFromXp(100), 2);
      expect(ProgressionEngine.levelFromXp(250), 3);
      expect(ProgressionEngine.levelFromXp(450), 4);
      expect(ProgressionEngine.levelFromXp(700), 5);
      expect(ProgressionEngine.levelFromXp(1350), 7);
    });

    test('Resolves calling titles correctly across levels', () {
      expect(CallingTitles.titleFor(calling: CallingDomain.warrior, level: 1), 'Recruit');
      expect(CallingTitles.titleFor(calling: CallingDomain.warrior, level: 7), 'Knight');
      expect(CallingTitles.titleFor(calling: CallingDomain.artificer, level: 7), 'Artificer');
    });
  });

  group('Streak Engine Tests', () {
    test('Calculates streak backward for daily quest', () {
      final today = LocalDate(2025, 6, 15);
      final rule = const DailyEveryDayRule();
      final completions = {
        LocalDate(2025, 6, 15): 1,
        LocalDate(2025, 6, 14): 1,
        LocalDate(2025, 6, 13): 1,
      };

      final result = StreakEngine.calculate(
        rule: rule,
        targetValue: 1,
        completionValues: completions,
        existingRepairs: {},
        today: today,
        weekStart: WeekStart.monday,
        firstCompletionDate: LocalDate(2025, 6, 13),
      );

      expect(result.streak, 3);
    });

    test('Uses freeze repair when wallet is available', () {
      final today = LocalDate(2025, 6, 15);
      final rule = const DailyEveryDayRule();
      final completions = {
        LocalDate(2025, 6, 15): 1,
        // Missed June 14
        LocalDate(2025, 6, 13): 1,
      };

      final result = StreakEngine.calculate(
        rule: rule,
        targetValue: 1,
        completionValues: completions,
        existingRepairs: {},
        today: today,
        weekStart: WeekStart.monday,
        firstCompletionDate: LocalDate(2025, 6, 10),
        availableFreezeWallet: 1,
      );

      expect(result.streak, 2);
      expect(result.newlyConsumedRepairs.length, 1);
    });
  });

  group('Badge Engine Tests', () {
    test('Evaluates First Step and Centurion', () {
      final badges = BadgeEngine.evaluate(
        totalCompletions: 150,
        maxStreak: 35,
        perfectDaysCount: 12,
        domainsWithCompletions: CallingDomain.values.toSet(),
        completedGoalsCount: 1,
        earnedBadgeKeys: {},
      );

      final firstStep = badges.firstWhere((b) => b.definition.key == 'first_step');
      final centurion = badges.firstWhere((b) => b.definition.key == 'centurion');
      final streak30 = badges.firstWhere((b) => b.definition.key == 'streak_30');

      expect(firstStep.isEarned, isTrue);
      expect(centurion.isEarned, isTrue);
      expect(streak30.isEarned, isTrue);
    });
  });
}
