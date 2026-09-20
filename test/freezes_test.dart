import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app/write/quest_actions.dart';
import 'package:questlog/data/db/database.dart';
import 'package:questlog/domain/constants/xp_constants.dart';
import 'package:questlog/domain/engine/freezes.dart';
import 'package:questlog/domain/engine/settlement.dart';
import 'package:questlog/domain/engine/streak.dart';
import 'package:questlog/domain/engine/schedule_rule.dart';
import 'package:questlog/domain/model/models.dart';
import 'package:questlog/ui/theme/app_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/chips.dart';

const _monday = WeekStart.monday;

/// A daily quest starting May 2026 (before every fixture week).
QuestData _daily(String id, {bool essential = true}) => QuestData(
      id: id,
      title: 'Quest $id',
      rule: const DailyEveryDayRule(),
      targetType: 0,
      targetValue: 1,
      difficulty: 1,
      essential: essential,
      createdAt: DateTime(2026, 5, 1),
    );

/// Full-value completions for each date in [days] (June 2026).
Map<LocalDate, int> _days(List<int> days) => {
      for (final d in days) LocalDate(2026, 6, d): 1,
    };

void main() {
  group('FreezeEngine.weeklyGrants', () {
    test('perfect daily week grants 2', () {
      final grants = FreezeEngine.weeklyGrants(
        quests: [_daily('q')],
        completionsByQuest: {
          'q': _days([1, 2, 3, 4, 5, 6, 7]),
        },
        weekStart: _monday,
        today: LocalDate(2026, 6, 8),
      );
      expect(grants.length, equals(1));
      expect(grants.single.grants, equals(2));
    });

    test('monthly quest with zero completions does not block a perfect week', () {
      final monthly = QuestData(
        id: 'qm',
        title: 'Monthly',
        // Scheduled Jun 3 (inside the week), untouched: blocks under the
        // old all-cadence scope, skipped under daily+weekly scope.
        rule: const MonthlyDayOfMonthRule(day: 3),
        targetType: 0,
        targetValue: 1,
        difficulty: 1,
        essential: false,
        createdAt: DateTime(2026, 5, 1),
      );
      final grants = FreezeEngine.weeklyGrants(
        quests: [_daily('q'), monthly],
        completionsByQuest: {
          'q': _days([1, 2, 3, 4, 5, 6, 7]),
        },
        weekStart: _monday,
        today: LocalDate(2026, 6, 8),
      );
      expect(grants.single.grants, equals(2));
    });

    test('essentials-only week grants 1 (no stacking)', () {
      final grants = FreezeEngine.weeklyGrants(
        quests: [_daily('e'), _daily('n', essential: false)],
        completionsByQuest: {
          'e': _days([1, 2, 3, 4, 5, 6, 7]),
          // Non-essential untouched all week: week imperfect, essentials clean.
          'n': const <LocalDate, int>{},
        },
        weekStart: _monday,
        today: LocalDate(2026, 6, 8),
      );
      expect(grants.single.grants, equals(1));
    });

    test('perfect week with essentials grants exactly 2, not 3', () {
      final grants = FreezeEngine.weeklyGrants(
        quests: [_daily('e'), _daily('n', essential: false)],
        completionsByQuest: {
          'e': _days([1, 2, 3, 4, 5, 6, 7]),
          'n': _days([1, 2, 3, 4, 5, 6, 7]),
        },
        weekStart: _monday,
        today: LocalDate(2026, 6, 8),
      );
      expect(grants.single.grants, equals(2));
    });

    test('imperfect week with no essentials satisfied grants 0', () {
      final grants = FreezeEngine.weeklyGrants(
        quests: [_daily('a'), _daily('n', essential: false)],
        completionsByQuest: {
          'a': _days([1, 2, 3, 4, 5, 6, 7]),
          'n': _days([1, 2, 3, 4, 5, 6, 7]),
        },
        weekStart: _monday,
        today: LocalDate(2026, 6, 15),
      );
      expect(grants.length, equals(2));
      expect(grants[0].grants, equals(2));
      // Week 2: nothing logged — scheduled essentials unsatisfied, no grant.
      expect(grants[1].grants, equals(0));
    });

    test('open week never grants, even when perfect so far', () {
      final grants = FreezeEngine.weeklyGrants(
        quests: [_daily('q')],
        completionsByQuest: {
          'q': _days([1, 2, 3]),
        },
        weekStart: _monday,
        today: LocalDate(2026, 6, 3),
      );
      expect(grants, isEmpty);
    });

    test('no daily/weekly quests grants nothing', () {
      final monthly = QuestData(
        id: 'qm',
        title: 'Monthly',
        rule: const MonthlyDayOfMonthRule(day: 15),
        targetType: 0,
        targetValue: 1,
        difficulty: 1,
        essential: false,
        createdAt: DateTime(2026, 5, 1),
      );
      expect(
        FreezeEngine.weeklyGrants(
          quests: [monthly],
          completionsByQuest: const {},
          weekStart: _monday,
          today: LocalDate(2026, 6, 8),
        ),
        isEmpty,
      );
    });
  });

  group('FreezeEngine wallet replay', () {
    List<WeeklyFreezeGrant> weeks(List<int> grants) => [
          for (var i = 0; i < grants.length; i++)
            WeeklyFreezeGrant(
              weekEndDay: LocalDate(2026, 6, 7 + 7 * i),
              grants: grants[i],
            ),
        ];

    test('cap is 5: three perfect weeks hold 5, not 6', () {
      const repairs = <StreakRepairData>[];
      expect(
        FreezeEngine.replayWallet(grants: weeks([2, 2, 2]), repairs: repairs),
        equals(5),
      );
      expect(
        FreezeEngine.peakWallet(grants: weeks([2, 2, 2]), repairs: repairs),
        equals(5),
      );
    });

    test('chronological replay: grant, repair, grant', () {
      final repairs = [
        StreakRepairData(
          id: 'r1',
          questId: 'q',
          periodKey: '2026-06-10',
          appliedAt: DateTime(2026, 6, 10, 10, 0),
        ),
      ];
      // 2 - 1 + 2 = 3 final; peak 3 (2, then 1, then 3).
      expect(
        FreezeEngine.replayWallet(grants: weeks([2, 2]), repairs: repairs),
        equals(3),
      );
      expect(
        FreezeEngine.peakWallet(grants: weeks([2, 2]), repairs: repairs),
        equals(3),
      );
    });

    test('peak survives later spend (hold-2 badge math)', () {
      final repairs = [
        for (var i = 0; i < 2; i++)
          StreakRepairData(
            id: 'r$i',
            questId: 'q',
            periodKey: '2026-06-${10 + i}',
            appliedAt: DateTime(2026, 6, 20, 10, 0),
          ),
      ];
      expect(
        FreezeEngine.replayWallet(grants: weeks([2]), repairs: repairs),
        equals(0),
      );
      expect(
        FreezeEngine.peakWallet(grants: weeks([2]), repairs: repairs),
        equals(2),
      );
    });

    test('ties break toward grants', () {
      final repairs = [
        StreakRepairData(
          id: 'r1',
          questId: 'q',
          periodKey: '2026-06-07',
          appliedAt: DateTime(2026, 6, 7), // same instant as the grant
        ),
      ];
      // Grant first: 0 + 2 - 1 = 1 (repair-first would clamp at 0, then +2).
      expect(
        FreezeEngine.replayWallet(grants: weeks([2]), repairs: repairs),
        equals(1),
      );
    });
  });

  group('StreakEngine.bestStreak', () {
    test('broken streak keeps the historical best', () {
      // 10-day run, 5-day gap, 3-day run including today.
      final done = {
        for (var d = 1; d <= 10; d++) LocalDate(2026, 6, d): 1,
        for (var d = 16; d <= 18; d++) LocalDate(2026, 6, d): 1,
      };
      final res = StreakEngine.calculate(
        rule: const DailyEveryDayRule(),
        targetValue: 1,
        completionValues: done,
        existingRepairs: const {},
        today: LocalDate(2026, 6, 18),
        weekStart: _monday,
        firstCompletionDate: LocalDate(2026, 6, 1),
      );
      expect(res.streak, equals(3));
      expect(res.bestStreak, equals(10));
    });

    test('unbroken run: best equals current', () {
      final done = {
        for (var d = 1; d <= 7; d++) LocalDate(2026, 6, d): 1,
      };
      final res = StreakEngine.calculate(
        rule: const DailyEveryDayRule(),
        targetValue: 1,
        completionValues: done,
        existingRepairs: const {},
        today: LocalDate(2026, 6, 7),
        weekStart: _monday,
        firstCompletionDate: LocalDate(2026, 6, 1),
      );
      expect(res.streak, equals(7));
      expect(res.bestStreak, equals(7));
    });
  });

  group('Settlement perfect-week scope', () {
    test('unsatisfied monthly quest no longer blocks the week (+75 XP kept)', () {
      final monthly = QuestData(
        id: 'qm',
        title: 'Monthly',
        // Scheduled Jun 3 (inside the week), untouched.
        rule: const MonthlyDayOfMonthRule(day: 3),
        targetType: 0,
        targetValue: 1,
        difficulty: 1,
        essential: false,
        createdAt: DateTime(2026, 5, 1),
      );
      final result = SettlementEngine.settle(
        questsData: [
          {
            'id': 'q',
            'essential': true,
            'rule': const DailyEveryDayRule(),
            'targetValue': 1,
          },
          {
            'id': 'qm',
            'essential': false,
            'rule': monthly.rule,
            'targetValue': 1,
          },
        ],
        completionsByQuest: {
          'q': _days([1, 2, 3, 4, 5, 6, 7]),
        },
        profileSettledThrough: LocalDate(2026, 5, 31),
        today: LocalDate(2026, 6, 8),
        weekStart: _monday,
        existingEventRefs: const {},
      );
      final weekEvents =
          result.newEvents.where((e) => e.type == XpEventType.perfectWeek);
      expect(weekEvents.length, equals(1));
      expect(weekEvents.single.ref, equals('perfect_week:2026-06-01'));
      expect(
        weekEvents.single.amount,
        equals(XpConstants.perfectWeekBonus),
      );
    });
  });

  group('consume-on-write integration (in-memory DB)', () {
    test('a miss spends one freeze, persists the repair, preserves the run',
        () async {
      final db = AppDatabase(NativeDatabase.memory());
      final actions = QuestActions(db);

      await db.questsDao.insertQuest(
        QuestsCompanion(
          id: const Value('q_freeze'),
          title: const Value('Daily'),
          rule: const Value(DailyEveryDayRule()),
          difficulty: const Value(1),
          essential: const Value(true),
          createdAt: Value(DateTime(2026, 5, 1)),
        ),
      );

      String ds(int day) => '2026-06-${day.toString().padLeft(2, '0')}';
      // Perfect week Jun 1-7 (2 grants), then daily through Jun 13
      // with Jun 10 missed.
      for (final day in [1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13]) {
        await db.completionsDao.insertCompletion(
          CompletionsCompanion(
            id: Value('seed_$day'),
            questId: const Value('q_freeze'),
            localDate: Value(ds(day)),
            timezone: const Value('UTC'),
            createdAt: Value(DateTime(2026, 6, day, 10, 0)),
          ),
        );
      }

      final quests = await db.questsDao.getActiveQuests();
      await actions.completeQuest(
        quest: quests.singleWhere((q) => q.id == 'q_freeze'),
        date: LocalDate(2026, 6, 14),
        weekStart: _monday,
        now: DateTime(2026, 6, 14, 10, 0),
      );

      // Exactly one repair, backdated to the missed day.
      final repairs = await db.ledgerDao.getStreakRepairs();
      expect(repairs.length, equals(1));
      expect(repairs.single.questId, equals('q_freeze'));
      expect(repairs.single.periodKey, equals('2026-06-10'));

      // Wallet: 2 grants - 1 repair = 1.
      final allCompletions = await db.completionsDao.getAllCompletions();
      final byQuest = <String, Map<LocalDate, int>>{};
      for (final c in allCompletions) {
        final d = LocalDate.parse(c.localDate);
        byQuest.putIfAbsent(c.questId, () => {})[d] =
            (byQuest[c.questId]![d] ?? 0) + c.value;
      }
      expect(
        FreezeEngine.walletBalance(
          quests: quests,
          completionsByQuest: byQuest,
          repairs: repairs,
          weekStart: _monday,
          today: LocalDate(2026, 6, 14),
        ),
        equals(1),
      );

      // The run bridges the repaired miss: 9 + 4 = 13, not 4.
      final res = StreakEngine.calculate(
        rule: const DailyEveryDayRule(),
        targetValue: 1,
        completionValues: byQuest['q_freeze']!,
        existingRepairs: {repairs.single.periodKey},
        today: LocalDate(2026, 6, 14),
        weekStart: _monday,
        firstCompletionDate: LocalDate(2026, 6, 1),
      );
      expect(res.streak, equals(13));

      await db.close();
    });
  });

  group('FreezeChip', () {
    testWidgets('shows count over the cap-5 capacity', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildTheme(isDark: true, accentTheme: AccentTheme.frost),
          home: const Scaffold(
            body: FreezeChip(count: 3),
          ),
        ),
      );
      expect(find.text('3/5'), findsOneWidget);
    });
  });
}
