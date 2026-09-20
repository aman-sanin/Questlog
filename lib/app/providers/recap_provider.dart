import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/database.dart';
import '../../domain/engine/insights.dart';
import '../../domain/model/models.dart';
import 'badges_provider.dart';
import 'database_provider.dart';
import 'profile_provider.dart';
import 'today_provider.dart';

final _allXpEventsProvider = FutureProvider<List<XpEventData>>((ref) {
  return ref.watch(ledgerDaoProvider).getAllXpEvents();
});

/// Recap of the last fully-closed calendar month (the manuscript the first
/// week of each month teases). All month-scoped inputs derive here; the
/// engine stays pure.
final monthlyRecapProvider = Provider<AsyncValue<MonthlyRecapData>>((ref) {
  final today = ref.watch(effectiveLocalDateProvider);
  final weekStart = ref.watch(weekStartProvider);
  final questsAsync = ref.watch(allQuestsStreamProvider);
  final completionsAsync = ref.watch(allCompletionsStreamProvider);
  final repairsAsync = ref.watch(streakRepairsStreamProvider);
  final xpAsync = ref.watch(_allXpEventsProvider);

  if (questsAsync is AsyncLoading ||
      completionsAsync is AsyncLoading ||
      repairsAsync is AsyncLoading ||
      xpAsync is AsyncLoading) {
    return const AsyncLoading();
  }
  if (questsAsync.hasError) {
    return AsyncError(questsAsync.error!, questsAsync.stackTrace!);
  }
  if (completionsAsync.hasError) {
    return AsyncError(completionsAsync.error!, completionsAsync.stackTrace!);
  }
  if (repairsAsync.hasError) {
    return AsyncError(repairsAsync.error!, repairsAsync.stackTrace!);
  }
  if (xpAsync.hasError) {
    return AsyncError(xpAsync.error!, xpAsync.stackTrace!);
  }

  final quests = questsAsync.value ?? [];
  final completions = completionsAsync.value ?? [];
  final repairs = repairsAsync.value ?? [];
  final xpEvents = xpAsync.value ?? [];

  final recapMonth = today.month == 1
      ? LocalDate(today.year - 1, 12, 1)
      : LocalDate(today.year, today.month - 1, 1);
  final recapEnd = InsightsEngine.monthEnd(recapMonth);
  final prevMonth = recapMonth.month == 1
      ? LocalDate(recapMonth.year - 1, 12, 1)
      : LocalDate(recapMonth.year, recapMonth.month - 1, 1);

  final completionsByQuest = <String, Map<LocalDate, int>>{};
  for (final c in completions) {
    final d = LocalDate.parse(c.localDate);
    completionsByQuest.putIfAbsent(c.questId, () => <LocalDate, int>{})[d] =
        (completionsByQuest[c.questId]![d] ?? 0) + c.value;
  }

  final monthXpEvents = <XpEventData>[];
  for (final e in xpEvents) {
    final d = LocalDate.parse(e.localDate);
    if (d >= recapMonth && d <= recapEnd) monthXpEvents.add(e);
  }

  final monthRepairs = <StreakRepairData>[];
  final repairsByQuest = <String, Set<String>>{};
  for (final r in repairs) {
    repairsByQuest.putIfAbsent(r.questId, () => {}).add(r.periodKey);
    final applied = LocalDate.fromDateTime(r.appliedAt);
    if (applied >= recapMonth && applied <= recapEnd) {
      monthRepairs.add(r);
    }
  }

  // Perfect days in the recap month (same satisfaction rule as badges).
  final perfectDaysInMonth = <LocalDate>{};
  final essentialQuests = quests.where((q) => q.essential).toList();
  if (essentialQuests.isNotEmpty) {
    final monthDates = <LocalDate>{};
    for (final perQuest in completionsByQuest.values) {
      for (final d in perQuest.keys) {
        if (d >= recapMonth && d <= recapEnd) monthDates.add(d);
      }
    }
    for (final d in monthDates) {
      var due = 0;
      var done = 0;
      for (final eq in essentialQuests) {
        final created = LocalDate.fromDateTime(eq.createdAt);
        if (d < created) continue;
        if (eq.rule.isScheduledOn(d, weekStart.value)) {
          due++;
          final val = completionsByQuest[eq.id]?[d] ?? 0;
          if (val >= eq.targetValue) done++;
        }
      }
      if (due > 0 && due == done) perfectDaysInMonth.add(d);
    }
  }

  return AsyncData(
    InsightsEngine.buildMonthlyRecap(
      month: recapMonth,
      prevMonth: prevMonth,
      quests: quests,
      completionsByQuest: completionsByQuest,
      monthXpEvents: monthXpEvents,
      monthRepairs: monthRepairs,
      repairsByQuest: repairsByQuest,
      perfectDaysInMonth: perfectDaysInMonth,
      weekStart: weekStart,
      today: today,
    ),
  );
});
