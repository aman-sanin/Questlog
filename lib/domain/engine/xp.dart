import '../constants/xp_constants.dart';
import '../model/models.dart';
import 'schedule_rule.dart';

class XpEngine {
  /// Calculate total XP for a period given the cadence, difficulty, target, and completed count.
  static int calculatePeriodXp({
    required Cadence cadence,
    required Difficulty difficulty,
    required int target,
    required int count,
  }) {
    if (count <= 0 || target <= 0) return 0;

    final base = XpConstants.baseForCadence(cadence);
    final diffMultiplier = XpConstants.multiplierForDifficulty(difficulty);
    final basePeriodXp = base * diffMultiplier;

    if (count <= target) {
      final progress = count / target;
      return (basePeriodXp * progress).round();
    } else {
      // Overachievement: quarter-rate per extra unit, capped at 2 extra units (max 1.5x)
      final extraUnits = (count - target).clamp(0, 2);
      final effectiveMultiplier = 1.0 + (0.25 * extraUnits);
      return (basePeriodXp * effectiveMultiplier).round();
    }
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
    if (!isScheduled || target <= 0 || newCount <= previousCount) {
      return 0;
    }

    final prevXp = calculatePeriodXp(
      cadence: rule.cadence,
      difficulty: difficulty,
      target: target,
      count: previousCount,
    );

    final newXp = calculatePeriodXp(
      cadence: rule.cadence,
      difficulty: difficulty,
      target: target,
      count: newCount,
    );

    final delta = newXp - prevXp;
    return delta > 0 ? delta : 0;
  }

  /// Check if a streak length hits a milestone and return the XP bonus
  static int? bonusForStreakMilestone(int streak) {
    return XpConstants.streakMilestones[streak];
  }
}
