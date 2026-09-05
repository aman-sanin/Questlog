import 'dart:math';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app/providers/database_provider.dart';
import 'package:questlog/data/db/database.dart';
import 'package:questlog/domain/constants/tunables.dart';
import 'package:questlog/domain/engine/coach.dart';
import 'package:questlog/domain/engine/schedule_rule.dart';
import 'package:questlog/domain/model/models.dart';
import 'package:questlog/ui/screens/profile_screen.dart';
import 'package:questlog/ui/screens/settings_screen.dart';
import 'package:questlog/ui/screens/today_screen.dart';
import 'package:questlog/ui/theme/app_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

void main() {
  final today = LocalDate(2026, 9, 1);
  const weekStart = WeekStart.monday;

  QuestHistoryData makeQuest({
    String id = 'q1',
    String title = 'Meditate',
    ScheduleRule rule = const DailyRule.everyDay(),
    TargetType targetType = TargetType.checkbox,
    int targetValue = 1,
    Difficulty difficulty = Difficulty.easy,
    bool essential = false,
    DateTime? createdAt,
    DateTime? archivedAt,
    LocalDate? pausedUntil,
    Map<LocalDate, int> completions = const {},
    int currentStreak = 0,
    bool isSatisfiedToday = false,
  }) {
    return QuestHistoryData(
      id: id,
      title: title,
      rule: rule,
      targetType: targetType,
      targetValue: targetValue,
      difficulty: difficulty,
      essential: essential,
      createdAt: createdAt ?? DateTime(2026, 7, 1),
      archivedAt: archivedAt,
      pausedUntil: pausedUntil,
      completions: completions,
      currentStreak: currentStreak,
      isSatisfiedToday: isSatisfiedToday,
    );
  }

  group('Coach Detectors (Pure)', () {
    test('1. welcome_back fires at >= 14d absence and not under', () {
      final signals14 = CoachEngine.evaluateAll(
        activeQuests: [],
        today: today,
        weekStart: weekStart,
        lastActiveDate: today.subtractDays(14),
      );
      expect(signals14.any((s) => s.ruleType == CoachRuleType.welcomeBack), isTrue);
      expect(signals14.first.cooldownDays, equals(60));

      final signals13 = CoachEngine.evaluateAll(
        activeQuests: [],
        today: today,
        weekStart: weekStart,
        lastActiveDate: today.subtractDays(13),
      );
      expect(signals13.any((s) => s.ruleType == CoachRuleType.welcomeBack), isFalse);
    });

    test('2. backup_nudge fires at >= 50 completions and > 45d since export', () {
      final signals50 = CoachEngine.evaluateAll(
        activeQuests: [],
        today: today,
        weekStart: weekStart,
        lifetimeCompletions: 50,
        lastExportDate: today.subtractDays(46),
      );
      expect(signals50.any((s) => s.ruleType == CoachRuleType.backupNudge), isTrue);

      final signals45 = CoachEngine.evaluateAll(
        activeQuests: [],
        today: today,
        weekStart: weekStart,
        lifetimeCompletions: 50,
        lastExportDate: today.subtractDays(45),
      );
      expect(signals45.any((s) => s.ruleType == CoachRuleType.backupNudge), isFalse);

      final signals49 = CoachEngine.evaluateAll(
        activeQuests: [],
        today: today,
        weekStart: weekStart,
        lifetimeCompletions: 49,
        lastExportDate: today.subtractDays(100),
      );
      expect(signals49.any((s) => s.ruleType == CoachRuleType.backupNudge), isFalse);
    });

    test('3. essential_stumble fires on >= 3 consecutive misses on essential quest', () {
      final comps3 = <LocalDate, int>{};
      final q3 = makeQuest(
        essential: true,
        createdAt: DateTime(2026, 8, 1),
        completions: comps3,
      );

      final signals = CoachEngine.evaluateAll(
        activeQuests: [q3],
        today: today,
        weekStart: weekStart,
      );
      expect(signals.any((s) => s.ruleType == CoachRuleType.essentialStumble), isTrue);
      final stumbleSignal = signals.firstWhere((s) => s.ruleType == CoachRuleType.essentialStumble);
      expect(stumbleSignal.cooldownDays, equals(14));

      final comps2 = <LocalDate, int>{
        today.subtractDays(3): 1,
      };
      final q2 = makeQuest(
        essential: true,
        createdAt: DateTime(2026, 8, 1),
        completions: comps2,
      );
      final signals2 = CoachEngine.evaluateAll(
        activeQuests: [q2],
        today: today,
        weekStart: weekStart,
      );
      expect(signals2.any((s) => s.ruleType == CoachRuleType.essentialStumble), isFalse);
    });

    test('5. zombie fires on >= 14d created with 0 completions', () {
      final qZombie = makeQuest(
        createdAt: DateTime(2026, 8, 1),
        completions: {},
      );
      final signals = CoachEngine.evaluateAll(
        activeQuests: [qZombie],
        today: today,
        weekStart: weekStart,
      );
      expect(signals.any((s) => s.ruleType == CoachRuleType.zombie), isTrue);

      final qRecent = makeQuest(
        createdAt: DateTime(2026, 8, 25),
        completions: {},
      );
      final signalsRecent = CoachEngine.evaluateAll(
        activeQuests: [qRecent],
        today: today,
        weekStart: weekStart,
      );
      expect(signalsRecent.any((s) => s.ruleType == CoachRuleType.zombie), isFalse);
    });

    test('6. stale fires on last completion >= 30d and active', () {
      final qStale = makeQuest(
        completions: {
          today.subtractDays(30): 1,
        },
      );
      final signals = CoachEngine.evaluateAll(
        activeQuests: [qStale],
        today: today,
        weekStart: weekStart,
      );
      expect(signals.any((s) => s.ruleType == CoachRuleType.stale), isTrue);

      final qFresh = makeQuest(
        completions: {
          today.subtractDays(29): 1,
        },
      );
      final signalsFresh = CoachEngine.evaluateAll(
        activeQuests: [qFresh],
        today: today,
        weekStart: weekStart,
      );
      expect(signalsFresh.any((s) => s.ruleType == CoachRuleType.stale), isFalse);
    });

    test('7. rightsize fires on rate < 50% over 14d (with >= 10 periods)', () {
      final comps = <LocalDate, int>{
        today.subtractDays(1): 1,
        today.subtractDays(2): 1,
        today.subtractDays(3): 1,
        today.subtractDays(4): 1,
      };
      final q = makeQuest(
        createdAt: DateTime(2026, 8, 1),
        completions: comps,
      );
      final signals = CoachEngine.evaluateAll(
        activeQuests: [q],
        today: today,
        weekStart: weekStart,
      );
      expect(signals.any((s) => s.ruleType == CoachRuleType.rightsize), isTrue);

      final compsHigh = <LocalDate, int>{
        for (int i = 1; i <= 8; i++) today.subtractDays(i): 1,
      };
      final qHigh = makeQuest(
        createdAt: DateTime(2026, 8, 1),
        completions: compsHigh,
      );
      final signalsHigh = CoachEngine.evaluateAll(
        activeQuests: [qHigh],
        today: today,
        weekStart: weekStart,
      );
      expect(signalsHigh.any((s) => s.ruleType == CoachRuleType.rightsize), isFalse);
    });

    test('8. mastery fires on rate >= 90% and streak >= 7', () {
      final comps = <LocalDate, int>{
        for (int i = 0; i < 14; i++) today.subtractDays(i): 1,
      };
      final q = makeQuest(
        createdAt: DateTime(2026, 8, 1),
        completions: comps,
        currentStreak: 14,
      );
      final signals = CoachEngine.evaluateAll(
        activeQuests: [q],
        today: today,
        weekStart: weekStart,
      );
      expect(signals.any((s) => s.ruleType == CoachRuleType.mastery), isTrue);

      final comps85 = <LocalDate, int>{
        for (int i = 0; i < 12; i++) today.subtractDays(i): 1,
      };
      final q85 = makeQuest(
        createdAt: DateTime(2026, 8, 1),
        completions: comps85,
        currentStreak: 7,
      );
      final signals85 = CoachEngine.evaluateAll(
        activeQuests: [q85],
        today: today,
        weekStart: weekStart,
      );
      expect(signals85.any((s) => s.ruleType == CoachRuleType.mastery), isFalse);
    });

    test('9. milestone_near fires on streak in {6, 29, 99, 364} and unsatisfied today', () {
      final qMilestone = makeQuest(
        currentStreak: 6,
        isSatisfiedToday: false,
      );
      final signals = CoachEngine.evaluateAll(
        activeQuests: [qMilestone],
        today: today,
        weekStart: weekStart,
      );
      expect(signals.any((s) => s.ruleType == CoachRuleType.milestoneNear), isTrue);
      final sig = signals.firstWhere((s) => s.ruleType == CoachRuleType.milestoneNear);
      expect(sig.dedupKey, equals('coach:milestone:q1:7'));
      expect(sig.message, contains('+50 XP'));

      final qSatisfied = makeQuest(
        currentStreak: 6,
        isSatisfiedToday: true,
      );
      final signalsSatisfied = CoachEngine.evaluateAll(
        activeQuests: [qSatisfied],
        today: today,
        weekStart: weekStart,
      );
      expect(signalsSatisfied.any((s) => s.ruleType == CoachRuleType.milestoneNear), isFalse);
    });

    test('4. load detector fires when >= 6 quests under 50% or >= 3 quests share health rule', () {
      final q1 = makeQuest(id: 'q1', title: 'Q1', createdAt: DateTime(2026, 8, 1), completions: {});
      final q2 = makeQuest(id: 'q2', title: 'Q2', createdAt: DateTime(2026, 8, 1), completions: {});
      final q3 = makeQuest(id: 'q3', title: 'Q3', createdAt: DateTime(2026, 8, 1), completions: {});

      final signals = CoachEngine.evaluateAll(
        activeQuests: [q1, q2, q3],
        today: today,
        weekStart: weekStart,
      );
      expect(signals.any((s) => s.ruleType == CoachRuleType.load), isTrue);
      expect(signals.any((s) => s.ruleType == CoachRuleType.zombie), isFalse);
    });

    test('10. perfect_week_near fires on daysLeft <= 1 and exactly 1 unsatisfied essential unit', () {
      final signals = CoachEngine.evaluateAll(
        activeQuests: [],
        today: today,
        weekStart: weekStart,
        daysLeftInWeek: 1,
        unsatisfiedEssentialThisWeek: 1,
      );
      expect(signals.any((s) => s.ruleType == CoachRuleType.perfectWeekNear), isTrue);

      final signals2 = CoachEngine.evaluateAll(
        activeQuests: [],
        today: today,
        weekStart: weekStart,
        daysLeftInWeek: 1,
        unsatisfiedEssentialThisWeek: 2,
      );
      expect(signals2.any((s) => s.ruleType == CoachRuleType.perfectWeekNear), isFalse);
    });
  });

  group('Determinism & Ranking Hierarchy', () {
    test('Hierarchy order is strictly preserved and deterministic', () {
      final qEssential = makeQuest(id: 'q_ess', title: 'Essential', essential: true, createdAt: DateTime(2026, 8, 1), completions: {});
      final qZombie = makeQuest(id: 'q_zomb', title: 'Zombie', createdAt: DateTime(2026, 8, 1), completions: {});

      final signals1 = CoachEngine.evaluateAll(
        activeQuests: [qEssential, qZombie],
        today: today,
        weekStart: weekStart,
        lastActiveDate: today.subtractDays(20),
        lifetimeCompletions: 60,
        lastExportDate: today.subtractDays(50),
      );

      final signals2 = CoachEngine.evaluateAll(
        activeQuests: [qEssential, qZombie],
        today: today,
        weekStart: weekStart,
        lastActiveDate: today.subtractDays(20),
        lifetimeCompletions: 60,
        lastExportDate: today.subtractDays(50),
      );

      expect(signals1.length, equals(signals2.length));
      for (int i = 0; i < signals1.length; i++) {
        expect(signals1[i].ruleType, equals(signals2[i].ruleType));
        expect(signals1[i].message, equals(signals2[i].message));
      }

      expect(signals1[0].ruleType, equals(CoachRuleType.welcomeBack));
      expect(signals1[1].ruleType, equals(CoachRuleType.backupNudge));
      expect(signals1[2].ruleType, equals(CoachRuleType.essentialStumble));
    });
  });

  group('Player Name Addressing', () {
    test('Personalizes title and opening copy when name is present', () {
      final q = makeQuest(
        createdAt: DateTime(2026, 8, 1),
        completions: {
          for (int i = 0; i < 14; i++) today.subtractDays(i): 1,
        },
        currentStreak: 14,
      );

      final namedSignals = CoachEngine.evaluateAll(
        activeQuests: [q],
        today: today,
        weekStart: weekStart,
        userName: 'Galahad',
      );

      expect(namedSignals.first.title, equals('COACH · GALAHAD'));
      expect(namedSignals.first.message, startsWith('Galahad, Meditate is at 100%'));

      final anonymousSignals = CoachEngine.evaluateAll(
        activeQuests: [q],
        today: today,
        weekStart: weekStart,
        userName: null,
      );

      expect(anonymousSignals.first.title, equals('COACH'));
      expect(anonymousSignals.first.message, startsWith('Meditate is at 100%'));
    });
  });

  group('Copy Linter (No exclamation marks, No should)', () {
    test('All possible coach message variants adhere to copy laws', () {
      final q = makeQuest(
        id: 'q1',
        title: 'Exercise',
        createdAt: DateTime(2026, 8, 1),
        completions: {today.subtractDays(35): 1},
        currentStreak: 6,
        isSatisfiedToday: false,
      );

      final signals = CoachEngine.evaluateAll(
        activeQuests: [q],
        today: today,
        weekStart: weekStart,
        userName: 'Arthur',
        lastActiveDate: today.subtractDays(20),
        lastExportDate: today.subtractDays(60),
        lifetimeCompletions: 70,
        daysLeftInWeek: 1,
        unsatisfiedEssentialThisWeek: 1,
      );

      for (final s in signals) {
        expect(s.message.contains('!'), isFalse, reason: 'Found ! in ${s.message}');
        expect(s.message.toLowerCase().contains('should'), isFalse, reason: 'Found should in ${s.message}');
        for (final act in s.actions) {
          expect(act.label.contains('!'), isFalse, reason: 'Found ! in action ${act.label}');
          expect(act.label.toLowerCase().contains('should'), isFalse, reason: 'Found should in action ${act.label}');
        }
      }
    });
  });

  group('Cooldown & Dismissal Backoff Math', () {
    test('Calculates 30 -> 60 -> 90 day dismissal backoff correctly', () {
      const base = CoachTunables.coachBaseCooldown;
      final backoff0 = base;
      final backoff1 = min(base * (1 << 1), CoachTunables.coachMaxCooldown);
      final backoff2 = min(base * (1 << 2), CoachTunables.coachMaxCooldown);
      final backoff3 = min(base * (1 << 3), CoachTunables.coachMaxCooldown);

      expect(backoff0, equals(30));
      expect(backoff1, equals(60));
      expect(backoff2, equals(90));
      expect(backoff3, equals(90));
    });
  });

  group('UI Integration: Player Name on Profile & Settings', () {
    testWidgets('ProfileScreen displays adventurer name above rank', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      await db.profileDao.getProfile();
      await db.profileDao.updateName('GALAHAD');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            theme: AppTheme.buildTheme(isDark: true, accentTheme: AccentTheme.frost),
            home: const ProfileScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('GALAHAD'), findsOneWidget);
      expect(find.text('RECRUIT'), findsOneWidget);

      await db.close();
    });

    testWidgets('SettingsScreen displays and edits adventurer name', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      await db.profileDao.getProfile();
      await db.profileDao.updateName('LANCELOT');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            theme: AppTheme.buildTheme(isDark: true, accentTheme: AccentTheme.frost),
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('LANCELOT'), findsOneWidget);
      expect(find.text('ADVENTURER IDENTITY'), findsOneWidget);

      // Tap edit button
      await tester.tap(find.text('EDIT'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('ADVENTURER NAME'), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);

      await db.close();
    });

    testWidgets('SettingsScreen toggles and persists Tactile Sound Effects to KV', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      await db.profileDao.getProfile();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            theme: AppTheme.buildTheme(isDark: true, accentTheme: AccentTheme.frost),
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.scrollUntilVisible(
        find.text('Tactile Sound Effects'),
        200,
      );

      expect(find.text('Tactile Sound Effects'), findsOneWidget);

      // Initially false
      final initialVal = await db.ledgerDao.getKv('sound_enabled');
      expect(initialVal, isNull);

      // Tap to toggle sound effects ON
      await tester.tap(find.text('Tactile Sound Effects'));
      await tester.pump(const Duration(milliseconds: 100));

      final onVal = await db.ledgerDao.getKv('sound_enabled');
      expect(onVal, equals('true'));

      // Tap again to toggle sound effects OFF
      await tester.tap(find.text('Tactile Sound Effects'));
      await tester.pump(const Duration(milliseconds: 100));

      final offVal = await db.ledgerDao.getKv('sound_enabled');
      expect(offVal, equals('false'));

      await db.close();
    });

    testWidgets('TodayScreen filters quests by cadence and supports reset', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      await db.profileDao.getProfile();

      await db.questsDao.insertQuest(
        QuestsCompanion.insert(
          id: 'q_daily',
          title: 'Daily Meditation',
          rule: const DailyEveryDayRule(),
          createdAt: DateTime.now(),
        ),
      );

      await db.questsDao.insertQuest(
        QuestsCompanion.insert(
          id: 'q_weekly',
          title: 'Weekly Review',
          rule: const WeeklyTimesRule(times: 3),
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            theme: AppTheme.buildTheme(isDark: true, accentTheme: AccentTheme.frost),
            home: const TodayScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Both quests visible initially under ALL
      expect(find.text('Daily Meditation'), findsOneWidget);
      expect(find.text('Weekly Review'), findsOneWidget);
      expect(find.text('ALL'), findsOneWidget);
      expect(find.text('DAILY'), findsOneWidget);
      expect(find.text('WEEKLY'), findsOneWidget);

      // Tap WEEKLY filter
      await tester.tap(find.text('WEEKLY'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Weekly Review'), findsOneWidget);
      expect(find.text('Daily Meditation'), findsNothing);

      // Tap SINGLE filter (no single quests exist)
      await tester.tap(find.text('SINGLE'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('NO SINGLE QUESTS'), findsOneWidget);
      expect(find.text('SHOW ALL'), findsOneWidget);

      // Tap SHOW ALL
      await tester.tap(find.text('SHOW ALL'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Daily Meditation'), findsOneWidget);
      expect(find.text('Weekly Review'), findsOneWidget);

      await db.close();
    });
  });
}
