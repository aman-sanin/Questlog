import '../model/models.dart';
import 'schedule_rule.dart';

class Recurrence {
  /// Walks backward from [from] date, yielding each period's DateRange in reverse chronological order
  /// up to (and including) the period containing [firstCompletion].
  /// Limited to a maximum lookback of 400 days to satisfy lookback constraints.
  static List<DateRange> periodsBackward({
    required LocalDate from,
    required ScheduleRule rule,
    required int weekStart,
    required LocalDate firstCompletion,
  }) {
    final List<DateRange> list = [];
    LocalDate current = from;
    final firstLimit = rule.periodOf(firstCompletion, weekStart).start;

    while (true) {
      final currentPeriod = rule.periodOf(current, weekStart);
      
      // If the period ends before firstCompletion, we stop.
      // Wait, is start or end the boundary? Let's check:
      // "if unit.end < firstCompletion: break // birth grace"
      // So if the period's end date is strictly before firstCompletion, we stop.
      if (currentPeriod.end.isBefore(firstLimit)) {
        break;
      }

      // Add if unique (since stepping back daily could hit same week/month)
      if (list.isEmpty || list.last.start != currentPeriod.start) {
        list.add(currentPeriod);
      }

      // Move current pointer back past the start of this period
      final prevDate = currentPeriod.start.subtract(const Duration(days: 1));
      current = LocalDate.fromDateTime(prevDate);

      // Guard lookback window limit (400 days)
      if (from.differenceInDays(current) > 400) {
        break;
      }
    }

    return list;
  }
}
