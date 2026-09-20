import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../data/db/database.dart';
import '../../domain/engine/freezes.dart';
import '../../domain/engine/schedule_rule.dart';
import '../../domain/engine/settlement.dart';
import '../../domain/engine/streak.dart';
import '../../domain/engine/xp.dart';
import '../../domain/model/models.dart';

class QuestActions {
  final AppDatabase db;
  final _uuid = const Uuid();

  QuestActions(this.db);

  /// Settle closed periods and materialize pending bonuses
  Future<void> settle({
    required LocalDate today,
    required WeekStart weekStart,
    required DateTime now,
  }) async {
    final activeQuests = await db.questsDao.getActiveQuests();
    final profile = await db.profileDao.getProfile();
    final allEvents = await db.ledgerDao.getAllXpEvents();
    final existingEventRefs = allEvents.map((e) => e.ref).toSet();

    final sixtyDaysAgo = today.subtractDays(60);
    final completions = await db.completionsDao.getCompletionsInDateRange(
      sixtyDaysAgo.formatted,
      today.formatted,
    );

    final Map<String, Map<LocalDate, int>> completionsByQuest = {};
    for (final c in completions) {
      final date = LocalDate.parse(c.localDate);
      completionsByQuest.putIfAbsent(c.questId, () => {})[date] =
          (completionsByQuest[c.questId]?[date] ?? 0) + c.value;
    }

    final List<Map<String, dynamic>> questsData = activeQuests
        .map((q) => {
              'id': q.id,
              'essential': q.essential,
              'rule': q.rule,
              'targetValue': q.targetValue,
            })
        .toList();

    LocalDate? profileSettledThrough;
    if (profile.settledThrough != null) {
      try {
        profileSettledThrough = LocalDate.parse(profile.settledThrough!);
      } catch (_) {}
    }

    final settlementResult = SettlementEngine.settle(
      questsData: questsData,
      completionsByQuest: completionsByQuest,
      profileSettledThrough: profileSettledThrough,
      today: today,
      weekStart: weekStart,
      existingEventRefs: existingEventRefs,
    );

    if (settlementResult.newEvents.isNotEmpty || settlementResult.profileSettledThrough != null) {
      await db.transaction(() async {
        for (final event in settlementResult.newEvents) {
          await db.ledgerDao.insertXpEvent(
            XpEventsCompanion(
              id: Value(_uuid.v4()),
              type: Value(event.type.index),
              ref: Value(event.ref),
              periodRef: Value(event.periodRef),
              amount: Value(event.amount),
              localDate: Value(event.localDate.formatted),
              createdAt: Value(now),
            ),
          );
        }

        if (settlementResult.profileSettledThrough != null) {
          await db.profileDao.updateSettledThrough(
            settlementResult.profileSettledThrough!.formatted,
          );
        }
      });
    }
  }

