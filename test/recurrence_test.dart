import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/domain/engine/recurrence.dart';
import 'package:questlog/domain/engine/schedule_rule.dart';
import 'package:questlog/domain/model/models.dart';

void main() {
  group('Group A: Recurrence Properties', () {
    test('MWF rule over a full year (2025): never yields Sat/Sun, exactly 157 days', () {
      final rule = const DailyWeekdaysRule(days: [1, 3, 5]); // Mon, Wed, Fri
      int scheduledCount = 0;
      int satSunCount = 0;

      LocalDate d = const LocalDate(2025, 1, 1);
      final end = const LocalDate(2025, 12, 31);

      while (d <= end) {
        if (rule.isScheduledOn(d)) {
          scheduledCount++;
          final weekday = d.toDateTime().weekday;
          if (weekday == 6 || weekday == 7) {
            satSunCount++;
          }
        }
        d = d.addDays(1);
      }

      expect(satSunCount, equals(0));
      expect(scheduledCount, equals(157)); // 52 Mondays + 53 Wednesdays + 52 Fridays = 157
    });

    test('every_day over a normal year (2025) yields 365, leap year (2024) yields 366', () {
      const rule = DailyEveryDayRule();

      int count2025 = 0;
      LocalDate d2025 = const LocalDate(2025, 1, 1);
      while (d2025 <= const LocalDate(2025, 12, 31)) {
        if (rule.isScheduledOn(d2025)) count2025++;
        d2025 = d2025.addDays(1);
      }
      expect(count2025, equals(365));

      int count2024 = 0;
      LocalDate d2024 = const LocalDate(2024, 1, 1);
      while (d2024 <= const LocalDate(2024, 12, 31)) {
        if (rule.isScheduledOn(d2024)) count2024++;
        d2024 = d2024.addDays(1);
      }
      expect(count2024, equals(366));
    });

    test('Interval n=3, anchored at 2025-01-01: scheduled exactly every 3rd day', () {
      final anchor = const LocalDate(2025, 1, 1);
      final rule = DailyIntervalRule(count: 3, anchor: anchor);

      expect(rule.isScheduledOn(const LocalDate(2025, 1, 1)), isTrue);
      expect(rule.isScheduledOn(const LocalDate(2025, 1, 2)), isFalse);
      expect(rule.isScheduledOn(const LocalDate(2025, 1, 3)), isFalse);
      expect(rule.isScheduledOn(const LocalDate(2025, 1, 4)), isTrue);
      expect(rule.isScheduledOn(const LocalDate(2025, 1, 7)), isTrue);
      expect(rule.isScheduledOn(const LocalDate(2025, 1, 10)), isTrue);
    });

    test('2nd Tuesday: exactly one day per month in every month of the year', () {
      const rule = MonthlyNthWeekdayRule(nth: 2, weekday: 2); // 2nd Tuesday

      for (int month = 1; month <= 12; month++) {
        int tuesdayCount = 0;
        final daysInMonth = MonthlyRule.daysInMonth(2025, month);
        for (int day = 1; day <= daysInMonth; day++) {
          final date = LocalDate(2025, month, day);
          if (rule.isScheduledOn(date)) {
            tuesdayCount++;
            expect(date.toDateTime().weekday, equals(2));
          }
        }
        expect(tuesdayCount, equals(1), reason: 'Month $month should have exactly 1 2nd Tuesday');
      }
    });

    test('day_of_month: 31 in June clamps to June 30 (clamped, not vanished)', () {
      const rule = MonthlyDayOfMonthRule(day: 31);

      // June has 30 days
      expect(rule.isScheduledOn(const LocalDate(2025, 6, 30)), isTrue);
      expect(rule.isScheduledOn(const LocalDate(2025, 6, 29)), isFalse);

      // July has 31 days
      expect(rule.isScheduledOn(const LocalDate(2025, 7, 31)), isTrue);
      expect(rule.isScheduledOn(const LocalDate(2025, 7, 30)), isFalse);
    });

    test('Feb 29 in non-leap year (2025) fires Feb 28; in leap year (2024) fires Feb 29', () {
      const rule = YearlyDateRule(month: 2, day: 29);

      // Non-leap year 2025
      expect(rule.isScheduledOn(const LocalDate(2025, 2, 28)), isTrue);
      expect(rule.isScheduledOn(const LocalDate(2025, 2, 27)), isFalse);

      // Leap year 2024
      expect(rule.isScheduledOn(const LocalDate(2024, 2, 29)), isTrue);
      expect(rule.isScheduledOn(const LocalDate(2024, 2, 28)), isFalse);
    });

    test('last_day rule correctly identifies last day for 28, 29, 30, and 31-day months', () {
      const rule = MonthlyLastDayRule();

      expect(rule.isScheduledOn(const LocalDate(2025, 2, 28)), isTrue);
      expect(rule.isScheduledOn(const LocalDate(2024, 2, 29)), isTrue);
      expect(rule.isScheduledOn(const LocalDate(2025, 4, 30)), isTrue);
      expect(rule.isScheduledOn(const LocalDate(2025, 5, 31)), isTrue);
      expect(rule.isScheduledOn(const LocalDate(2025, 5, 30)), isFalse);
    });

    test('Week of Dec 29, 2025 – Jan 4, 2026: correct single period key for Monday and Sunday week starts', () {
      const rule = WeeklyTimesRule(times: 3);

      final dec30 = const LocalDate(2025, 12, 30); // Tuesday
      final jan2 = const LocalDate(2026, 1, 2);   // Friday

      // Monday week start (2025-12-29 to 2026-01-04)
      final pKeyDec30Mon = rule.periodKey(dec30, 1);
      final pKeyJan2Mon = rule.periodKey(jan2, 1);
      expect(pKeyDec30Mon, equals('W:2025-12-29'));
      expect(pKeyJan2Mon, equals('W:2025-12-29'));
      expect(pKeyDec30Mon, equals(pKeyJan2Mon));

      // Sunday week start
      final pKeyDec30Sun = rule.periodKey(dec30, 7);
      final pKeyJan2Sun = rule.periodKey(jan2, 7);
      expect(pKeyDec30Sun, equals('W:2025-12-28'));
      expect(pKeyJan2Sun, equals('W:2025-12-28'));
      expect(pKeyDec30Sun, equals(pKeyJan2Sun));
    });

    test('5th-Friday rule: zero scheduled Fridays in 4-Friday months', () {
      const rule = MonthlyNthWeekdayRule(nth: 5, weekday: 5); // 5th Friday

      // February 2025 has 4 Fridays (Feb 7, 14, 21, 28)
      int scheduledCountFeb = 0;
      for (int d = 1; d <= 28; d++) {
        if (rule.isScheduledOn(LocalDate(2025, 2, d))) {
          scheduledCountFeb++;
        }
      }
      expect(scheduledCountFeb, equals(0));

      // May 2025 has 5 Fridays (May 2, 9, 16, 23, 30)
      int scheduledCountMay = 0;
      for (int d = 1; d <= 31; d++) {
        if (rule.isScheduledOn(LocalDate(2025, 5, d))) {
          scheduledCountMay++;
        }
      }
      expect(scheduledCountMay, equals(1));
    });
  });
}
