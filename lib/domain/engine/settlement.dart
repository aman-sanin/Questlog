import '../constants/xp_constants.dart';
import '../model/models.dart';
import 'schedule_rule.dart';

class SettlementPendingEvent {
  final XpEventType type;
  final String ref;
  final String? periodRef;
  final int amount;
  final LocalDate localDate;

  const SettlementPendingEvent({
    required this.type,
    required this.ref,
    this.periodRef,
    required this.amount,
    required this.localDate,
  });
}

class SettlementResult {
  final List<SettlementPendingEvent> newEvents;
  final Map<String, LocalDate> questSettledThrough;
  final LocalDate? profileSettledThrough;

  const SettlementResult({
    required this.newEvents,
    required this.questSettledThrough,
    this.profileSettledThrough,
  });
}

class SettlementEngine {
  static SettlementResult settle({
    required List<Map<String, dynamic>> questsData,
    required Map<String, Map<LocalDate, int>> completionsByQuest,
    required LocalDate? profileSettledThrough,
    required LocalDate today,
    required WeekStart weekStart,
    required Set<String> existingEventRefs,
  }) {
    final List<SettlementPendingEvent> pendingEvents = [];
    final Map<String, LocalDate> newQuestMarkers = {};

    final yesterday = today.subtractDays(1);

    // 1. Process daily closed bonuses for profile
    LocalDate currentDay = profileSettledThrough != null
        ? profileSettledThrough.addDays(1)
        : today.subtractDays(30);

    if (currentDay < today.subtractDays(60)) {
      currentDay = today.subtractDays(60);
    }

    while (currentDay <= yesterday) {
      // Check Perfect Day for currentDay
      // Perfect Day = >=1 day-scheduled essential quest scheduled that day, and all satisfied
      int essentialScheduledCount = 0;
      int essentialCompletedCount = 0;

      for (final q in questsData) {
        final bool isEssential = q['essential'] as bool? ?? false;
        final ScheduleRule rule = q['rule'] as ScheduleRule;
        final String qId = q['id'] as String;

        if (isEssential && !rule.isWindowScheduled && rule.isScheduledOn(currentDay, weekStart.value)) {
          essentialScheduledCount++;
          final count = completionsByQuest[qId]?[currentDay] ?? 0;
          final target = q['targetValue'] as int? ?? 1;
          if (count >= target) {
            essentialCompletedCount++;
          }
        }
      }

      if (essentialScheduledCount > 0 && essentialScheduledCount == essentialCompletedCount) {
        final refKey = 'perfect_day:${currentDay.formatted}';
        if (!existingEventRefs.contains(refKey)) {
          pendingEvents.add(SettlementPendingEvent(
            type: XpEventType.perfectDay,
            ref: refKey,
            amount: XpConstants.perfectDayBonus,
            localDate: currentDay,
          ));
        }
      }

      // Check closed weekly periods if currentDay is the end of a week
      final currentWeekday = currentDay.toDateTime().weekday; // 1=Mon, 7=Sun
      final isWeekEnd = (weekStart == WeekStart.monday && currentWeekday == 7) ||
          (weekStart == WeekStart.sunday && currentWeekday == 6);

      if (isWeekEnd) {
        final weekRange = WeeklyRule.times(1).periodOf(currentDay, weekStart.value);
        final weekStartDay = weekRange.startLocalDate;
        final weekEndDay = weekRange.endLocalDate;

        int scheduledQuestsCount = 0;
        int satisfiedQuestsCount = 0;

        for (final q in questsData) {
          final ScheduleRule rule = q['rule'] as ScheduleRule;
          final String qId = q['id'] as String;
          final qCompletions = completionsByQuest[qId] ?? {};

          int target = q['targetValue'] as int? ?? 1;
          if (rule is WeeklyRule && rule.times != null) target = rule.times!;

          // Total completions in week (honoring allowedDays constraint if specified)
          int weekCount = 0;
          for (final entry in qCompletions.entries) {
            if (entry.key >= weekStartDay && entry.key <= weekEndDay) {
              if (rule is WeeklyRule && rule.allowedDays != null && rule.allowedDays!.isNotEmpty) {
                if (rule.allowedDays!.contains(entry.key.toDateTime().weekday)) {
                  weekCount += entry.value;
                }
              } else {
                weekCount += entry.value;
              }
            }
          }

          bool wasScheduled = false;
          if (rule.isWindowScheduled) {
            wasScheduled = true;
          } else {
            // Check if scheduled on any day of the week
            LocalDate d = weekStartDay;
            while (d <= weekEndDay) {
              if (rule.isScheduledOn(d, weekStart.value)) {
                wasScheduled = true;
                break;
              }
              d = d.addDays(1);
            }
          }

          if (wasScheduled) {
            scheduledQuestsCount++;
            if (weekCount >= target) {
              satisfiedQuestsCount++;
            }
          }
        }

        if (scheduledQuestsCount > 0 && scheduledQuestsCount == satisfiedQuestsCount) {
          final refKey = 'perfect_week:${weekStartDay.formatted}';
          if (!existingEventRefs.contains(refKey)) {
            pendingEvents.add(SettlementPendingEvent(
              type: XpEventType.perfectWeek,
              ref: refKey,
              amount: XpConstants.perfectWeekBonus,
              localDate: weekEndDay,
            ));
          }
        }
      }

      currentDay = currentDay.addDays(1);
    }

    return SettlementResult(
      newEvents: pendingEvents,
      questSettledThrough: newQuestMarkers,
      profileSettledThrough: yesterday,
    );
  }
}
