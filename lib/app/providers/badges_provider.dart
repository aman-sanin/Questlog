import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/database.dart';
import '../../domain/engine/badges.dart';
import '../../domain/engine/progression.dart';
import '../../domain/engine/streak.dart';
import '../../domain/model/models.dart';
import 'database_provider.dart';
import 'profile_provider.dart';
import 'profile_view_provider.dart';

class BadgesScreenState {
  final List<BadgeStatus> allBadges;
  final int earnedCount;
  final int totalCount;
  final Map<BadgeCategory, List<BadgeStatus>> groupedByCategory;
  final int sealedCount;
  final int revealedSealedCount;

  const BadgesScreenState({
    required this.allBadges,
    required this.earnedCount,
    required this.totalCount,
    required this.groupedByCategory,
    required this.sealedCount,
    required this.revealedSealedCount,
  });

  double get overallProgressRatio => totalCount > 0 ? (earnedCount / totalCount).clamp(0.0, 1.0) : 0.0;
}

final allCompletionsStreamProvider = StreamProvider<List<CompletionData>>((ref) {
  return ref.watch(completionsDaoProvider).watchAllCompletions();
});

final allQuestsStreamProvider = StreamProvider<List<QuestData>>((ref) {
  return ref.watch(questsDaoProvider).watchAllQuests();
});

final allGoalsStreamProvider = StreamProvider<List<GoalData>>((ref) {
  return ref.watch(goalsDaoProvider).watchActiveGoals();
});

final seenMomentsStreamProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(ledgerDaoProvider).watchSeenMoments();
});

final repairsStreamProvider = StreamProvider<List<StreakRepairData>>((ref) {
  return ref.watch(ledgerDaoProvider).watchStreakRepairs();
});

final badgesStateProvider = Provider<AsyncValue<BadgesScreenState>>((ref) {
  final completionsAsync = ref.watch(allCompletionsStreamProvider);
  final questsAsync = ref.watch(allQuestsStreamProvider);
  final goalsAsync = ref.watch(allGoalsStreamProvider);
  final profileAsync = ref.watch(profileStreamProvider);
  final seenMomentsAsync = ref.watch(seenMomentsStreamProvider);
  final repairsAsync = ref.watch(repairsStreamProvider);
  final totalXpAsync = ref.watch(totalXpStreamProvider);
  final today = ref.watch(effectiveLocalDateProvider);
  final weekStart = ref.watch(weekStartProvider);

  if (completionsAsync is AsyncLoading ||
      questsAsync is AsyncLoading ||
      goalsAsync is AsyncLoading ||
      profileAsync is AsyncLoading ||
      seenMomentsAsync is AsyncLoading ||
      repairsAsync is AsyncLoading ||
      totalXpAsync is AsyncLoading) {
    return const AsyncLoading();
  }

  if (completionsAsync.hasError) return AsyncError(completionsAsync.error!, completionsAsync.stackTrace!);
  if (questsAsync.hasError) return AsyncError(questsAsync.error!, questsAsync.stackTrace!);
  if (goalsAsync.hasError) return AsyncError(goalsAsync.error!, goalsAsync.stackTrace!);
  if (profileAsync.hasError) return AsyncError(profileAsync.error!, profileAsync.stackTrace!);
  if (seenMomentsAsync.hasError) return AsyncError(seenMomentsAsync.error!, seenMomentsAsync.stackTrace!);
  if (repairsAsync.hasError) return AsyncError(repairsAsync.error!, repairsAsync.stackTrace!);
  if (totalXpAsync.hasError) return AsyncError(totalXpAsync.error!, totalXpAsync.stackTrace!);

  final completions = completionsAsync.value ?? [];
  final quests = questsAsync.value ?? [];
  final goals = goalsAsync.value ?? [];
  final profile = profileAsync.value;
  final seenMoments = seenMomentsAsync.value ?? <String>{};

  if (profile == null) {
    return const AsyncLoading();
  }

  // Group completions by quest
  final completionsByQuest = <String, Map<LocalDate, int>>{};
  final firstCompletionByQuest = <String, LocalDate>{};

  for (final c in completions) {
    final d = LocalDate.parse(c.localDate);
    completionsByQuest.putIfAbsent(c.questId, () => {})[d] =
        (completionsByQuest[c.questId]![d] ?? 0) + c.value;

    final currentFirst = firstCompletionByQuest[c.questId];
    if (currentFirst == null || d < currentFirst) {
      firstCompletionByQuest[c.questId] = d;
    }
  }

  // Calculate streaks per quest
  final questMaxStreaks = <String, int>{};
  for (final q in quests) {
    final qCompletions = completionsByQuest[q.id] ?? {};
    final firstDate = firstCompletionByQuest[q.id];
    final pausedUntil = q.pausedUntil != null ? LocalDate.parse(q.pausedUntil!) : null;

    final streakRes = StreakEngine.calculate(
      rule: q.rule,
      targetValue: q.targetValue,
      completionValues: qCompletions,
      existingRepairs: {},
      today: today,
      weekStart: weekStart,
      firstCompletionDate: firstDate,
      pausedUntil: pausedUntil,
    );
    questMaxStreaks[q.id] = streakRes.bestStreak;
  }

  // Extract perfect days from completions + scheduled essentials
  final perfectDays = <LocalDate>{};
  final essentialQuests = quests.where((q) => q.essential).toList();

  if (essentialQuests.isNotEmpty) {
    final allDates = <LocalDate>{};
    for (final c in completions) {
      allDates.add(LocalDate.parse(c.localDate));
    }

    for (final d in allDates) {
      int dueEssential = 0;
      int completedEssential = 0;

      for (final eq in essentialQuests) {
        final created = LocalDate.fromDateTime(eq.createdAt);
        if (d < created) continue;

        if (eq.rule.isScheduledOn(d, weekStart.value)) {
          dueEssential++;
          final val = completionsByQuest[eq.id]?[d] ?? 0;
          final target = eq.targetValue;
          if (val >= target) {
            completedEssential++;
          }
        }
      }

      if (dueEssential > 0 && dueEssential == completedEssential) {
        perfectDays.add(d);
      }
    }
  }

  final evaluatedBadges = BadgeEngine.evaluate(
    completions: completions,
    quests: quests,
    goals: goals,
    streakRepairs: repairsAsync.value ?? [],
    profile: profile,
    questMaxStreaks: questMaxStreaks,
    perfectDays: perfectDays,
    seenBadgeKeys: seenMoments,
    weekStart: weekStart,
    today: today,
    playerLevel: ProgressionEngine.levelFromXp(totalXpAsync.value ?? 0),
  );

  final grouped = <BadgeCategory, List<BadgeStatus>>{};
  for (final cat in BadgeCategory.values) {
    grouped[cat] = [];
  }

  int earned = 0;
  int sealedCount = 0;
  int revealedSealed = 0;

  for (final b in evaluatedBadges) {
    if (b.isEarned) earned++;

    if (b.definition.sealed) {
      sealedCount++;
      if (b.isEarned) {
        revealedSealed++;
      }
    }

    grouped[b.definition.category]?.add(b);
  }

  return AsyncData(BadgesScreenState(
    allBadges: evaluatedBadges,
    earnedCount: earned,
    totalCount: evaluatedBadges.length,
    groupedByCategory: grouped,
    sealedCount: sealedCount,
    revealedSealedCount: revealedSealed,
  ));
});
