import '../model/models.dart';

abstract class ScheduleRule {
  const ScheduleRule();

  Cadence get cadence;
  bool isScheduledOn(LocalDate d, [dynamic weekStart]);
  String periodKey(LocalDate d, [dynamic weekStart]);
  DateRange periodOf(LocalDate d, [dynamic weekStart]);
  bool get isWindowScheduled;
  Map<String, dynamic> toJson();

  static int resolveWeekStart(dynamic ws) {
    if (ws is WeekStart) return ws.value;
    if (ws is int) return ws;
    return 1;
  }

  static ScheduleRule fromJson(Map<String, dynamic> json) {
    final cadenceStr = json['cadence'] as String?;
    final cadence = Cadence.values.firstWhere(
      (e) => e.name == cadenceStr,
      orElse: () => Cadence.daily,
    );
    final mode = json['mode'] as String?;

    switch (cadence) {
      case Cadence.daily:
        return DailyRule.fromJson(mode, json);
      case Cadence.weekly:
        return WeeklyRule.fromJson(mode, json);
      case Cadence.monthly:
        return MonthlyRule.fromJson(mode, json);
      case Cadence.yearly:
        return YearlyRule.fromJson(mode, json);
      case Cadence.single:
        return SingleRule.fromJson(json);
    }
  }
}

class DailyRule extends ScheduleRule {
  @override
  final Cadence cadence = Cadence.daily;
  final String mode; // every_day, weekdays, interval
  final List<int>? weekdays; // 1-7
  final int? interval;
  final LocalDate? anchor;

  const DailyRule.everyDay() : mode = 'every_day', weekdays = null, interval = null, anchor = null;
  const DailyRule.weekdays(List<int> days) : mode = 'weekdays', weekdays = days, interval = null, anchor = null;
  const DailyRule.interval(int count, LocalDate anchorDate) : mode = 'interval', weekdays = null, interval = count, anchor = anchorDate;

  factory DailyRule.fromJson(String? mode, Map<String, dynamic> json) {
    if (mode == 'weekdays') {
      final list = (json['weekdays'] as List?)?.map((e) => e as int).toList();
      return DailyRule.weekdays(list ?? [1, 2, 3, 4, 5, 6, 7]);
    } else if (mode == 'interval') {
      final interval = json['interval'] as int? ?? 1;
      final anchorStr = json['anchor'] as String?;
      final anchor = anchorStr != null ? LocalDate.parse(anchorStr) : LocalDate(2026, 1, 1);
      return DailyRule.interval(interval, anchor);
    }
    return const DailyRule.everyDay();
  }

  @override
  bool get isWindowScheduled => false;

  @override
  bool isScheduledOn(LocalDate d, [dynamic weekStart]) {
    if (mode == 'every_day') return true;
    if (mode == 'weekdays') {
      return weekdays?.contains(d.toDateTime().weekday) ?? false;
    }
    if (mode == 'interval') {
      if (anchor == null || interval == null || interval! <= 0) return false;
      final diff = d.differenceInDays(anchor!);
      return diff >= 0 && (diff % interval!) == 0;
    }
    return false;
  }

  @override
  String periodKey(LocalDate d, [dynamic weekStart]) {
    return d.dateString;
  }

  @override
  DateRange periodOf(LocalDate d, [dynamic weekStart]) {
    final dt = d.toDateTime();
    return DateRange(dt, dt);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'cadence': cadence.name,
      'mode': mode,
      if (weekdays != null) 'weekdays': weekdays,
      if (interval != null) 'interval': interval,
      if (anchor != null) 'anchor': anchor!.dateString,
    };
  }
}

class DailyEveryDayRule extends DailyRule {
  const DailyEveryDayRule() : super.everyDay();
}

class DailyWeekdaysRule extends DailyRule {
  const DailyWeekdaysRule({required List<int> days}) : super.weekdays(days);
}

class DailyIntervalRule extends DailyRule {
  const DailyIntervalRule({required int count, required LocalDate anchor}) : super.interval(count, anchor);
}

class WeeklyRule extends ScheduleRule {
  @override
  final Cadence cadence = Cadence.weekly;
  final String mode; // times, on_days
  final int? times;
  final List<int>? onDays; // weekdays 1-7 (for on_days mode)
  final List<int>? allowedDays; // weekdays 1-7 (for constrained times mode)

  const WeeklyRule.times(int count, [this.allowedDays])
      : mode = 'times',
        times = count,
        onDays = null;
  const WeeklyRule.onDays(List<int> days)
      : mode = 'on_days',
        times = null,
        onDays = days,
        allowedDays = null;

