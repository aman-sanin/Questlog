import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/database.dart';
import '../../domain/engine/quest_state.dart';
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

final streakRepairsStreamProvider = StreamProvider<List<StreakRepairData>>((ref) {
  return ref.watch(ledgerDaoProvider).watchStreakRepairs();
});

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
      targetValue: q.targetValue,
      completionValues: qCompletions,
      existingRepairs: qRepairs,
      today: today,
      weekStart: weekStart,
      firstCompletionDate: firstDate,
      pausedUntil: pausedUntil,
    );

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

  // Sort function: essentials first, rare cadences first, then title
  int sortQuests(QuestEvaluation a, QuestEvaluation b) {
    if (a.essential != b.essential) {
      return a.essential ? -1 : 1;
    }
    // Yearly (3) > Monthly (2) > Weekly (1) > Daily (0)
    if (a.rule.cadence.index != b.rule.cadence.index) {
      return b.rule.cadence.index.compareTo(a.rule.cadence.index);
    }
    return a.title.compareTo(b.title);
  }

  // Group quests by goal
  final goalSections = <GoalSectionViewModel>[];
  final generalQuests = <QuestEvaluation>[];

  final questsByGoalId = <String, List<QuestEvaluation>>{};
  for (final q in evaluatedQuests) {
    if (q.goalId != null) {
      questsByGoalId.putIfAbsent(q.goalId!, () => []).add(q);
    } else {
      generalQuests.add(q);
    }
  }

  for (final goal in goals) {
    final gQuests = questsByGoalId[goal.id] ?? [];
    if (gQuests.isNotEmpty) {
      gQuests.sort(sortQuests);
      int doneCount = gQuests.where((q) => q.isCompleted).length;
      double rate = doneCount / gQuests.length;

      goalSections.add(GoalSectionViewModel(
        goal: goal,
        completionRate: rate,
        quests: gQuests,
      ));
    }
  }

  generalQuests.sort(sortQuests);

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
