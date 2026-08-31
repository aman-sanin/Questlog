import '../constants/xp_constants.dart';
import '../model/models.dart';
import 'schedule_rule.dart';

class XpEngine {
  /// Calculate total XP for a period given its progress ratio (completed / target)
  static int calculatePeriodXp({
    required Cadence cadence,
    required Difficulty difficulty,
    required double progress,
  }) {
    if (progress <= 0) return 0;

    final base = XpConstants.baseForCadence(cadence);
    final diffMultiplier = XpConstants.multiplierForDifficulty(difficulty);

    // Overachievement scale: min(progress, 1 + 0.25 * max(0, progress - 1))
    final effectiveProgress = progress <= 1.0
        ? progress
        : (1.0 + 0.25 * (progress - 1.0)).clamp(1.0, 1.5);

    final double total = base * diffMultiplier * effectiveProgress;
    return total.round();
  }

  /// Calculates the incremental XP to grant for a completion event
  static int calculateIncrementalXp({
    required ScheduleRule rule,
    required Difficulty difficulty,
    required int target,
    required int previousCount,
    required int newCount,
    required bool isScheduled,
  }) {
    if (!isScheduled || target <= 0) {
      return 0;
    }

    final prevProgress = previousCount / target;
    final newProgress = newCount / target;

    final prevXp = calculatePeriodXp(
      cadence: rule.cadence,
      difficulty: difficulty,
      progress: prevProgress,
    );

    final newXp = calculatePeriodXp(
      cadence: rule.cadence,
      difficulty: difficulty,
      progress: newProgress,
    );

    final delta = newXp - prevXp;
    return delta > 0 ? delta : 0;
  }

  /// Check if a streak length hits a milestone and return the XP bonus
  static int? bonusForStreakMilestone(int streak) {
    return XpConstants.streakMilestones[streak];
  }
}
