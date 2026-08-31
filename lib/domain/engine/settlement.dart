import '../constants/xp_constants.dart';
import '../model/models.dart';
import 'recurrence.dart';
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

    // 1. Process daily / weekly closed bonuses for profile
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
        final bool isEssential = q['essential'] as bool;
        final ScheduleRule rule = q['rule'] as ScheduleRule;
        final String qId = q['id'] as String;

        if (isEssential && !rule.isWindowScheduled && rule.isScheduledOn(currentDay)) {
          essentialScheduledCount++;
          final count = completionsByQuest[qId]?[currentDay] ?? 0;
          final target = q['targetValue'] as int;
          if (count >= target) {
            essentialCompletedCount++;
          }
        }
      }

      if (essentialScheduledCount > 0 && essentialScheduledCount == essentialCompletedCount) {
        final ref = currentDay.formatted;
        if (!existingEventRefs.contains('perfect_day:$ref')) {
          pendingEvents.add(SettlementPendingEvent(
            type: XpEventType.perfectDay,
            ref: ref,
            amount: XpConstants.perfectDayBonus,
            localDate: currentDay,
          ));
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
