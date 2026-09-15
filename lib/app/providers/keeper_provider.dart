import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/database.dart';
import '../../domain/keeper/classifier.dart';
import '../../domain/keeper/growth.dart';
import '../../domain/model/models.dart';
import 'badges_provider.dart';
import 'profile_provider.dart';
import 'profile_view_provider.dart';
import 'today_provider.dart';

/// Everything the presentation layer needs about the Keeper for one frame,
/// fully derived from existing providers (keeper.md §4/§8).
class KeeperUiState {
  final KeeperMood mood;
  final bool anticipation;
  final KeeperStage stage;
  final CallingDomain? calling;
  final int perfectDays;
  final int level;

  const KeeperUiState({
    required this.mood,
    required this.anticipation,
    required this.stage,
    required this.calling,
    required this.perfectDays,
    required this.level,
  });

  /// A witness is only summoned once a calling is chosen.
  bool get summoned => calling != null;
}

/// The derived mood for the effective day (keeper.md §4, no-shame guarantee).
final keeperMoodProvider = Provider<KeeperMood>((ref) {
  return ref.watch(keeperUiStateProvider).mood;
});

final keeperUiStateProvider = Provider<KeeperUiState>((ref) {
  final todayAsync = ref.watch(todayStateProvider);
  final completionsAsync = ref.watch(recentCompletionsStreamProvider);
  final profileAsync = ref.watch(profileStreamProvider);
  final profileViewAsync = ref.watch(profileViewStateProvider);
  final allCompletionsAsync = ref.watch(allCompletionsStreamProvider);
  final allQuestsAsync = ref.watch(allQuestsStreamProvider);
  final today = ref.watch(effectiveLocalDateProvider);
  final now = ref.watch(currentDateTimeProvider);
  final weekStart = ref.watch(weekStartProvider);

  final loading = todayAsync.isLoading ||
      completionsAsync.isLoading ||
      profileAsync.isLoading ||
      allCompletionsAsync.isLoading ||
      allQuestsAsync.isLoading;
  if (loading) {
    return const KeeperUiState(
      mood: KeeperMood.dormant,
      anticipation: false,
      stage: KeeperStage.summoned,
      calling: null,
      perfectDays: 0,
      level: 1,
    );
  }

  final state = todayAsync.value;
  final completions = completionsAsync.value ?? const <CompletionData>[];

  // Mood
  var mood = KeeperMood.dormant;
  var anticipation = false;
  if (state != null) {
    final todayKey = today.formatted;
    final completionsToday =
        completions.where((c) => c.localDate == todayKey).length;

    final dueEssentials =
        state.allQuests.where((q) => q.essential && q.isDueToday).toList();
    final essentialsDone = dueEssentials.every((q) => q.isCompleted);

    // Nothing due today → quiescent rest, not dread (keeper.md §5).
    final anythingDue = state.allQuests.any((q) => q.isDueToday);

    final resetMinute = profileAsync.value?.resetMinute ?? 0;
    final minutesIntoDay = now.hour * 60 + now.minute - resetMinute;
    final dayFraction = (minutesIntoDay / 1440.0).clamp(0.0, 1.0);

    mood = keeperMoodFor(
      anythingDue: anythingDue,
      completionsToday: completionsToday,
      essentialsDone: essentialsDone,
      dayFraction: dayFraction,
    );

    // Anticipation (exactly one essential remains — it brightens, never points)
    final unsatisfied =
        dueEssentials.where((q) => !q.isCompleted).length;
    anticipation = unsatisfied == 1;
  }

  // Growth — derived from full-history completions + player level.
  final perfectDays = derivePerfectDays(
    essentialQuests:
        (allQuestsAsync.value ?? const <QuestData>[]).where((q) => q.essential),
    completionsByQuest: _groupCompletions(allCompletionsAsync.value ?? const []),
    weekStart: weekStart,
  ).length;

  final level = profileViewAsync.value?.progression.level ?? 1;
  final callingIndex = profileAsync.value?.calling;
  final calling =
      callingIndex != null ? CallingDomain.values[callingIndex] : null;

  return KeeperUiState(
    mood: mood,
    anticipation: anticipation,
    stage: keeperStageFor(perfectDays: perfectDays, level: level),
    calling: calling,
    perfectDays: perfectDays,
    level: level,
  );
});

