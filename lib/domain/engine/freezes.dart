import '../../data/db/database.dart';
import '../constants/xp_constants.dart';
import '../model/models.dart';
import 'schedule_rule.dart';

/// Freeze grants for one closed week. Exclusive tiers, no stacking:
/// 2 for a perfect daily/weekly week, else 1 for an essentials-clean week.
class WeeklyFreezeGrant {
  final LocalDate weekEndDay;
  final int grants; // 0, 1, or 2

  const WeeklyFreezeGrant({required this.weekEndDay, required this.grants});
}

/// Freeze grant + wallet math (keeper freeze rules).
///
/// Single source of truth for grants, shared by the live wallet and the
/// badge engine. Grants derive at read time from the completion log (full
/// history, uniform scope) — the perfect-week *ledger events* remain XP-only
/// artifacts (+75 XP each) and are not counted here.
abstract final class FreezeEngine {
  /// Grants per closed week (weekEnd < today), oldest first.
  ///
  /// Only daily + weekly quests weigh the check. A week grants 2 when every
  /// scheduled daily/weekly quest met its target; otherwise 1 when every
  /// scheduled essential daily/weekly quest did (requires at least one
  /// scheduled essential — vacuous weeks grant nothing).
  static List<WeeklyFreezeGrant> weeklyGrants({
    required List<QuestData> quests,
    required Map<String, Map<LocalDate, int>> completionsByQuest,
    required WeekStart weekStart,
    required LocalDate today,
  }) {
    final candidates =
        quests.where((q) => q.rule is DailyRule || q.rule is WeeklyRule).toList();
    if (candidates.isEmpty) return const [];

    LocalDate? earliest;
    for (final perQuest in completionsByQuest.values) {
      for (final d in perQuest.keys) {
        if (earliest == null || d < earliest) earliest = d;
      }
    }
    // No completions at all: every week would grant 0.
    if (earliest == null) return const [];

    LocalDate weekStartDay =
        WeeklyRule.times(1).periodOf(earliest, weekStart.value).startLocalDate;

    final grants = <WeeklyFreezeGrant>[];
    while (true) {
      final weekEndDay = weekStartDay.addDays(6);
      if (weekEndDay >= today) break; // only closed weeks grant

      int scheduled = 0;
      int satisfied = 0;
      int essentialsScheduled = 0;
      int essentialsSatisfied = 0;

      for (final q in candidates) {
        final weekCount = _weekCount(
          completionsByQuest[q.id] ?? const {},
          weekStartDay,
          weekEndDay,
          q.rule,
        );
        if (!_wasScheduled(q.rule, weekStartDay, weekEndDay, weekStart)) {
          continue;
        }
        final target = _targetFor(q);
        scheduled++;
        if (weekCount >= target) satisfied++;
        if (q.essential) {
          essentialsScheduled++;
          if (weekCount >= target) essentialsSatisfied++;
        }
      }

      final grant = (scheduled > 0 && satisfied == scheduled)
          ? 2
          : (essentialsScheduled > 0 &&
                  essentialsSatisfied == essentialsScheduled)
              ? 1
              : 0;
      grants.add(WeeklyFreezeGrant(weekEndDay: weekEndDay, grants: grant));

      weekStartDay = weekEndDay.addDays(1);
    }
    return grants;
  }

  /// Total grants across all closed weeks.
  static int totalGrants({
    required List<QuestData> quests,
    required Map<String, Map<LocalDate, int>> completionsByQuest,
    required WeekStart weekStart,
    required LocalDate today,
  }) {
    var total = 0;
    for (final g in weeklyGrants(
      quests: quests,
      completionsByQuest: completionsByQuest,
      weekStart: weekStart,
      today: today,
    )) {
      total += g.grants;
    }
    return total;
  }

  /// Wallet replay: chronological grants minus repairs, clamped 0..capacity.
  /// Ties break toward grants (generous).
  static int replayWallet({
    required List<WeeklyFreezeGrant> grants,
    required List<StreakRepairData> repairs,
    int capacity = XpConstants.freezeWalletCapacity,
  }) {
    var balance = 0;
    for (final item in _timeline(grants: grants, repairs: repairs)) {
      balance = (balance + item.delta).clamp(0, capacity);
    }
    return balance;
  }

  /// Peak balance reached during the replay (for "hold N at once" badges).
  static int peakWallet({
    required List<WeeklyFreezeGrant> grants,
    required List<StreakRepairData> repairs,
    int capacity = XpConstants.freezeWalletCapacity,
  }) {
    var balance = 0;
    var peak = 0;
    for (final item in _timeline(grants: grants, repairs: repairs)) {
      balance = (balance + item.delta).clamp(0, capacity);
      if (balance > peak) peak = balance;
    }
    return peak;
  }

  static List<({DateTime time, int delta, bool grant})> _timeline({
    required List<WeeklyFreezeGrant> grants,
    required List<StreakRepairData> repairs,
  }) {
    final timeline = <({DateTime time, int delta, bool grant})>[];
    for (final g in grants) {
      if (g.grants > 0) {
        timeline.add((
          time: g.weekEndDay.toDateTime(),
          delta: g.grants,
          grant: true,
        ));
      }
    }
    for (final r in repairs) {
      timeline.add((time: r.appliedAt, delta: -1, grant: false));
    }
    timeline.sort((a, b) {
      final c = a.time.compareTo(b.time);
      if (c != 0) return c;
      return (b.grant ? 1 : 0) - (a.grant ? 1 : 0);
    });
    return timeline;
  }

  /// Convenience: live balance straight from logbook inputs.
  static int walletBalance({
    required List<QuestData> quests,
    required Map<String, Map<LocalDate, int>> completionsByQuest,
    required List<StreakRepairData> repairs,
    required WeekStart weekStart,
    required LocalDate today,
    int capacity = XpConstants.freezeWalletCapacity,
  }) {
    return replayWallet(
      grants: weeklyGrants(
        quests: quests,
        completionsByQuest: completionsByQuest,
        weekStart: weekStart,
        today: today,
      ),
      repairs: repairs,
      capacity: capacity,
    );
  }

  // ── Shared week math (mirrors settlement's perfect-week check) ──────────

  static int _targetFor(QuestData q) {
    final rule = q.rule;
    if (rule is WeeklyRule && rule.times != null) return rule.times!;
    return q.targetValue;
  }

  static int _weekCount(
    Map<LocalDate, int> perQuest,
    LocalDate weekStartDay,
    LocalDate weekEndDay,
    ScheduleRule rule,
  ) {
    var count = 0;
    for (final entry in perQuest.entries) {
      if (entry.key >= weekStartDay && entry.key <= weekEndDay) {
        if (rule is WeeklyRule &&
            rule.allowedDays != null &&
            rule.allowedDays!.isNotEmpty) {
          if (rule.allowedDays!.contains(entry.key.toDateTime().weekday)) {
            count += entry.value;
          }
        } else {
          count += entry.value;
        }
      }
    }
    return count;
  }

  static bool _wasScheduled(
    ScheduleRule rule,
    LocalDate weekStartDay,
    LocalDate weekEndDay,
    WeekStart weekStart,
  ) {
    if (rule.isWindowScheduled) return true;
    var d = weekStartDay;
    while (d <= weekEndDay) {
      if (rule.isScheduledOn(d, weekStart.value)) return true;
      d = d.addDays(1);
    }
    return false;
  }
}
