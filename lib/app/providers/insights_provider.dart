import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/database.dart';
import '../../domain/engine/insights.dart';
import '../../domain/engine/quest_state.dart';
import '../../domain/model/models.dart';
import 'profile_provider.dart';
import 'profile_view_provider.dart';
import 'today_provider.dart';

enum HeatmapIntensity {
  offDay,
  paused,
  low, // 1 completion
  medium, // 2–3 completions
  high, // 4–6 completions
  perfect, // 7+ completions
}

class HeatmapDayStatus {
  final LocalDate date;
  final HeatmapIntensity intensity;
  final int completionsCount;
  final bool isToday;

  const HeatmapDayStatus({
    required this.date,
    required this.intensity,
    required this.completionsCount,
    required this.isToday,
  });
}

class InsightsScreenState {
  final LocalDate selectedMonth;
  final List<HeatmapDayStatus> heatmapDays;
  final List<HeatmapDayStatus> yearHeatmapDays;
  final List<QuestEvaluation> streakLeaderboard;
  final WeeklyInsightData weeklyInsight;
  final bool hasMonthlyRecap;

  const InsightsScreenState({
    required this.selectedMonth,
    required this.heatmapDays,
    required this.yearHeatmapDays,
    required this.streakLeaderboard,
    required this.weeklyInsight,
    required this.hasMonthlyRecap,
  });
}

final selectedInsightsMonthProvider = StateProvider<LocalDate>((ref) {
  final today = ref.watch(effectiveLocalDateProvider);
  return LocalDate(today.year, today.month, 1);
});

final insightsStateProvider = Provider<AsyncValue<InsightsScreenState>>((ref) {
  final month = ref.watch(selectedInsightsMonthProvider);
  final today = ref.watch(effectiveLocalDateProvider);
  final todayStateAsync = ref.watch(todayStateProvider);
  final yearCompletionsAsync = ref.watch(yearCompletionsStreamProvider);
  final monthCompletionsAsync = ref.watch(monthCompletionsProvider(month));
  final totalXpAsync = ref.watch(totalXpStreamProvider);

  if (todayStateAsync is AsyncLoading ||
      yearCompletionsAsync is AsyncLoading ||
      monthCompletionsAsync is AsyncLoading) {
    return const AsyncLoading();
  }
  if (todayStateAsync.hasError) return AsyncError(todayStateAsync.error!, todayStateAsync.stackTrace!);
  if (yearCompletionsAsync.hasError) return AsyncError(yearCompletionsAsync.error!, yearCompletionsAsync.stackTrace!);
  if (monthCompletionsAsync.hasError) return AsyncError(monthCompletionsAsync.error!, monthCompletionsAsync.stackTrace!);

  final yearCompletions = yearCompletionsAsync.value ?? [];
  final monthCompletions = monthCompletionsAsync.value ?? [];
  final totalXp = totalXpAsync.value ?? 0;

  final nextMonth = month.month == 12 ? LocalDate(month.year + 1, 1, 1) : LocalDate(month.year, month.month + 1, 1);
  final endOfMonth = nextMonth.subtractDays(1);

  return AsyncData(_buildInsights(
    month: month,
    today: today,
    endOfMonth: endOfMonth,
    todayState: todayStateAsync.value!,
    monthCompletions: monthCompletions,
    yearCompletions: yearCompletions,
    totalXp: totalXp,
  ));
});


/// GitHub-style bucket for a day's total completion value: blank iff nothing
/// was done, accent shade scaling with volume. Fixed breaks, stable month
/// to month. Scheduled/essential/missed play no role — a missed day simply
/// has nothing logged, so it stays blank.
HeatmapIntensity heatmapIntensityForCount(int total) {
  if (total <= 0) return HeatmapIntensity.offDay;
  if (total == 1) return HeatmapIntensity.low;
  if (total <= 3) return HeatmapIntensity.medium;
  if (total <= 6) return HeatmapIntensity.high;
  return HeatmapIntensity.perfect;
}

