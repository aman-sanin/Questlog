import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/database.dart';
import '../../domain/engine/freezes.dart';
import '../../domain/engine/quest_state.dart';
import '../../domain/engine/schedule_rule.dart';
import '../../domain/engine/streak.dart';
import '../../domain/model/models.dart';
import 'database_provider.dart';
import 'profile_provider.dart';

class GoalSectionViewModel {
  final GoalData goal;
  final double completionRate;
  final List<QuestEvaluation> quests;

  const GoalSectionViewModel({
    required this.goal,
    required this.completionRate,
    required this.quests,
  });
}

class TodayScreenState {
  final LocalDate today;
  final List<GoalSectionViewModel> goalSections;
  final List<QuestEvaluation> generalQuests;
  final bool isPerfectDayEarned;
  final int totalDueCount;
  final int completedDueCount;
  final bool isEmpty;

  const TodayScreenState({
    required this.today,
    required this.goalSections,
    required this.generalQuests,
    required this.isPerfectDayEarned,
    required this.totalDueCount,
    required this.completedDueCount,
    required this.isEmpty,
  });

  List<QuestEvaluation> get allQuests => [
        ...generalQuests,
        for (final g in goalSections) ...g.quests,
      ];
}

/// Quest display order for Today (and goal sheets, which reuse these lists):
/// current quests on top, completed sink to the bottom. Within each group:
/// essentials first, rare cadences first, then title.
int sortQuestsForToday(QuestEvaluation a, QuestEvaluation b) {
  if (a.isCompleted != b.isCompleted) {
    return a.isCompleted ? 1 : -1;
  }
  if (a.essential != b.essential) {
    return a.essential ? -1 : 1;
  }
  // Yearly (3) > Monthly (2) > Weekly (1) > Daily (0)
  if (a.rule.cadence.index != b.rule.cadence.index) {
    return b.rule.cadence.index.compareTo(a.rule.cadence.index);
  }
  return a.title.compareTo(b.title);
}

final activeQuestsStreamProvider = StreamProvider<List<QuestData>>((ref) {
  return ref.watch(questsDaoProvider).watchActiveQuests();
});

final activeGoalsStreamProvider = StreamProvider<List<GoalData>>((ref) {
  return ref.watch(goalsDaoProvider).watchActiveGoals();
});

final recentCompletionsStreamProvider = StreamProvider<List<CompletionData>>((ref) {
  final today = ref.watch(effectiveLocalDateProvider);
  final start = today.subtractDays(60).formatted;
  final end = today.addDays(7).formatted;
  return ref.watch(completionsDaoProvider).watchCompletionsInDateRange(start, end);
});

/// 365-day window for the year heatmap — watched by insightsStateProvider
final yearCompletionsStreamProvider = StreamProvider<List<CompletionData>>((ref) {
  final today = ref.watch(effectiveLocalDateProvider);
  final start = today.subtractDays(364).formatted;
  final end = today.formatted;
  return ref.watch(completionsDaoProvider).watchCompletionsInDateRange(start, end);
});

/// Per-month completions for the month heatmap (keyed by first-of-month LocalDate)
final monthCompletionsProvider = StreamProvider.family<List<CompletionData>, LocalDate>((ref, month) {
  final nextMonth = month.month == 12 ? LocalDate(month.year + 1, 1, 1) : LocalDate(month.year, month.month + 1, 1);
  final endOfMonth = nextMonth.subtractDays(1);
  return ref.watch(completionsDaoProvider).watchCompletionsInDateRange(month.formatted, endOfMonth.formatted);
});

final streakRepairsStreamProvider = StreamProvider<List<StreakRepairData>>((ref) {
  return ref.watch(ledgerDaoProvider).watchStreakRepairs();
});

/// Full-history streams for the freeze wallet (grants derive from the whole
/// log, not the recent window). Kept local to avoid a provider import cycle
/// via badges/profile_view.
final _allQuestsForWalletProvider = StreamProvider<List<QuestData>>((ref) {
  return ref.watch(questsDaoProvider).watchAllQuests();
});

final _allCompletionsForWalletProvider =
    StreamProvider<List<CompletionData>>((ref) {
  return ref.watch(completionsDaoProvider).watchAllCompletions();
});

