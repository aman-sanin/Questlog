import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/domain/engine/schedule_rule.dart';
import 'package:questlog/domain/engine/recurrence.dart';
import 'package:questlog/domain/model/models.dart';

void main() {
  group('DailyRule Tests', () {
    test('Every day rule schedules on every day', () {
      final rule = DailyRule.everyDay();
      expect(rule.isScheduledOn(LocalDate(2026, 8, 30), 1), isTrue);
      expect(rule.isScheduledOn(LocalDate(2026, 8, 31), 1), isTrue);
    });

    test('Weekdays rule schedules only on specified days', () {
      // 2026-08-31 is Monday (1)
      // 2026-09-01 is Tuesday (2)
      final rule = DailyRule.weekdays([1, 3, 5]); // Mon, Wed, Fri
      expect(rule.isScheduledOn(LocalDate(2026, 8, 31), 1), isTrue);
      expect(rule.isScheduledOn(LocalDate(2026, 9, 1), 1), isFalse);
    });

    test('Interval rule schedules based on anchor', () {
      // Anchor: 2026-08-30
      final anchor = LocalDate(2026, 8, 30);
      final rule = DailyRule.interval(3, anchor); // Every 3 days

      expect(rule.isScheduledOn(LocalDate(2026, 8, 30), 1), isTrue);
      expect(rule.isScheduledOn(LocalDate(2026, 8, 31), 1), isFalse);
      expect(rule.isScheduledOn(LocalDate(2026, 9, 2), 1), isTrue); // 3 days later
    });
  });

  group('WeeklyRule Tests', () {
    test('Weekly times rule is window-scheduled and open on all days', () {
      final rule = WeeklyRule.times(3);
      expect(rule.isWindowScheduled, isTrue);
      expect(rule.isScheduledOn(LocalDate(2026, 8, 30), 1), isTrue);
    });

    test('Weekly periodOf calculates correct range based on weekStart', () {
      // 2026-08-30 is Sunday
      // If weekStart = 1 (Monday), week starts on 2026-08-24 (Monday) and ends on 2026-08-30 (Sunday)
      final rule = WeeklyRule.times(1);
      final range = rule.periodOf(LocalDate(2026, 8, 30), 1);
      expect(LocalDate.fromDateTime(range.start).dateString, '2026-08-24');
      expect(LocalDate.fromDateTime(range.end).dateString, '2026-08-30');
    });
  });

  group('MonthlyRule Tests', () {
    test('nth_weekday works correctly', () {
      // 2026-09-08 is second Tuesday of Sept 2026 (Sept 1 is Tuesday, Sept 8 is 2nd Tuesday)
      final rule = MonthlyRule.nthWeekday(2, 2); // 2nd Tuesday
      expect(rule.isScheduledOn(LocalDate(2026, 9, 8), 1), isTrue);
      expect(rule.isScheduledOn(LocalDate(2026, 9, 1), 1), isFalse);
      expect(rule.isScheduledOn(LocalDate(2026, 9, 15), 1), isFalse);
    });

    test('last_day works correctly', () {
      final rule = MonthlyRule.lastDay();
      expect(rule.isScheduledOn(LocalDate(2026, 8, 31), 1), isTrue);
      expect(rule.isScheduledOn(LocalDate(2026, 8, 30), 1), isFalse);
    });
  });

  group('Recurrence.periodsBackward Tests', () {
    test('periodsBackward returns correct list of weekly periods', () {
      final rule = WeeklyRule.times(1);
      final from = LocalDate(2026, 8, 30); // Sunday
      final firstCompletion = LocalDate(2026, 8, 10); // Monday (3 weeks prior range start)

      final periods = Recurrence.periodsBackward(
        from: from,
        rule: rule,
        weekStart: 1,
        firstCompletion: firstCompletion,
      );

      // Should return 3 periods:
      // Week 1: Aug 24 - Aug 30
      // Week 2: Aug 17 - Aug 23
      // Week 3: Aug 10 - Aug 16
      expect(periods.length, 3);
      expect(LocalDate.fromDateTime(periods[0].start).dateString, '2026-08-24');
      expect(LocalDate.fromDateTime(periods[1].start).dateString, '2026-08-17');
      expect(LocalDate.fromDateTime(periods[2].start).dateString, '2026-08-10');
    });
  });
}
