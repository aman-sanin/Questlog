import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/database.dart';
import '../../domain/engine/insights.dart';
import '../../domain/engine/quest_state.dart';
import '../../domain/engine/schedule_rule.dart';
import '../../domain/model/models.dart';
import 'profile_provider.dart';
import 'profile_view_provider.dart';
import 'today_provider.dart';

enum HeatmapIntensity {
  offDay,
  paused,
  missedEssential,
  low, // 1–39%
  medium, // 40–69%
  high, // 70–99%
  perfect, // 100%
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
  final weekStart = ref.watch(weekStartProvider);
  final todayStateAsync = ref.watch(todayStateProvider);
  final yearCompletionsAsync = ref.watch(yearCompletionsStreamProvider);
  final monthCompletionsAsync = ref.watch(monthCompletionsProvider(month));
  final questsAsync = ref.watch(activeQuestsStreamProvider);
  final totalXpAsync = ref.watch(totalXpStreamProvider);

  if (todayStateAsync is AsyncLoading ||
      yearCompletionsAsync is AsyncLoading ||
      monthCompletionsAsync is AsyncLoading ||
      questsAsync is AsyncLoading) {
    return const AsyncLoading();
  }
  if (todayStateAsync.hasError) return AsyncError(todayStateAsync.error!, todayStateAsync.stackTrace!);
  if (yearCompletionsAsync.hasError) return AsyncError(yearCompletionsAsync.error!, yearCompletionsAsync.stackTrace!);
  if (monthCompletionsAsync.hasError) return AsyncError(monthCompletionsAsync.error!, monthCompletionsAsync.stackTrace!);
  if (questsAsync.hasError) return AsyncError(questsAsync.error!, questsAsync.stackTrace!);

  final quests = questsAsync.value ?? [];
  final yearCompletions = yearCompletionsAsync.value ?? [];
  final monthCompletions = monthCompletionsAsync.value ?? [];
  final totalXp = totalXpAsync.value ?? 0;

  final nextMonth = month.month == 12 ? LocalDate(month.year + 1, 1, 1) : LocalDate(month.year, month.month + 1, 1);
  final endOfMonth = nextMonth.subtractDays(1);

  return AsyncData(_buildInsights(
    month: month,
    today: today,
    endOfMonth: endOfMonth,
    weekStart: weekStart,
    todayState: todayStateAsync.value!,
    quests: quests,
    monthCompletions: monthCompletions,
    yearCompletions: yearCompletions,
    totalXp: totalXp,
  ));
});


/// Compute HeatmapIntensity for a single day given completions and the quests active on that day.
HeatmapIntensity _intensityForDay({
  required LocalDate day,
  required LocalDate today,
  required List<QuestData> quests,
  required Map<String, int> completionCountByQuestId, // questId -> total value for this day
  required WeekStart weekStart,
}) {
  if (day > today) return HeatmapIntensity.offDay;

  // Count quests that were due on this day (and existed on this day)
  int dueCount = 0;
  int completedCount = 0;
  bool anyEssentialMissed = false;

  for (final q in quests) {
    final createdDate = LocalDate.fromDateTime(q.createdAt);
    if (day < createdDate) continue; // quest didn't exist yet

    final scheduled = q.rule.isScheduledOn(day, weekStart.value);
    if (!scheduled) continue;

    dueCount++;
    final val = completionCountByQuestId[q.id] ?? 0;
    final target = _targetForRule(q.rule, q.targetValue);
    if (val >= target) {
      completedCount++;
    } else if (q.essential) {
      anyEssentialMissed = true;
    }
  }

  if (dueCount == 0) return HeatmapIntensity.offDay;

  if (anyEssentialMissed && day < today) return HeatmapIntensity.missedEssential;

  final ratio = completedCount / dueCount;
  if (ratio >= 1.0) return HeatmapIntensity.perfect;
  if (ratio >= 0.70) return HeatmapIntensity.high;
  if (ratio >= 0.40) return HeatmapIntensity.medium;
  if (ratio > 0.0) return HeatmapIntensity.low;
  // 0% completion on a past day
  if (day < today && anyEssentialMissed) return HeatmapIntensity.missedEssential;
  return HeatmapIntensity.offDay;
}

int _targetForRule(ScheduleRule rule, int baseTarget) {
  if (rule is WeeklyRule && rule.times != null) return rule.times!;
  if (rule is MonthlyRule && rule.times != null) return rule.times!;
  if (rule is YearlyRule && rule.times != null) return rule.times!;
  return baseTarget;
}

InsightsScreenState _buildInsights({
  required LocalDate month,
  required LocalDate today,
  required LocalDate endOfMonth,
  required WeekStart weekStart,
  required TodayScreenState todayState,
  required List<QuestData> quests,
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

    final intensity = _intensityForDay(
      day: cur,
      today: today,
      quests: quests,
      completionCountByQuestId: dayCompByQuest,
      weekStart: weekStart,
    );

    final totalCompletions = dayCompByQuest.values.fold(0, (a, b) => a + b);

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

    final intensity = _intensityForDay(
      day: yearCur,
      today: today,
      quests: quests,
      completionCountByQuestId: dayCompByQuest,
      weekStart: weekStart,
    );

    final totalCompletions = dayCompByQuest.values.fold(0, (a, b) => a + b);

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