  /// Complete a quest (or increment its counter) for a scoring date
  Future<String> completeQuest({
    required QuestData quest,
    required LocalDate date,
    int incrementValue = 1,
    String? note,
    required WeekStart weekStart,
    String timezone = 'UTC',
    required DateTime now,
  }) async {
    final completionId = _uuid.v4();

    // 1. Get current completions in period to calculate incremental XP
    final period = quest.rule.periodOf(date, weekStart);
    final completionsInPeriod = await db.completionsDao.getCompletionsInDateRange(
      period.startLocalDate.formatted,
      period.endLocalDate.formatted,
    );

    int prevCount = 0;
    for (final c in completionsInPeriod) {
      if (c.questId == quest.id) {
        final cDate = LocalDate.parse(c.localDate);
        if (quest.rule is WeeklyRule &&
            (quest.rule as WeeklyRule).allowedDays != null &&
            (quest.rule as WeeklyRule).allowedDays!.isNotEmpty) {
          if ((quest.rule as WeeklyRule).allowedDays!.contains(cDate.toDateTime().weekday)) {
            prevCount += c.value;
          }
        } else {
          prevCount += c.value;
        }
      }
    }

    final isScheduled = quest.rule is WeeklyRule &&
            (quest.rule as WeeklyRule).allowedDays != null &&
            (quest.rule as WeeklyRule).allowedDays!.isNotEmpty
        ? (quest.rule as WeeklyRule).allowedDays!.contains(date.toDateTime().weekday)
        : (quest.rule.isWindowScheduled
            ? period.contains(date)
            : quest.rule.isScheduledOn(date));

    final newCount = isScheduled ? (prevCount + incrementValue) : prevCount;

    int target = quest.targetValue;
    if (quest.rule is WeeklyRule && (quest.rule as WeeklyRule).times != null) {
      target = (quest.rule as WeeklyRule).times!;
    } else if (quest.rule is MonthlyRule && (quest.rule as MonthlyRule).times != null) {
      target = (quest.rule as MonthlyRule).times!;
    } else if (quest.rule is YearlyRule && (quest.rule as YearlyRule).times != null) {
      target = (quest.rule as YearlyRule).times!;
    }

    final xpAmount = XpEngine.calculateIncrementalXp(
      rule: quest.rule,
      difficulty: Difficulty.values[quest.difficulty],
      target: target,
      previousCount: prevCount,
      newCount: newCount,
      isScheduled: isScheduled,
    );

    final periodKey = quest.rule.periodKey(period.startLocalDate, weekStart);

    await db.transaction(() async {
      // Insert completion row
      await db.completionsDao.insertCompletion(
        CompletionsCompanion(
          id: Value(completionId),
          questId: Value(quest.id),
          localDate: Value(date.formatted),
          value: Value(incrementValue),
          note: Value(note),
          timezone: Value(timezone),
          createdAt: Value(now),
        ),
      );

      // Insert XP event if any XP earned
      if (xpAmount > 0) {
        await db.ledgerDao.insertXpEvent(
          XpEventsCompanion(
            id: Value(_uuid.v4()),
            type: Value(XpEventType.quest.index),
            ref: Value(completionId),
            periodRef: Value('${quest.id}|$periodKey'),
            amount: Value(xpAmount),
            localDate: Value(date.formatted),
            createdAt: Value(now),
          ),
        );
      }
    });

    // Run settlement
    await settle(today: date, weekStart: weekStart, now: now);

    // Spend wallet freezes on any missed periods the balance covers.
    await consumeFreezes(today: date, weekStart: weekStart, now: now);

    return completionId;
  }

  /// Spend wallet freezes on missed periods (essential quests first,
  /// then oldest) and persist the repairs. Runs after a completion is
  /// recorded; repairs are backdated to the missed period via periodKey.
  /// Stale repairs are harmless: satisfied periods hit the satisfied branch
  /// before the repair check, so an unneeded repair never changes a streak.
  Future<void> consumeFreezes({
    required LocalDate today,
    required WeekStart weekStart,
    required DateTime now,
  }) async {
    final quests = await db.questsDao.getActiveQuests();
    if (quests.isEmpty) return;
    final completions = await db.completionsDao.getAllCompletions();
    final repairs = await db.ledgerDao.getStreakRepairs();

    final completionsByQuest = <String, Map<LocalDate, int>>{};
    for (final c in completions) {
      final d = LocalDate.parse(c.localDate);
      completionsByQuest.putIfAbsent(c.questId, () => {})[d] =
          (completionsByQuest[c.questId]![d] ?? 0) + c.value;
    }

    var wallet = FreezeEngine.walletBalance(
      quests: quests,
      completionsByQuest: completionsByQuest,
      repairs: repairs,
      weekStart: weekStart,
      today: today,
    );
    if (wallet <= 0) return;

    final persisted = <String, Set<String>>{};
    for (final r in repairs) {
      persisted.putIfAbsent(r.questId, () => {}).add(r.periodKey);
    }

    final ordered = quests.toList()
      ..sort((a, b) {
        if (a.essential != b.essential) return a.essential ? -1 : 1;
        final c = a.createdAt.compareTo(b.createdAt);
        if (c != 0) return c;
        return a.id.compareTo(b.id);
      });

    for (final q in ordered) {
      if (wallet <= 0) break;
      final qCompletions = completionsByQuest[q.id] ?? {};
      LocalDate? firstDate;
      for (final d in qCompletions.keys) {
        if (firstDate == null || d < firstDate) firstDate = d;
      }
      final res = StreakEngine.calculate(
        rule: q.rule,
        targetType: TargetType.values[q.targetType],
        targetValue: q.targetValue,
        completionValues: qCompletions,
        existingRepairs: persisted[q.id] ?? {},
        today: today,
        weekStart: weekStart,
        firstCompletionDate: firstDate,
        pausedUntil:
            q.pausedUntil != null ? LocalDate.parse(q.pausedUntil!) : null,
        availableFreezeWallet: wallet,
      );
      for (final pKey in res.newlyConsumedRepairs) {
        await db.ledgerDao.insertStreakRepair(
          StreakRepairsCompanion(
            id: Value(_uuid.v4()),
            questId: Value(q.id),
            periodKey: Value(pKey),
            appliedAt: Value(now),
          ),
        );
        persisted.putIfAbsent(q.id, () => {}).add(pKey);
        wallet--;
      }
    }
  }