/// Live freeze wallet balance: grant replay minus persisted repairs,
/// capped at [XpConstants.freezeWalletCapacity].
final freezeWalletProvider = Provider<AsyncValue<int>>((ref) {
  final questsAsync = ref.watch(_allQuestsForWalletProvider);
  final completionsAsync = ref.watch(_allCompletionsForWalletProvider);
  final repairsAsync = ref.watch(streakRepairsStreamProvider);
  final today = ref.watch(effectiveLocalDateProvider);
  final weekStart = ref.watch(weekStartProvider);

  if (questsAsync is AsyncLoading ||
      completionsAsync is AsyncLoading ||
      repairsAsync is AsyncLoading) {
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

  final completionsByQuest = <String, Map<LocalDate, int>>{};
  for (final c in completionsAsync.value ?? <CompletionData>[]) {
    final d = LocalDate.parse(c.localDate);
    final perQuest =
        completionsByQuest.putIfAbsent(c.questId, () => <LocalDate, int>{});
    perQuest[d] = (perQuest[d] ?? 0) + c.value;
  }

  return AsyncData(FreezeEngine.walletBalance(
    quests: questsAsync.value ?? [],
    completionsByQuest: completionsByQuest,
    repairs: repairsAsync.value ?? [],
    weekStart: weekStart,
    today: today,
  ));
});

final todayCadenceFilterProvider = StateProvider<Cadence?>((ref) => null);

final todayStateProvider = Provider<AsyncValue<TodayScreenState>>((ref) {
  final questsAsync = ref.watch(activeQuestsStreamProvider);
  final goalsAsync = ref.watch(activeGoalsStreamProvider);
  final completionsAsync = ref.watch(recentCompletionsStreamProvider);
  final repairsAsync = ref.watch(streakRepairsStreamProvider);
  final today = ref.watch(effectiveLocalDateProvider);
  final now = ref.watch(currentDateTimeProvider);
  final weekStart = ref.watch(weekStartProvider);

  if (questsAsync is AsyncLoading ||
      goalsAsync is AsyncLoading ||
      completionsAsync is AsyncLoading ||
      repairsAsync is AsyncLoading) {
    return const AsyncLoading();
  }

  if (questsAsync.hasError) return AsyncError(questsAsync.error!, questsAsync.stackTrace!);
  if (goalsAsync.hasError) return AsyncError(goalsAsync.error!, goalsAsync.stackTrace!);
  if (completionsAsync.hasError) return AsyncError(completionsAsync.error!, completionsAsync.stackTrace!);
  if (repairsAsync.hasError) return AsyncError(repairsAsync.error!, repairsAsync.stackTrace!);

  final quests = questsAsync.value ?? [];
  final goals = goalsAsync.value ?? [];
  final completions = completionsAsync.value ?? [];
  final repairs = repairsAsync.value ?? [];

  // Index completions by quest and date
  final completionsByQuest = <String, Map<LocalDate, int>>{};
  final completionDatesByQuest = <String, List<LocalDate>>{};
  final firstCompletionByQuest = <String, LocalDate>{};

  for (final c in completions) {
    final d = LocalDate.parse(c.localDate);
    completionsByQuest.putIfAbsent(c.questId, () => {})[d] =
        (completionsByQuest[c.questId]![d] ?? 0) + c.value;
    completionDatesByQuest.putIfAbsent(c.questId, () => []).add(d);

    final currentFirst = firstCompletionByQuest[c.questId];
    if (currentFirst == null || d < currentFirst) {
      firstCompletionByQuest[c.questId] = d;
    }
  }

  final repairsByQuest = <String, Set<String>>{};
  for (final r in repairs) {
    repairsByQuest.putIfAbsent(r.questId, () => {}).add(r.periodKey);
  }

  final evaluatedQuests = <QuestEvaluation>[];
  int totalDue = 0;
  int completedDue = 0;
  int essentialDue = 0;
  int essentialCompleted = 0;

  for (final q in quests) {
    final qCompletions = completionsByQuest[q.id] ?? {};
    final qDates = completionDatesByQuest[q.id] ?? [];
    final qRepairs = repairsByQuest[q.id] ?? {};
    final firstDate = firstCompletionByQuest[q.id];
    final pausedUntil = q.pausedUntil != null ? LocalDate.parse(q.pausedUntil!) : null;

    final streakRes = StreakEngine.calculate(
      rule: q.rule,
      targetType: TargetType.values[q.targetType],
      targetValue: q.targetValue,
      completionValues: qCompletions,
      existingRepairs: qRepairs,
      today: today,
      weekStart: weekStart,
      firstCompletionDate: firstDate,
      pausedUntil: pausedUntil,
    );

    final yesterdayKey = q.rule.periodKey(today.subtractDays(1), weekStart.value);
    final hasFreezeSavedYesterday = qRepairs.contains(yesterdayKey);

    final evaluation = QuestEvaluation.evaluate(
      questId: q.id,
      title: q.title,
      rule: q.rule,
      targetType: TargetType.values[q.targetType],
      targetValue: q.targetValue,
      unit: q.unit,
      difficulty: Difficulty.values[q.difficulty],
      essential: q.essential,
      goalId: q.goalId,
      domain: q.domain != null ? CallingDomain.values[q.domain!] : null,
      pausedUntil: pausedUntil,
      completionDates: qDates,
      completionValues: qCompletions,
      today: today,
      now: now,
      weekStart: weekStart,
      firstCompletionDate: firstDate,
      streak: streakRes.streak,
      hasFreezeSavedYesterday: hasFreezeSavedYesterday,
    );

    evaluatedQuests.add(evaluation);

    if (evaluation.isDueToday) {
      totalDue++;
      if (evaluation.isCompleted) {
        completedDue++;
      }
      if (evaluation.essential) {
        essentialDue++;
        if (evaluation.isCompleted) {
          essentialCompleted++;
        }
      }
    }
  }

  // Group quests by goal
  final goalSections = <GoalSectionViewModel>[];
  final generalQuests = <QuestEvaluation>[];

  final questsByGoalId = <String, List<QuestEvaluation>>{};
  for (final q in evaluatedQuests) {
    if (q.rule is SingleRule && !q.isDueToday && q.isCompleted) {
      continue;
    }
    if (q.goalId != null) {
      questsByGoalId.putIfAbsent(q.goalId!, () => []).add(q);
    } else {
      generalQuests.add(q);
    }
  }

  for (final goal in goals) {
    final gQuests = questsByGoalId[goal.id] ?? [];
    if (gQuests.isNotEmpty) {
      gQuests.sort(sortQuestsForToday);
      int doneCount = gQuests.where((q) => q.isCompleted).length;
      double rate = doneCount / gQuests.length;

      goalSections.add(GoalSectionViewModel(
        goal: goal,
        completionRate: rate,
        quests: gQuests,
      ));
    }
  }

  generalQuests.sort(sortQuestsForToday);

  final isPerfectDay = essentialDue > 0 && essentialDue == essentialCompleted;

  return AsyncData(TodayScreenState(
    today: today,
    goalSections: goalSections,
    generalQuests: generalQuests,
    isPerfectDayEarned: isPerfectDay,
    totalDueCount: totalDue,
    completedDueCount: completedDue,
    isEmpty: quests.isEmpty,
  ));
});
