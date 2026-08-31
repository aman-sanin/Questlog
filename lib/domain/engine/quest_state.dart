import '../model/models.dart';
import 'schedule_rule.dart';

class QuestEvaluation {
  final String questId;
  final String title;
  final ScheduleRule rule;
  final TargetType targetType;
  final int targetValue;
  final String? unit;
  final Difficulty difficulty;
  final bool essential;
  final String? goalId;
  final CallingDomain? domain;
  final LocalDate? pausedUntil;

  // Evaluated state properties
  final bool isDueToday;
  final int completedValue;
  final int target;
  final double progress;
  final bool isCompleted;
  final int streak;
  final QuestVisual visualState;
  final WindowInfo? windowInfo;
  final String metaDescription;

  const QuestEvaluation({
    required this.questId,
    required this.title,
    required this.rule,
    required this.targetType,
    required this.targetValue,
    this.unit,
    required this.difficulty,
    required this.essential,
    this.goalId,
    this.domain,
    this.pausedUntil,
    required this.isDueToday,
    required this.completedValue,
    required this.target,
    required this.progress,
    required this.isCompleted,
    required this.streak,
    required this.visualState,
    this.windowInfo,
    required this.metaDescription,
  });

  static QuestEvaluation evaluate({
    required String questId,
    required String title,
    required ScheduleRule rule,
    required TargetType targetType,
    required int targetValue,
    String? unit,
    required Difficulty difficulty,
    required bool essential,
    String? goalId,
    CallingDomain? domain,
    LocalDate? pausedUntil,
    required List<LocalDate> completionDates,
    required Map<LocalDate, int> completionValues,
    required LocalDate today,
    required DateTime now,
    required WeekStart weekStart,
    LocalDate? firstCompletionDate,
    required int streak,
    bool hasFreezeSavedYesterday = false,
  }) {
    final period = rule.periodOf(today, weekStart.value);
    final isWindow = rule.isWindowScheduled;
    final isDue = isWindow
        ? period.contains(today)
        : rule.isScheduledOn(today, weekStart.value);

    // Calculate completions in current period (honoring allowedDays if constrained)
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

    int target = targetValue;
    if (rule is WeeklyRule && rule.times != null) target = rule.times!;
    if (rule is MonthlyRule && rule.times != null) target = rule.times!;
    if (rule is YearlyRule && rule.times != null) target = rule.times!;

    final double progress = target == 0 ? 1.0 : (periodCompleted / target).clamp(0.0, 2.0);
    final bool completed = periodCompleted >= target;
    final bool overachieved = periodCompleted > target;

    // Check pause state
    final bool isPaused = pausedUntil != null && pausedUntil >= today;

    // Check at risk: day scheduled, open, 18h into the day
    final bool isAtRisk = !completed && !isWindow && isDue && now.hour >= 18;

    // Check yesterday's miss for day-scheduled quests
    final yesterday = today.subtractDays(1);
    bool missedYesterday = false;
    if (!isWindow &&
        firstCompletionDate != null &&
        yesterday >= firstCompletionDate &&
        rule.isScheduledOn(yesterday, weekStart.value)) {
      final yVal = completionValues[yesterday] ?? 0;
      if (yVal < target && !hasFreezeSavedYesterday) {
        missedYesterday = true;
      }
    }

    // Determine visual state
    QuestVisual visual;
    if (isPaused) {
      visual = QuestVisual.paused;
    } else if (overachieved) {
      visual = QuestVisual.overachieved;
    } else if (completed) {
      visual = QuestVisual.completed;
    } else if (isAtRisk) {
      visual = QuestVisual.atRisk;
    } else if (missedYesterday && !isDue) {
      visual = essential ? QuestVisual.missedEssential : QuestVisual.missedNonEssential;
    } else if (firstCompletionDate == null && !isDue) {
      visual = QuestVisual.grace;
    } else {
      visual = QuestVisual.pending;
    }

    // Window info for window quests
    WindowInfo? winInfo;
    if (isWindow) {
      final daysLeft = period.endLocalDate.differenceInDays(today) + 1;
      winInfo = WindowInfo(
        currentCount: periodCompleted,
        targetCount: target,
        daysLeftInPeriod: daysLeft > 0 ? daysLeft : 0,
      );
    }

    // Compose mono meta description (e.g., "DAILY · 2/3 GLASSES · 23 STREAK")
    final metaParts = <String>[];
    metaParts.add(rule.cadence.name.toUpperCase());
    if (targetType == TargetType.counter) {
      metaParts.add('$periodCompleted/$target ${unit != null && unit.isNotEmpty ? unit.toUpperCase() : "TODAY"}');
    }
    if (streak > 0) {
      metaParts.add('$streak ${rule.cadence == Cadence.daily ? "STREAK" : "PERIODS"}');
    }
    if (hasFreezeSavedYesterday) {
      metaParts.add('STREAK SAVED · ❄');
    } else if (isPaused) {
      metaParts.add('PAUSED UNTIL ${pausedUntil?.formatted}');
    } else if (winInfo != null && !completed) {
      metaParts.add('${winInfo.daysLeftInPeriod} DAYS LEFT');
    } else if (missedYesterday) {
      metaParts.add('MISSED YESTERDAY');
    } else if (firstCompletionDate == null) {
      metaParts.add('STARTS WITH 1ST COMPLETION');
    }

    return QuestEvaluation(
      questId: questId,
      title: title,
      rule: rule,
      targetType: targetType,
      targetValue: targetValue,
      unit: unit,
      difficulty: difficulty,
      essential: essential,
      goalId: goalId,
      domain: domain,
      pausedUntil: pausedUntil,
      isDueToday: isDue,
      completedValue: periodCompleted,
      target: target,
      progress: progress,
      isCompleted: completed,
      streak: streak,
      visualState: visual,
      windowInfo: winInfo,
      metaDescription: metaParts.join(' · '),
    );
  }
}