InsightsScreenState _buildInsights({
  required LocalDate month,
  required LocalDate today,
  required LocalDate endOfMonth,
  required TodayScreenState todayState,
  required List<CompletionData> monthCompletions,
  required List<CompletionData> yearCompletions,
  required int totalXp,
}) {
  // Build streak leaderboard
  final allQuests = <QuestEvaluation>[
    ...todayState.generalQuests,
    for (final sec in todayState.goalSections) ...sec.quests,
  ];
  allQuests.sort((a, b) => b.streak.compareTo(a.streak));

  // ── Month heatmap ──────────────────────────────────────────────────────────
  // Index month completions: questId -> date -> value
  final monthCompByQuestDate = <String, Map<LocalDate, int>>{};
  for (final c in monthCompletions) {
    final d = LocalDate.parse(c.localDate);
    monthCompByQuestDate.putIfAbsent(c.questId, () => {})[d] =
        (monthCompByQuestDate[c.questId]?[d] ?? 0) + c.value;
  }

  final monthDays = <HeatmapDayStatus>[];
  LocalDate cur = LocalDate(month.year, month.month, 1);
  while (cur <= endOfMonth) {
    // For this day: build questId -> completionValue map
    final dayCompByQuest = <String, int>{};
    for (final entry in monthCompByQuestDate.entries) {
      final val = entry.value[cur];
      if (val != null) dayCompByQuest[entry.key] = val;
    }

    final totalCompletions = dayCompByQuest.values.fold(0, (a, b) => a + b);
    final intensity = cur > today
        ? HeatmapIntensity.offDay
        : heatmapIntensityForCount(totalCompletions);

    monthDays.add(HeatmapDayStatus(
      date: cur,
      intensity: intensity,
      completionsCount: totalCompletions,
      isToday: cur == today,
    ));
    cur = cur.addDays(1);
  }

  // ── Year heatmap ───────────────────────────────────────────────────────────
  // Index year completions: questId -> date -> value
  final yearCompByQuestDate = <String, Map<LocalDate, int>>{};
  for (final c in yearCompletions) {
    final d = LocalDate.parse(c.localDate);
    yearCompByQuestDate.putIfAbsent(c.questId, () => {})[d] =
        (yearCompByQuestDate[c.questId]?[d] ?? 0) + c.value;
  }

  // Also build completionsByDate for weeklyInsight
  final completionsByDate = <LocalDate, int>{};
  for (final c in yearCompletions) {
    final d = LocalDate.parse(c.localDate);
    completionsByDate[d] = (completionsByDate[d] ?? 0) + c.value;
  }

  final yearDays = <HeatmapDayStatus>[];
  final yearStart = today.subtractDays(364);
  LocalDate yearCur = yearStart;
  while (yearCur <= today) {
    final dayCompByQuest = <String, int>{};
    for (final entry in yearCompByQuestDate.entries) {
      final val = entry.value[yearCur];
      if (val != null) dayCompByQuest[entry.key] = val;
    }

    final totalCompletions = dayCompByQuest.values.fold(0, (a, b) => a + b);
    final intensity = heatmapIntensityForCount(totalCompletions);

    yearDays.add(HeatmapDayStatus(
      date: yearCur,
      intensity: intensity,
      completionsCount: totalCompletions,
      isToday: yearCur == today,
    ));
    yearCur = yearCur.addDays(1);
  }

  // ── Weekly insight ─────────────────────────────────────────────────────────
  final weeklyInsight = InsightsEngine.getWeeklyInsight(
    completionsByDate: completionsByDate,
    today: today,
    totalXp: totalXp,
  );

  return InsightsScreenState(
    selectedMonth: month,
    heatmapDays: monthDays,
    yearHeatmapDays: yearDays,
    streakLeaderboard: allQuests.take(10).toList(),
    weeklyInsight: weeklyInsight,
    hasMonthlyRecap: today.day <= 7,
  );
}

