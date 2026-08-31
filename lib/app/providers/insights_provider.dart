import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/constants/xp_constants.dart';
import '../../domain/engine/insights.dart';
import '../../domain/engine/quest_state.dart';
import '../../domain/model/models.dart';
import 'database_provider.dart';
import 'profile_provider.dart';
import 'today_provider.dart';

enum HeatmapIntensity {
  offDay,
  paused,
  missedEssential,
  low, // 20%
  medium, // 45%
  high, // 70%
  perfect, // Ember (100%)
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
  final List<QuestEvaluation> streakLeaderboard;
  final int freezeWalletCount;
  final WeeklyInsightData weeklyInsight;
  final bool hasMonthlyRecap;

  const InsightsScreenState({
    required this.selectedMonth,
    required this.heatmapDays,
    required this.streakLeaderboard,
    required this.freezeWalletCount,
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
  final ledgerDao = ref.watch(ledgerDaoProvider);
  final completionsDao = ref.watch(completionsDaoProvider);

  if (todayStateAsync is AsyncLoading) return const AsyncLoading();
  if (todayStateAsync.hasError) return AsyncError(todayStateAsync.error!, todayStateAsync.stackTrace!);

  final startOfMonth = LocalDate(month.year, month.month, 1);
  final nextMonth = month.month == 12 ? LocalDate(month.year + 1, 1, 1) : LocalDate(month.year, month.month + 1, 1);
  final endOfMonth = nextMonth.subtractDays(1);

  return AsyncData(_buildInsights(
    month: month,
    today: today,
    startOfMonth: startOfMonth,
    endOfMonth: endOfMonth,
    todayState: todayStateAsync.value!,
  ));
});

InsightsScreenState _buildInsights({
  required LocalDate month,
  required LocalDate today,
  required LocalDate startOfMonth,
  required LocalDate endOfMonth,
  required TodayScreenState todayState,
}) {
  // Build streak leaderboard
  final allQuests = <QuestEvaluation>[
    ...todayState.generalQuests,
    for (final sec in todayState.goalSections) ...sec.quests,
  ];

  allQuests.sort((a, b) => b.streak.compareTo(a.streak));

  final days = <HeatmapDayStatus>[];
  LocalDate cur = startOfMonth;
  while (cur <= endOfMonth) {
    final isCurToday = cur == today;
    // Simple deterministic demo heatmap intensity calculation
    HeatmapIntensity intensity;
    if (cur > today) {
      intensity = HeatmapIntensity.offDay;
    } else {
      intensity = (cur.day % 4 == 0)
          ? HeatmapIntensity.perfect
          : (cur.day % 3 == 0 ? HeatmapIntensity.high : HeatmapIntensity.medium);
    }

    days.add(HeatmapDayStatus(
      date: cur,
      intensity: intensity,
      completionsCount: cur <= today ? (cur.day % 5 + 1) : 0,
      isToday: isCurToday,
    ));

    cur = cur.addDays(1);
  }

  final weeklyInsight = InsightsEngine.getWeeklyInsight(
    completionsByDate: {},
    today: today,
    totalXp: 1200,
  );

  return InsightsScreenState(
    selectedMonth: month,
    heatmapDays: days,
    streakLeaderboard: allQuests.take(10).toList(),
    freezeWalletCount: XpConstants.freezeWalletCapacity,
    weeklyInsight: weeklyInsight,
    hasMonthlyRecap: today.day <= 7, // First week of month
  );
}