  /// Undo a completion within the undo window
  Future<void> undoCompletion(String completionId, {LocalDate? today, WeekStart? weekStart, DateTime? now}) async {
    await db.transaction(() async {
      await db.completionsDao.deleteCompletion(completionId);
      await db.ledgerDao.deleteXpEventsByRef(completionId);
    });

    if (today != null && weekStart != null && now != null) {
      await settle(today: today, weekStart: weekStart, now: now);
    }
  }

  /// Decrement a counter quest by removing its latest completion log entry on date
  Future<void> decrementQuest({
    required String questId,
    required LocalDate date,
    required WeekStart weekStart,
    required DateTime now,
  }) async {
    final completions = await db.completionsDao.getCompletionsInDateRange(date.formatted, date.formatted);
    final questCompletions = completions.where((c) => c.questId == questId).toList();
    if (questCompletions.isNotEmpty) {
      final latest = questCompletions.last;
      await undoCompletion(latest.id, today: date, weekStart: weekStart, now: now);
    }
  }

  /// Create a new quest
  Future<String> createQuest({
    required String title,
    String? note,
    required ScheduleRule rule,
    required TargetType targetType,
    int targetValue = 1,
    String? unit,
    required Difficulty difficulty,
    bool essential = false,
    String? goalId,
    CallingDomain? domain,
    int? reminderMinute,
    required DateTime now,
    LocalDate? today,
    WeekStart? weekStart,
  }) async {
    final id = _uuid.v4();
    await db.questsDao.insertQuest(
      QuestsCompanion(
        id: Value(id),
        title: Value(title),
        note: Value(note),
        rule: Value(rule),
        targetType: Value(targetType.index),
        targetValue: Value(targetValue),
        unit: Value(unit),
        difficulty: Value(difficulty.index),
        essential: Value(essential),
        goalId: Value(goalId),
        domain: Value(domain?.index),
        reminderMinute: Value(reminderMinute),
        createdAt: Value(now),
      ),
    );

    if (today != null && weekStart != null) {
      await settle(today: today, weekStart: weekStart, now: now);
    }

    return id;
  }

  /// Update an existing quest
  Future<void> updateQuest({
    required String id,
    required String title,
    String? note,
    required ScheduleRule rule,
    required TargetType targetType,
    int targetValue = 1,
    String? unit,
    required Difficulty difficulty,
    bool essential = false,
    String? goalId,
    CallingDomain? domain,
    int? reminderMinute,
    String? pausedUntil,
    DateTime? archivedAt,
    required DateTime createdAt,
    LocalDate? today,
    WeekStart? weekStart,
    DateTime? now,
  }) async {
    await db.questsDao.updateQuest(
      QuestsCompanion(
        id: Value(id),
        title: Value(title),
        note: Value(note),
        rule: Value(rule),
        targetType: Value(targetType.index),
        targetValue: Value(targetValue),
        unit: Value(unit),
        difficulty: Value(difficulty.index),
        essential: Value(essential),
        goalId: Value(goalId),
        domain: Value(domain?.index),
        reminderMinute: Value(reminderMinute),
        pausedUntil: Value(pausedUntil),
        archivedAt: Value(archivedAt),
        createdAt: Value(createdAt),
      ),
    );

    if (today != null && weekStart != null && now != null) {
      await settle(today: today, weekStart: weekStart, now: now);
    }
  }

  /// Pause a quest until a local date
  Future<void> pauseQuest(String questId, LocalDate? pausedUntil) async {
    await db.questsDao.pauseQuest(questId, pausedUntil?.formatted);
  }

  /// Archive a quest
  Future<void> archiveQuest(String questId, DateTime now) async {
    await db.questsDao.archiveQuest(questId, now);
  }

  /// Update target value (safe edit)
  Future<void> updateTargetValue(String questId, int targetValue) async {
    await db.questsDao.updateTargetValue(questId, targetValue);
  }

  /// Update difficulty (safe edit)
  Future<void> updateDifficulty(String questId, Difficulty difficulty) async {
    await db.questsDao.updateDifficulty(questId, difficulty.index);
  }
}