  factory WeeklyRule.fromJson(String? mode, Map<String, dynamic> json) {
    if (mode == 'on_days') {
      final list = (json['on_days'] as List?)?.map((e) => e as int).toList();
      return WeeklyRule.onDays(list ?? [1]);
    }
    final times = json['times'] as int? ?? 1;
    final allowed = (json['allowed_days'] as List?)?.map((e) => e as int).toList();
    return WeeklyRule.times(times, allowed);
  }

  @override
  bool get isWindowScheduled => mode == 'times';

  @override
  bool isScheduledOn(LocalDate d, [dynamic weekStart]) {
    if (mode == 'times') {
      if (allowedDays != null && allowedDays!.isNotEmpty) {
        return allowedDays!.contains(d.toDateTime().weekday);
      }
      return true; // window is open all days of the week
    }
    if (mode == 'on_days') {
      return onDays?.contains(d.toDateTime().weekday) ?? false;
    }
    return false;
  }

  @override
  String periodKey(LocalDate d, [dynamic weekStart]) {
    final range = periodOf(d, weekStart);
    return 'W:${range.start.toIso8601String().substring(0, 10)}';
  }

  @override
  DateRange periodOf(LocalDate d, [dynamic weekStart]) {
    final ws = ScheduleRule.resolveWeekStart(weekStart);
    final dt = d.toDateTime();
    final currentWeekday = dt.weekday;
    int diff = currentWeekday - ws;
    if (diff < 0) diff += 7;
    final start = dt.subtract(Duration(days: diff));
    final end = start.add(const Duration(days: 6));
    return DateRange(start, end);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'cadence': cadence.name,
      'mode': mode,
      if (times != null) 'times': times,
      if (onDays != null) 'on_days': onDays,
      if (allowedDays != null) 'allowed_days': allowedDays,
    };
  }
}

class WeeklyTimesRule extends WeeklyRule {
  const WeeklyTimesRule({required int times, List<int>? allowedDays})
      : super.times(times, allowedDays);
}

class WeeklyOnDaysRule extends WeeklyRule {
  const WeeklyOnDaysRule({required List<int> days}) : super.onDays(days);
}

class MonthlyRule extends ScheduleRule {
  @override
  final Cadence cadence = Cadence.monthly;
  final String mode; // times, day_of_month, nth_weekday, last_day
  final int? times;
  final int? dayOfMonth; // 1-31
  final int? nth; // 1-5
  final int? weekday; // 1-7
  final bool? lastDay;

  const MonthlyRule.times(int count)
      : mode = 'times',
        times = count,
        dayOfMonth = null,
        nth = null,
        weekday = null,
        lastDay = null;

  const MonthlyRule.dayOfMonth(int day)
      : mode = 'day_of_month',
        times = null,
        dayOfMonth = day,
        nth = null,
        weekday = null,
        lastDay = null;

  const MonthlyRule.nthWeekday(int n, int day)
      : mode = 'nth_weekday',
        times = null,
        dayOfMonth = null,
        nth = n,
        weekday = day,
        lastDay = null;

  const MonthlyRule.lastDay()
      : mode = 'last_day',
        times = null,
        dayOfMonth = null,
        nth = null,
        weekday = null,
        lastDay = true;

  factory MonthlyRule.fromJson(String? mode, Map<String, dynamic> json) {
    if (mode == 'day_of_month') {
      return MonthlyRule.dayOfMonth(json['day_of_month'] as int? ?? 1);
    } else if (mode == 'nth_weekday') {
      return MonthlyRule.nthWeekday(
        json['nth'] as int? ?? 1,
        json['weekday'] as int? ?? 1,
      );
    } else if (mode == 'last_day') {
      return const MonthlyRule.lastDay();
    }
    final times = json['times'] as int? ?? 1;
    return MonthlyRule.times(times);
  }

  @override
  bool get isWindowScheduled => mode == 'times';

  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  @override
  bool isScheduledOn(LocalDate d, [dynamic weekStart]) {
    if (mode == 'times') return true; // window open all month
    if (mode == 'day_of_month') {
      final maxDays = daysInMonth(d.year, d.month);
      final targetDay = dayOfMonth!.clamp(1, maxDays);
      return d.day == targetDay;
    }
    if (mode == 'nth_weekday') {
      if (nth == null || weekday == null) return false;
      final isMatchingWeekday = d.toDateTime().weekday == weekday;
      if (!isMatchingWeekday) return false;
      final computedNth = (d.day - 1) ~/ 7 + 1;
      return computedNth == nth;
    }
    if (mode == 'last_day') {
      return d.day == daysInMonth(d.year, d.month);
    }
    return false;
  }

  @override
  String periodKey(LocalDate d, [dynamic weekStart]) {
    final mStr = d.month.toString().padLeft(2, '0');
    return 'M:${d.year}-$mStr';
  }

