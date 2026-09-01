import '../model/models.dart';

class XpConstants {
  static const int baseDaily = 10;
  static const int baseSingle = 15;
  static const int baseWeekly = 35;
  static const int baseMonthly = 120;
  static const int baseYearly = 400;

  static const int perfectDayBonus = 15;
  static const int perfectWeekBonus = 75; // +75 XP and grants 1 streak freeze
  static const int goalCompletionBonus = 250;

  static const int freezeWalletCapacity = 2;

  static int baseForCadence(Cadence cadence) {
    switch (cadence) {
      case Cadence.daily:
        return baseDaily;
      case Cadence.single:
        return baseSingle;
      case Cadence.weekly:
        return baseWeekly;
      case Cadence.monthly:
        return baseMonthly;
      case Cadence.yearly:
        return baseYearly;
    }
  }

  static double multiplierForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 1.0;
      case Difficulty.medium:
        return 1.5;
      case Difficulty.hard:
        return 2.0;
    }
  }

  static const Map<int, int> streakMilestones = {
    7: 50,
    30: 150,
    100: 500,
    365: 2000,
  };
}