/// The Keeper's journal for the sheet (keeper.md §10): all derived.
class KeeperJournal {
  final int daysKeptCompany;
  final int perfectDays;
  final int goalsSeenCompleted;
  final String? favoriteQuest;

  const KeeperJournal({
    required this.daysKeptCompany,
    required this.perfectDays,
    required this.goalsSeenCompleted,
    this.favoriteQuest,
  });
}

final keeperJournalProvider = Provider<KeeperJournal>((ref) {
  final allCompletionsAsync = ref.watch(allCompletionsStreamProvider);
  final allQuestsAsync = ref.watch(allQuestsStreamProvider);
  final allGoalsAsync = ref.watch(allGoalsStreamProvider);
  final ui = ref.watch(keeperUiStateProvider);

  final completions = allCompletionsAsync.value ?? const <CompletionData>[];
  final quests = allQuestsAsync.value ?? const <QuestData>[];
  final goals = allGoalsAsync.value ?? const <GoalData>[];

  final daysKept = completions.map((c) => c.localDate).toSet().length;

  String? favorite;
  var bestStreak = 1;
  for (final grouped in _groupCompletions(completions).entries) {
    final streak = _currentStreak(grouped.value);
    if (streak >= bestStreak) {
      bestStreak = streak;
      final q = quests.where((q) => q.id == grouped.key).firstOrNull;
      if (q != null) favorite = q.title;
    }
  }

  return KeeperJournal(
    daysKeptCompany: daysKept,
    perfectDays: ui.perfectDays,
    goalsSeenCompleted: goals.where((g) => g.completedAt != null).length,
    favoriteQuest: favorite,
  );
});

/// Completion history grouped as `questId -> date -> value`.
Map<String, Map<LocalDate, int>> _groupCompletions(
    Iterable<CompletionData> completions) {
  final map = <String, Map<LocalDate, int>>{};
  for (final c in completions) {
    final d = LocalDate.parse(c.localDate);
    map.putIfAbsent(c.questId, () => {}).update(d, (v) => v + c.value,
        ifAbsent: () => c.value);
  }
  return map;
}

/// Simple current streak over dates (consecutive days with a completion).
int _currentStreak(Map<LocalDate, int> byDate) {
  if (byDate.isEmpty) return 0;
  final dates = byDate.keys.toList()..sort();
  var best = 1;
  var run = 1;
  for (int i = 1; i < dates.length; i++) {
    if (dates[i].differenceInDays(dates[i - 1]) == 1) {
      run++;
    } else {
      run = 1;
    }
    if (run > best) best = run;
  }
  return best;
}

/// Presentation events the Keeper consumes (keeper.md §5 plumbing). Quest rows
/// post beside the write call; the widget animates gaze/poses off this bus.
enum KeeperEventKind { complete, perfectDay, pet }

@immutable
class KeeperEvent {
  final int seq;
  final KeeperEventKind kind;
  final Cadence? cadence;
  final Offset? at;

  const KeeperEvent({
    required this.seq,
    required this.kind,
    this.cadence,
    this.at,
  });
}

/// ChangeNotifier the widget listens to. Events are UI-emitted, never state.
class KeeperEventBus extends ChangeNotifier {
  int _seq = 0;
  KeeperEvent? _last;

  KeeperEvent? get last => _last;

  void post({
    required KeeperEventKind kind,
    Cadence? cadence,
    Offset? at,
  }) {
    _seq++;
    _last = KeeperEvent(seq: _seq, kind: kind, cadence: cadence, at: at);
    notifyListeners();
  }
}

final keeperEventBusProvider = Provider<KeeperEventBus>((ref) {
  final bus = KeeperEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});