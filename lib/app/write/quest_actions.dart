import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../data/db/database.dart';
import '../../domain/engine/schedule_rule.dart';
import '../../domain/engine/settlement.dart';
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
    final activeQuests = await db.questsDao.getAllActiveQuests();
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
        prevCount += c.value;
      }
    }

    final newCount = prevCount + incrementValue;

    int target = quest.targetValue;
    if (quest.rule is WeeklyRule && (quest.rule as WeeklyRule).times != null) {
      target = (quest.rule as WeeklyRule).times!;
    } else if (quest.rule is MonthlyRule && (quest.rule as MonthlyRule).times != null) {
      target = (quest.rule as MonthlyRule).times!;
    } else if (quest.rule is YearlyRule && (quest.rule as YearlyRule).times != null) {
      target = (quest.rule as YearlyRule).times!;
    }

    final isScheduled = quest.rule.isWindowScheduled
        ? period.contains(date)
        : quest.rule.isScheduledOn(date);

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

    return completionId;
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
}