  @override
  DateRange periodOf(LocalDate d, [dynamic weekStart]) {
    final start = DateTime(d.year, d.month, 1);
    final end = DateTime(d.year, d.month, daysInMonth(d.year, d.month));
    return DateRange(start, end);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'cadence': cadence.name,
      'mode': mode,
      if (times != null) 'times': times,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (nth != null) 'nth': nth,
      if (weekday != null) 'weekday': weekday,
      if (lastDay != null) 'last_day': lastDay,
    };
  }
}

class MonthlyTimesRule extends MonthlyRule {
  const MonthlyTimesRule({required int times}) : super.times(times);
}

class MonthlyDayOfMonthRule extends MonthlyRule {
  const MonthlyDayOfMonthRule({required int day}) : super.dayOfMonth(day);
}

class MonthlyNthWeekdayRule extends MonthlyRule {
  const MonthlyNthWeekdayRule({required int nth, required int weekday}) : super.nthWeekday(nth, weekday);
}

class MonthlyLastDayRule extends MonthlyRule {
  const MonthlyLastDayRule() : super.lastDay();
}

class YearlyRule extends ScheduleRule {
  @override
  final Cadence cadence = Cadence.yearly;
  final String mode; // date, times
  final int? month; // 1-12
  final int? day; // 1-31
  final int? times;

  const YearlyRule.date(int m, int d)
      : mode = 'date',
        month = m,
        day = d,
        times = null;

  const YearlyRule.times(int count)
      : mode = 'times',
        times = count,
        month = null,
        day = null;

  factory YearlyRule.fromJson(String? mode, Map<String, dynamic> json) {
    if (mode == 'times') {
      return YearlyRule.times(json['times'] as int? ?? 1);
    }
    return YearlyRule.date(
      json['month'] as int? ?? 1,
      json['day'] as int? ?? 1,
    );
  }

  @override
  bool get isWindowScheduled => mode == 'times';

  @override
  bool isScheduledOn(LocalDate d, [dynamic weekStart]) {
    if (mode == 'times') return true; // window open all year
    if (mode == 'date') {
      final maxDays = MonthlyRule.daysInMonth(d.year, month!);
      final targetDay = day!.clamp(1, maxDays);
      return d.month == month && d.day == targetDay;
    }
    return false;
  }

  @override
  String periodKey(LocalDate d, [dynamic weekStart]) {
    return 'Y:${d.year}';
  }

  @override
  DateRange periodOf(LocalDate d, [dynamic weekStart]) {
    final start = DateTime(d.year, 1, 1);
    final end = DateTime(d.year, 12, 31);
    return DateRange(start, end);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'cadence': cadence.name,
      'mode': mode,
      if (month != null) 'month': month,
      if (day != null) 'day': day,
      if (times != null) 'times': times,
    };
  }
}

class YearlyDateRule extends YearlyRule {
  const YearlyDateRule({required int month, required int day}) : super.date(month, day);
}

class YearlyTimesRule extends YearlyRule {
  const YearlyTimesRule({required int times}) : super.times(times);
}

class SingleRule extends ScheduleRule {
  @override
  final Cadence cadence = Cadence.single;
  final LocalDate? targetDate;

  const SingleRule({this.targetDate});

  factory SingleRule.fromJson(Map<String, dynamic> json) {
    final dateStr = json['target_date'] as String?;
    return SingleRule(
      targetDate: dateStr != null ? LocalDate.parse(dateStr) : null,
    );
  }

  @override
  bool get isWindowScheduled => false;

  @override
  bool isScheduledOn(LocalDate d, [dynamic weekStart]) {
    if (targetDate != null) {
      return d == targetDate;
    }
    return true;
  }

  @override
  String periodKey(LocalDate d, [dynamic weekStart]) {
    return targetDate != null ? 'single_${targetDate!.formatted}' : 'single_any';
  }

  @override
  DateRange periodOf(LocalDate d, [dynamic weekStart]) {
    return DateRange(
      DateTime(2020, 1, 1),
      DateTime(2099, 12, 31),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'cadence': cadence.name,
      if (targetDate != null) 'target_date': targetDate!.formatted,
    };
  }
}

class UnsupportedRule extends ScheduleRule {
  final Map<String, dynamic> raw;

  const UnsupportedRule(this.raw);

  @override
  Cadence get cadence => Cadence.daily;

  @override
  bool get isWindowScheduled => false;

  @override
  bool isScheduledOn(LocalDate d, [dynamic weekStart]) => false;

  @override
  String periodKey(LocalDate d, [dynamic weekStart]) => d.dateString;

  @override
  DateRange periodOf(LocalDate d, [dynamic weekStart]) {
    final dt = d.toDateTime();
    return DateRange(dt, dt);
  }

  @override
  Map<String, dynamic> toJson() => raw;
}


