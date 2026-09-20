import '../model/models.dart';
import 'recurrence.dart';
import 'schedule_rule.dart';

class StreakResult {
  final int streak;
  final int bestStreak;
  final List<String> newlyConsumedRepairs;

  const StreakResult({
    required this.streak,
    required this.bestStreak,
    this.newlyConsumedRepairs = const [],
  });
}

class StreakEngine {
  static StreakResult calculate({
    required ScheduleRule rule,
    TargetType targetType = TargetType.checkbox,
    required int targetValue,
    required Map<LocalDate, int> completionValues,
    required Set<String> existingRepairs,
    required LocalDate today,
    required WeekStart weekStart,
    LocalDate? firstCompletionDate,
    LocalDate? pausedUntil,
    int availableFreezeWallet = 0,
  }) {
    if (firstCompletionDate == null || rule is SingleRule) {
      return const StreakResult(streak: 0, bestStreak: 0);
    }

    int target = targetValue;
    if (targetType == TargetType.checkbox) {
      if (rule is WeeklyRule && rule.times != null) target = rule.times!;
      if (rule is MonthlyRule && rule.times != null) target = rule.times!;
      if (rule is YearlyRule && rule.times != null) target = rule.times!;
    }

    final periods = Recurrence.periodsBackward(
      from: today,
      rule: rule,
      weekStart: weekStart.value,
      firstCompletion: firstCompletionDate,
    );

    int currentStreak = 0;
    int run = 0; // length of the run currently being walked (any era)
    int bestStreak = 0; // longest run ever — survives breaks
    int wallet = availableFreezeWallet;
    final List<String> consumedRepairs = [];
    bool currentStreakFinalized = false;

    // Current active period
    final currentPeriod = rule.periodOf(today, weekStart.value);
    int currentPeriodCompleted = 0;
    for (final entry in completionValues.entries) {
      if (entry.key >= currentPeriod.startLocalDate && entry.key <= currentPeriod.endLocalDate) {
        if (rule is WeeklyRule && rule.allowedDays != null && rule.allowedDays!.isNotEmpty) {
          if (rule.allowedDays!.contains(entry.key.toDateTime().weekday)) {
            currentPeriodCompleted += entry.value;
          }
        } else {
          currentPeriodCompleted += entry.value;
        }
      }
    }

    if (currentPeriodCompleted >= target) {
      currentStreak++;
      run++;
      bestStreak = run;
    }

    for (final period in periods) {
      // Skip current period as it was evaluated above
      if (period.startLocalDate == currentPeriod.startLocalDate &&
          period.endLocalDate == currentPeriod.endLocalDate) {
        continue;
      }

      // Stop if before first completion ever (birth grace)
      if (period.endLocalDate < firstCompletionDate) {
        break;
      }

      // If non-window and not scheduled on this day, skip completely
      if (!rule.isWindowScheduled &&
          !rule.isScheduledOn(period.startLocalDate, weekStart.value)) {
        continue;
      }

      // Check if paused
      if (pausedUntil != null &&
          period.startLocalDate <= pausedUntil &&
          period.endLocalDate >= pausedUntil) {
        continue;
      }

      // Check completions in period
      int periodCompleted = 0;
      for (final entry in completionValues.entries) {
        if (entry.key >= period.startLocalDate && entry.key <= period.endLocalDate) {
          if (rule is WeeklyRule && rule.allowedDays != null && rule.allowedDays!.isNotEmpty) {
            if (rule.allowedDays!.contains(entry.key.toDateTime().weekday)) {
              periodCompleted += entry.value;
            }
          } else {
            periodCompleted += entry.value;
          }
        }
      }

      final bool isSatisfied = periodCompleted >= target;
      final String pKey = rule.periodKey(period.startLocalDate, weekStart.value);

      if (isSatisfied) {
        run++;
        if (run > bestStreak) bestStreak = run;
        if (!currentStreakFinalized) {
          currentStreak++;
        }
      } else if (existingRepairs.contains(pKey)) {
        // Previously consumed freeze repair bridges the run (unextended).
        continue;
      } else if (wallet > 0 && !currentStreakFinalized) {
        // Consume available freeze from wallet to preserve the current run.
        wallet--;
        consumedRepairs.add(pKey);
        continue;
      } else {
        // Run ends here: bank it, freeze the current count on first break,
        // but keep scanning — older runs still count toward best.
        if (run > bestStreak) bestStreak = run;
        run = 0;
        currentStreakFinalized = true;
        continue;
      }
    }

    if (run > bestStreak) bestStreak = run;

    return StreakResult(
      streak: currentStreak,
      bestStreak: bestStreak,
      newlyConsumedRepairs: consumedRepairs,
    );
  }
}
