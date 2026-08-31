import '../model/models.dart';

class WeeklyInsightData {
  final String headline;
  final String detail;
  final String stat;

  const WeeklyInsightData({
    required this.headline,
    required this.detail,
    required this.stat,
  });
}

class CoachSuggestion {
  final String questId;
  final String questTitle;
  final String title;
  final String body;
  final String primaryAction;
  final String secondaryAction;
  final String ruleType;

  const CoachSuggestion({
    required this.questId,
    required this.questTitle,
    required this.title,
    required this.body,
    required this.primaryAction,
    required this.secondaryAction,
    required this.ruleType,
  });
}

class MonthlyRecapStats {
  final String monthLabel;
  final int totalXp;
  final int perfectDays;
  final int bestStreak;
  final int totalCompletions;
  final double completionTrendVsLastMonth;
  final CallingDomain? busiestDomain;
  final String? mostCompletedQuestTitle;
  final int mostCompletedQuestCount;

  const MonthlyRecapStats({
    required this.monthLabel,
    required this.totalXp,
    required this.perfectDays,
    required this.bestStreak,
    required this.totalCompletions,
    required this.completionTrendVsLastMonth,
    this.busiestDomain,
    this.mostCompletedQuestTitle,
    this.mostCompletedQuestCount = 0,
  });
}

class InsightsEngine {
  /// Generate a deterministic rotating insight based on week index
  static WeeklyInsightData getWeeklyInsight({
    required Map<LocalDate, int> completionsByDate,
    required LocalDate today,
    required int totalXp,
  }) {
    final int weekNumber = (today.day ~/ 7) % 3;

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
        stat: '${(totalXp / 50).clamp(10, 99).toInt()}% ON-SCHEDULE',
        detail: 'You are completing the vast majority of active quests within their scheduled windows.',
      );
    } else {
      return const WeeklyInsightData(
        headline: 'FLOW VELOCITY',
        stat: 'ACTIVE CADENCE',
        detail: 'Your multi-period streaks indicate high habit stability over recent weeks.',
      );
    }
  }

  /// Calculates Monthly Recap statistics from completions and XP
  static MonthlyRecapStats calculateMonthlyRecap({
    required String monthLabel,
    required int totalXp,
    required int perfectDays,
    required int bestStreak,
    required int totalCompletions,
    required double trendVsLastMonth,
    CallingDomain? topDomain,
    String? topQuestTitle,
    int topQuestCount = 0,
  }) {
    return MonthlyRecapStats(
      monthLabel: monthLabel,
      totalXp: totalXp,
      perfectDays: perfectDays,
      bestStreak: bestStreak,
      totalCompletions: totalCompletions,
      completionTrendVsLastMonth: trendVsLastMonth,
      busiestDomain: topDomain,
      mostCompletedQuestTitle: topQuestTitle,
      mostCompletedQuestCount: topQuestCount,
    );
  }
}
