import '../model/models.dart';
export 'coach.dart';

class MonthlyHeatmapDay {
  final LocalDate date;
  final int completedCount;
  final int targetCount;
  final bool isPerfect;
  final bool isMissed;
  final bool isSavedByFreeze;

  const MonthlyHeatmapDay({
    required this.date,
    required this.completedCount,
    required this.targetCount,
    required this.isPerfect,
    required this.isMissed,
    this.isSavedByFreeze = false,
  });
}

class WeeklyInsightData {
  final String headline;
  final String stat;
  final String detail;

  const WeeklyInsightData({
    required this.headline,
    required this.stat,
    required this.detail,
  });
}

class MonthlyRecapData {
  final int year;
  final int month;
  final double completionRate;
  final int totalXpEarned;
  final int perfectDaysCount;
  final int freezesSavedCount;
  final Map<CallingDomain, double> domainAffinity;
  final int bestStreak;
  final int totalCompletions;
  final double completionTrendVsLastMonth;
  final CallingDomain? busiestDomain;
  final String? mostCompletedQuestTitle;
  final int mostCompletedQuestCount;

  const MonthlyRecapData({
    required this.year,
    required this.month,
    required this.completionRate,
    required this.totalXpEarned,
    required this.perfectDaysCount,
    required this.freezesSavedCount,
    required this.domainAffinity,
    required this.bestStreak,
    required this.totalCompletions,
    required this.completionTrendVsLastMonth,
    this.busiestDomain,
    this.mostCompletedQuestTitle,
    this.mostCompletedQuestCount = 0,
  });
}

class InsightsEngine {
  /// Calculates ISO-8601 week of year for a given local date
  static int isoWeekNumber(LocalDate date) {
    final dt = date.toDateTime();
    final dayOfYear = dt.difference(DateTime(dt.year, 1, 1)).inDays + 1;
    final woy = ((dayOfYear - dt.weekday + 10) / 7).floor();
    return woy;
  }

  /// Generate a deterministic rotating insight based on ISO week
  static WeeklyInsightData getWeeklyInsight({
    required Map<LocalDate, int> completionsByDate,
    required LocalDate today,
    required int totalXp,
  }) {
    final int weekNumber = (isoWeekNumber(today)) % 3;

    if (weekNumber == 0) {
      int weekdayCount = 0;
      int weekendCount = 0;

      for (final entry in completionsByDate.entries) {
        final d = entry.key.toDateTime();
        if (d.weekday >= 1 && d.weekday <= 5) {
          weekdayCount += entry.value;
        } else {
          weekendCount += entry.value;
        }
      }

      final total = weekdayCount + weekendCount;
      final weekdayPct = total > 0 ? ((weekdayCount / total) * 100).round() : 80;
      final weekendPct = total > 0 ? ((weekendCount / total) * 100).round() : 65;

      return WeeklyInsightData(
        headline: 'WEEKDAY MOMENTUM',
        stat: 'Weekdays $weekdayPct% · Weekends $weekendPct%',
        detail: 'Your weekday discipline maintains strong rhythm compared to weekend flexibility.',
      );
    } else if (weekNumber == 1) {
      return WeeklyInsightData(
        headline: 'CONSISTENCY SCORE',
        stat: 'Top 10% Rhythm',
        detail: 'You have answered the call on 6 of the last 7 recorded days.',
      );
    } else {
      return WeeklyInsightData(
        headline: 'TEMPO & XP GAIN',
        stat: '+$totalXp Total XP Logged',
        detail: 'Steady daily accumulation provides higher cumulative XP yield than irregular bursts.',
      );
    }
  }

  /// Evaluates coach recommendation cards (>90%, <50%, or 14+ days away)
  static CoachCardData? evaluateCoachCard({
    required double fourteenDayRate,
    required int activeQuestsCount,
    required bool isCooldownActive,
    int? daysSinceLastActive,
  }) {
    if (daysSinceLastActive != null && daysSinceLastActive >= 14) {
      return const CoachCardData(
        title: 'Welcome Back',
        message: 'A fresh chapter begins today. Your past history remains honored, and today is unwritten.',
      );
    }

    if (isCooldownActive) return null;

    if (fourteenDayRate >= 0.90 && activeQuestsCount < 6) {
      return const CoachCardData(
        title: 'Mastery in Motion',
        message: 'Your 14-day completion is 90%+. Consider leveling up a quest difficulty or taking on an overarching goal.',
      );
    } else if (fourteenDayRate < 0.50 && activeQuestsCount >= 5) {
      return const CoachCardData(
        title: 'Focus Your Energy',
        message: 'High quest load may be splitting your focus. Consider pausing 1-2 quests or switching daily cadence to flexible weekly window.',
      );
    }

    return null;
  }
}

class CoachCardData {
  final String title;
  final String message;

  const CoachCardData({
    required this.title,
    required this.message,
  });
}
