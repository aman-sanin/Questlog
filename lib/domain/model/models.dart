enum Cadence {
  daily,
  weekly,
  monthly,
  yearly;

  String get key => name;
}

enum Difficulty {
  easy,
  medium,
  hard;

  double get multiplier {
    switch (this) {
      case Difficulty.easy:
        return 1.0;
      case Difficulty.medium:
        return 1.5;
      case Difficulty.hard:
        return 2.0;
    }
  }
}

enum TargetType {
  checkbox,
  counter;
}

enum CallingDomain {
  warrior,
  sage,
  monk,
  bard,
  ranger,
  artificer;

  String get key => name;
}

enum QuestVisual {
  pending,
  atRisk,
  completed,
  missedEssential,
  missedNonEssential,
  paused,
  grace,
  overachieved;
}

enum XpEventType {
  quest,
  perfectDay,
  perfectWeek,
  milestone,
  goal,
}

enum WeekStart {
  monday(1),
  sunday(7);

  final int value;
  const WeekStart(this.value);
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange(this.start, this.end);

  LocalDate get startLocalDate => LocalDate.fromDateTime(start);
  LocalDate get endLocalDate => LocalDate.fromDateTime(end);

  bool contains(LocalDate date) {
    final d = date.toDateTime();
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return (d.isAfter(s) || d.isAtSameMomentAs(s)) && (d.isBefore(e) || d.isAtSameMomentAs(e));
  }

  @override
  String toString() => '${start.toIso8601String().substring(0, 10)}..${end.toIso8601String().substring(0, 10)}';
}

class WindowInfo {
  final int currentCount;
  final int targetCount;
  final int daysLeftInPeriod;

  const WindowInfo({
    required this.currentCount,
    required this.targetCount,
    required this.daysLeftInPeriod,
  });
}

// Simple LocalDate helper utility
class LocalDate implements Comparable<LocalDate> {
  final int year;
  final int month;
  final int day;

  const LocalDate(this.year, this.month, this.day);

  factory LocalDate.fromDateTime(DateTime dt) {
    return LocalDate(dt.year, dt.month, dt.day);
  }

  factory LocalDate.parse(String s) {
    final parts = s.split('-');
    return LocalDate(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  DateTime toDateTime() => DateTime(year, month, day);

  String get dateString {
    final yStr = year.toString().padLeft(4, '0');
    final mStr = month.toString().padLeft(2, '0');
    final dStr = day.toString().padLeft(2, '0');
    return '$yStr-$mStr-$dStr';
  }

  String get formatted => dateString;

  LocalDate addDays(int days) {
    return LocalDate.fromDateTime(toDateTime().add(Duration(days: days)));
  }

  LocalDate subtractDays(int days) => addDays(-days);

  int differenceInDays(LocalDate other) {
    return toDateTime().difference(other.toDateTime()).inDays;
  }

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;
  bool isAtSameMomentAs(LocalDate other) => compareTo(other) == 0;

  bool operator >=(LocalDate other) => compareTo(other) >= 0;
  bool operator <=(LocalDate other) => compareTo(other) <= 0;
  bool operator >(LocalDate other) => compareTo(other) > 0;
  bool operator <(LocalDate other) => compareTo(other) < 0;

  @override
  int compareTo(LocalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalDate &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ day.hashCode;

  @override
  String toString() => dateString;
}
