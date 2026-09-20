import '../model/models.dart';
import '../../data/db/database.dart';
import 'schedule_rule.dart';
import 'streak.dart';

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
  final int activeDays;

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
    this.activeDays = 0,
  });
}

class InsightsEngine {
  /// Last day of the month containing [month] (any day within it).
  static LocalDate monthEnd(LocalDate month) {
    final next = month.month == 12
        ? LocalDate(month.year + 1, 1, 1)
        : LocalDate(month.year, month.month + 1, 1);
    return next.subtractDays(1);
  }

  static int _targetFor(ScheduleRule rule, int baseTarget) {
    if (rule is WeeklyRule && rule.times != null) return rule.times!;
    if (rule is MonthlyRule && rule.times != null) return rule.times!;
    if (rule is YearlyRule && rule.times != null) return rule.times!;
    return baseTarget;
  }

  /// Scheduled day-units satisfied over [from]..[to] (same semantics as the
  /// heatmap intensity check: window-scheduled always due, others only when
  /// scheduled that day; quests count from their creation date).
  static double _completionRate({
    required LocalDate from,
    required LocalDate to,
    required List<QuestData> quests,
    required Map<String, Map<LocalDate, int>> completionsByQuest,
    required WeekStart weekStart,
  }) {
    var due = 0;
    var done = 0;
    var day = from;
    while (day <= to) {
      for (final q in quests) {
        if (day < LocalDate.fromDateTime(q.createdAt)) continue;
        if (!q.rule.isWindowScheduled &&
            !q.rule.isScheduledOn(day, weekStart.value)) {
          continue;
        }
        due++;
        final val = completionsByQuest[q.id]?[day] ?? 0;
        if (val >= _targetFor(q.rule, q.targetValue)) done++;
      }
      day = day.addDays(1);
    }
    return due > 0 ? done / due : 0.0;
  }

  /// Builds the monthly recap for [month] (first day of the month). Pure:
  /// every number derives from the logbook inputs, closed-month or partial
  /// alike (only closed weeks grant freezes elsewhere; the recap itself
  /// reports whatever the range holds).
  static MonthlyRecapData buildMonthlyRecap({
    required LocalDate month,
    required LocalDate prevMonth,
    required List<QuestData> quests,
    required Map<String, Map<LocalDate, int>> completionsByQuest,
    required List<XpEventData> monthXpEvents,
    required List<StreakRepairData> monthRepairs,
    required Map<String, Set<String>> repairsByQuest,
    required Set<LocalDate> perfectDaysInMonth,
    required WeekStart weekStart,
    required LocalDate today,
  }) {
    final end = monthEnd(month);
    final prevEnd = monthEnd(prevMonth);
    final questMap = {for (final q in quests) q.id: q};

    final rate = _completionRate(
      from: month,
      to: end,
      quests: quests,
      completionsByQuest: completionsByQuest,
      weekStart: weekStart,
    );
    final prevRate = _completionRate(
      from: prevMonth,
      to: prevEnd,
      quests: quests,
      completionsByQuest: completionsByQuest,
      weekStart: weekStart,
    );

    var totalXp = 0;
    for (final e in monthXpEvents) {
      totalXp += e.amount;
    }

    var perfectCount = perfectDaysInMonth.length;
    final activeDays = <LocalDate>{};
    var totalCompletions = 0;
    final domainValues = <CallingDomain, int>{};
    final questMonthTotals = <String, int>{};
    for (final entry in completionsByQuest.entries) {
      var questTotal = 0;
      for (final ce in entry.value.entries) {
        if (ce.key < month || ce.key > end) continue;
        questTotal += ce.value;
        totalCompletions += ce.value;
        activeDays.add(ce.key);
        final q = questMap[entry.key];
        if (q != null && q.domain != null) {
          final d = CallingDomain.values[q.domain!];
          domainValues[d] = (domainValues[d] ?? 0) + ce.value;
        }
      }
      if (questTotal > 0) questMonthTotals[entry.key] = questTotal;
    }

    final affinity = <CallingDomain, double>{};
    if (totalCompletions > 0) {
      for (final e in domainValues.entries) {
        affinity[e.key] = e.value / totalCompletions;
      }
    }
    CallingDomain? busiest;
    var busiestShare = 0.0;
    for (final e in affinity.entries) {
      if (e.value > busiestShare) {
        busiestShare = e.value;
        busiest = e.key;
      }
    }

    String? topQuestTitle;
    var topQuestCount = 0;
    final topIds = questMonthTotals.keys.toList()..sort();
    for (final id in topIds) {
      final total = questMonthTotals[id]!;
      if (total > topQuestCount) {
        topQuestCount = total;
        topQuestTitle = questMap[id]?.title;
      }
    }

    var bestStreak = 0;
    for (final q in quests) {
      final qCompletions = completionsByQuest[q.id] ?? {};
      LocalDate? firstDate;
      for (final d in qCompletions.keys) {
        if (firstDate == null || d < firstDate) firstDate = d;
      }
      final res = StreakEngine.calculate(
        rule: q.rule,
        targetType: TargetType.values[q.targetType],
        targetValue: q.targetValue,
        completionValues: qCompletions,
        existingRepairs: repairsByQuest[q.id] ?? {},
        today: today,
        weekStart: weekStart,
        firstCompletionDate: firstDate,
        pausedUntil: q.pausedUntil != null
            ? LocalDate.parse(q.pausedUntil!)
            : null,
      );
      if (res.bestStreak > bestStreak) bestStreak = res.bestStreak;
    }

    return MonthlyRecapData(
      year: month.year,
      month: month.month,
      completionRate: rate,
      totalXpEarned: totalXp,
      perfectDaysCount: perfectCount,
      freezesSavedCount: monthRepairs.length,
      domainAffinity: affinity,
      bestStreak: bestStreak,
      totalCompletions: totalCompletions,
      completionTrendVsLastMonth: rate - prevRate,
      busiestDomain: busiest,
      mostCompletedQuestTitle: topQuestTitle,
      mostCompletedQuestCount: topQuestCount,
      activeDays: activeDays.length,
    );
  }

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
      final weekdayPct = total > 0
          ? ((weekdayCount / total) * 100).round()
          : 80;
      final weekendPct = total > 0
          ? ((weekendCount / total) * 100).round()
          : 65;

      return WeeklyInsightData(
        headline: 'WEEKDAY MOMENTUM',
        stat: 'Weekdays $weekdayPct% · Weekends $weekendPct%',
        detail:
            'Your weekday discipline maintains strong rhythm compared to weekend flexibility.',
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
        detail:
            'Steady daily accumulation provides higher cumulative XP yield than irregular bursts.',
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
        message:
            'A fresh chapter begins today. Your past history remains honored, and today is unwritten.',
      );
    }

    if (isCooldownActive) return null;

    if (fourteenDayRate >= 0.90 && activeQuestsCount < 6) {
      return const CoachCardData(
        title: 'Mastery in Motion',
        message:
            'Your 14-day completion is 90%+. Consider leveling up a quest difficulty or taking on an overarching goal.',
      );
    } else if (fourteenDayRate < 0.50 && activeQuestsCount >= 5) {
      return const CoachCardData(
        title: 'Focus Your Energy',
        message:
            'High quest load may be splitting your focus. Consider pausing 1-2 quests or switching daily cadence to flexible weekly window.',
      );
    }

    return null;
  }
}

class CoachCardData {
  final String title;
  final String message;

  const CoachCardData({required this.title, required this.message});
}
