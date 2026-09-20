import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app/providers/badges_provider.dart';
import 'package:questlog/app/providers/today_provider.dart';
import 'package:questlog/data/db/database.dart';
import 'package:questlog/domain/engine/badges.dart';
import 'package:questlog/domain/engine/quest_state.dart';
import 'package:questlog/domain/engine/schedule_rule.dart';
import 'package:questlog/domain/model/models.dart';
import 'package:questlog/ui/screens/badges_screen.dart';
import 'package:questlog/ui/theme/app_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/badge_tile.dart';

void main() {
  group('P9b: 100-Badge Registry & Evaluation Suite', () {
    test('Registry Integrity: exactly 100 badges with unique keys and valid fields', () {
      expect(BadgeEngine.catalog.length, equals(100));

      final keys = <String>{};
      for (final badge in BadgeEngine.catalog) {
        expect(keys.contains(badge.key), isFalse, reason: 'Duplicate badge key: ${badge.key}');
        keys.add(badge.key);

        expect(badge.title.isNotEmpty, isTrue);
        expect(badge.flavor.isNotEmpty, isTrue);
        expect(badge.requirement.isNotEmpty, isTrue);
      }

      // Check category counts
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.journey).length, equals(11));
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.streaks).length, equals(12));
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.perfection).length, equals(11));
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.goals).length, equals(8));
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.economy).length, equals(8));
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.rarities).length, equals(11));
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.calling).length, equals(17));
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.keeper).length, equals(10));
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.sealed).length, equals(12));
      expect(BadgeEngine.catalog.where((b) => b.sealed).length, equals(12));
    });

    test('Evaluation: Journey counts derive correctly from completions', () {
      final completions = List.generate(
        100,
        (i) => CompletionData(
          id: 'c_$i',
          questId: 'q_1',
          localDate: '2026-08-${(i % 28 + 1).toString().padLeft(2, '0')}',
          value: 1,
          timezone: 'UTC',
          createdAt: DateTime(2026, 8, 1, 10, 0),
        ),
      );

      final dummyProfile = ProfileData(
        id: 1,
        resetMinute: 0,
        weekStart: 1,
        themeMode: 0,
        accent: 'frost',
        digestEnabled: true,
        digestMinute: 540,
      );

      final result = BadgeEngine.evaluate(
        completions: completions,
        quests: [],
        goals: [],
        streakRepairs: [],
        profile: dummyProfile,
        questMaxStreaks: {},
        perfectDays: {},
        seenBadgeKeys: {},
        weekStart: WeekStart.monday,
        today: LocalDate(2026, 8, 31),
      );

      final badgeMap = {for (final b in result) b.definition.key: b};

      expect(badgeMap['first_step']!.isEarned, isTrue);
      expect(badgeMap['tenfold']!.isEarned, isTrue);
      expect(badgeMap['half_century']!.isEarned, isTrue);
      expect(badgeMap['century']!.isEarned, isTrue);
      expect(badgeMap['millennial']!.isEarned, isFalse);
      expect(badgeMap['century']!.currentValue, equals(100));
    });

    test('Evaluation: Calling trial eligibility strictly checks profile calling', () {
      final warriorProfile = ProfileData(
        id: 1,
        calling: CallingDomain.warrior.index,
        resetMinute: 0,
        weekStart: 1,
        themeMode: 0,
        accent: 'frost',
        digestEnabled: true,
        digestMinute: 540,
      );

      final warriorQuest = QuestData(
        id: 'q_warrior',
        title: 'Morning Drill',
        rule: const DailyEveryDayRule(),
        targetType: 0,
        targetValue: 1,
        difficulty: 1,
        essential: true,
        domain: CallingDomain.warrior.index,
        createdAt: DateTime(2026, 1, 1),
      );

      final sageQuest = QuestData(
        id: 'q_sage',
        title: 'Study Runes',
        rule: const DailyEveryDayRule(),
        targetType: 0,
        targetValue: 1,
        difficulty: 1,
        essential: true,
        domain: CallingDomain.sage.index,
        createdAt: DateTime(2026, 1, 1),
      );

      final result = BadgeEngine.evaluate(
        completions: [],
        quests: [warriorQuest, sageQuest],
        goals: [],
        streakRepairs: [],
        profile: warriorProfile,
        questMaxStreaks: {'q_warrior': 35, 'q_sage': 35},
        perfectDays: {},
        seenBadgeKeys: {},
        weekStart: WeekStart.monday,
        today: LocalDate(2026, 8, 31),
      );

      final badgeMap = {for (final b in result) b.definition.key: b};

      // Warrior trial should be earned because streak >= 30 and calling is Warrior
      expect(badgeMap['trial_iron_will']!.isEarned, isTrue);
      expect(badgeMap['trial_iron_will']!.isEligible, isTrue);

      // Sage trial should NOT be earned even though sage quest streak is 35, because user is Warrior
      expect(badgeMap['trial_unbroken_focus']!.isEarned, isFalse);
      expect(badgeMap['trial_unbroken_focus']!.isEligible, isFalse);
    });

    test('Evaluation: Sealed badges (Night Owl, Dawnbreaker, Scribe)', () {
      final completions = [
        CompletionData(
          id: 'c_night',
          questId: 'q_1',
          localDate: '2026-08-15',
          value: 1,
          timezone: 'UTC',
          createdAt: DateTime(2026, 8, 15, 2, 30), // 02:30 AM wall-clock
        ),
        CompletionData(
          id: 'c_dawn',
          questId: 'q_1',
          localDate: '2026-08-16',
          value: 1,
          timezone: 'UTC',
          createdAt: DateTime(2026, 8, 16, 6, 15), // 06:15 AM
        ),
      ];

      final dummyProfile = ProfileData(
        id: 1,
        resetMinute: 0,
        weekStart: 1,
        themeMode: 0,
        accent: 'frost',
        digestEnabled: true,
        digestMinute: 540,
      );

      final result = BadgeEngine.evaluate(
        completions: completions,
        quests: [],
        goals: [],
        streakRepairs: [],
        profile: dummyProfile,
        questMaxStreaks: {},
        perfectDays: {},
        seenBadgeKeys: {},
        weekStart: WeekStart.monday,
        today: LocalDate(2026, 8, 31),
      );

      final badgeMap = {for (final b in result) b.definition.key: b};

      expect(badgeMap['night_owl']!.isEarned, isTrue);
      expect(badgeMap['dawnbreaker']!.isEarned, isTrue);
      expect(badgeMap['scribe']!.isEarned, isFalse);
    });

    test('Evaluation: new journey tiers fill the gaps', () {
      final completions = List.generate(
        250,
        (i) => CompletionData(
          id: 'c_$i',
          questId: 'q_1',
          localDate: '2026-08-${(i % 28 + 1).toString().padLeft(2, '0')}',
          value: 1,
          timezone: 'UTC',
          createdAt: DateTime(2026, 8, 1, 10, 0),
        ),
      );

      final dummyProfile = ProfileData(
        id: 1,
        resetMinute: 0,
        weekStart: 1,
        themeMode: 0,
        accent: 'frost',
        digestEnabled: true,
        digestMinute: 540,
      );

      final result = BadgeEngine.evaluate(
        completions: completions,
        quests: [],
        goals: [],
        streakRepairs: [],
        profile: dummyProfile,
        questMaxStreaks: {},
        perfectDays: {},
        seenBadgeKeys: {},
        weekStart: WeekStart.monday,
        today: LocalDate(2026, 8, 31),
      );

      final badgeMap = {for (final b in result) b.definition.key: b};

      expect(badgeMap['twenty_five']!.isEarned, isTrue);
      expect(badgeMap['twenty_five']!.currentValue, equals(250));
      expect(badgeMap['quarter_thousand']!.isEarned, isTrue);
      expect(badgeMap['half_thousand']!.isEarned, isFalse);
      expect(badgeMap['two_thousand']!.isEarned, isFalse);
      expect(badgeMap['century']!.isEarned, isTrue);
    });

    test('Evaluation: Keeper section — company, watch, stages, levels', () {
      final base = DateTime(2026, 6, 1);
      final completions = List.generate(35, (i) {
        final d = base.add(Duration(days: i));
        final ds =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        return CompletionData(
          id: 'k_$i',
          questId: 'q_1',
          localDate: ds,
          value: 1,
          timezone: 'UTC',
          createdAt: DateTime(d.year, d.month, d.day, 10, 0),
        );
      });
      final perfectDays = {
        for (final c in completions) LocalDate.parse(c.localDate),
      };

      final dummyProfile = ProfileData(
        id: 1,
        resetMinute: 0,
        weekStart: 1,
        themeMode: 0,
        accent: 'frost',
        digestEnabled: true,
        digestMinute: 540,
      );

      final result = BadgeEngine.evaluate(
        completions: completions,
        quests: [],
        goals: [],
        streakRepairs: [],
        profile: dummyProfile,
        questMaxStreaks: {},
        perfectDays: perfectDays,
        seenBadgeKeys: {},
        weekStart: WeekStart.monday,
        today: LocalDate(2026, 8, 31),
      );

      final badgeMap = {for (final b in result) b.definition.key: b};

      expect(badgeMap['keeper_first_day']!.isEarned, isTrue);
      expect(badgeMap['keeper_first_watch']!.isEarned, isTrue);
      expect(badgeMap['keeper_waking']!.isEarned, isTrue);
      expect(badgeMap['keeper_adorned']!.isEarned, isTrue);
      expect(badgeMap['keeper_trimmed']!.isEarned, isFalse);
      expect(badgeMap['keeper_company_week']!.isEarned, isTrue);
      expect(badgeMap['keeper_company_season']!.isEarned, isTrue);
      expect(badgeMap['keeper_company_year']!.isEarned, isFalse);
      expect(badgeMap['keeper_level_ten']!.isEarned, isFalse);
      expect(badgeMap['keeper_legend']!.isEarned, isFalse);

      final leveled = BadgeEngine.evaluate(
        completions: completions,
        quests: [],
        goals: [],
        streakRepairs: [],
        profile: dummyProfile,
        questMaxStreaks: {},
        perfectDays: perfectDays,
        seenBadgeKeys: {},
        weekStart: WeekStart.monday,
        today: LocalDate(2026, 8, 31),
        playerLevel: 30,
      );
      final leveledMap = {for (final b in leveled) b.definition.key: b};
      expect(leveledMap['keeper_level_ten']!.isEarned, isTrue);
      expect(leveledMap['keeper_level_ten']!.currentValue, equals(30));
      expect(leveledMap['keeper_legend']!.isEarned, isTrue);
    });

    test('Evaluation: pledged calling tiers + full circle', () {
      final warriorProfile = ProfileData(
        id: 1,
        calling: CallingDomain.warrior.index,
        resetMinute: 0,
        weekStart: 1,
        themeMode: 0,
        accent: 'frost',
        digestEnabled: true,
        digestMinute: 540,
      );

      final quests = [
        for (final d in CallingDomain.values)
          QuestData(
            id: 'q_${d.name}',
            title: '${d.name} quest',
            rule: const DailyEveryDayRule(),
            targetType: 0,
            targetValue: 1,
            difficulty: 1,
            essential: true,
            domain: d.index,
            createdAt: DateTime(2026, 1, 1),
          ),
      ];

      final completions = [
        for (var i = 0; i < 30; i++)
          CompletionData(
            id: 'cw_$i',
            questId: 'q_warrior',
            localDate: '2026-08-${(i % 28 + 1).toString().padLeft(2, '0')}',
            value: 1,
            timezone: 'UTC',
            createdAt: DateTime(2026, 8, 1, 10, 0),
          ),
        for (final d in CallingDomain.values)
          if (d != CallingDomain.warrior)
            CompletionData(
              id: 'c_${d.name}',
              questId: 'q_${d.name}',
              localDate: '2026-08-01',
              value: 1,
              timezone: 'UTC',
              createdAt: DateTime(2026, 8, 1, 10, 0),
            ),
      ];

      final result = BadgeEngine.evaluate(
        completions: completions,
        quests: quests,
        goals: [],
        streakRepairs: [],
        profile: warriorProfile,
        questMaxStreaks: {'q_warrior': 65},
        perfectDays: {},
        seenBadgeKeys: {},
        weekStart: WeekStart.monday,
        today: LocalDate(2026, 8, 31),
      );

      final badgeMap = {for (final b in result) b.definition.key: b};

      expect(badgeMap['first_tribute']!.isEarned, isTrue);
      expect(badgeMap['first_tribute']!.isEligible, isTrue);
      expect(badgeMap['oathkeeper']!.isEarned, isTrue);
      expect(badgeMap['paragon']!.isEarned, isFalse);
      expect(badgeMap['unbending']!.isEarned, isTrue);
      expect(badgeMap['full_circle']!.isEarned, isTrue);
      expect(badgeMap['full_circle']!.currentValue, equals(6));
      // Pledge gating still holds for the per-domain trials.
      expect(badgeMap['trial_iron_will']!.isEarned, isTrue);
      expect(badgeMap['trial_hundred_battles']!.isEarned, isFalse);
    });

    test('Evaluation: nightcap, high noon, equinox dates', () {
      CompletionData at(String id, String date, int hour, int minute) =>
          CompletionData(
            id: id,
            questId: 'q_1',
            localDate: date,
            value: 1,
            timezone: 'UTC',
            createdAt: DateTime.parse('${date}T${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00'),
          );

      final completions = [
        at('c_nightcap', '2026-08-15', 22, 30),
        at('c_noon', '2026-08-16', 12, 15),
        at('c_spring', '2026-03-20', 10, 0),
        at('c_hallows', '2026-10-31', 10, 0),
      ];

      final dummyProfile = ProfileData(
        id: 1,
        resetMinute: 0,
        weekStart: 1,
        themeMode: 0,
        accent: 'frost',
        digestEnabled: true,
        digestMinute: 540,
      );

      final result = BadgeEngine.evaluate(
        completions: completions,
        quests: [],
        goals: [],
        streakRepairs: [],
        profile: dummyProfile,
        questMaxStreaks: {},
        perfectDays: {},
        seenBadgeKeys: {},
        weekStart: WeekStart.monday,
        today: LocalDate(2026, 8, 31),
      );

      final badgeMap = {for (final b in result) b.definition.key: b};

      expect(badgeMap['nightcap']!.isEarned, isTrue);
      expect(badgeMap['high_noon']!.isEarned, isTrue);
      expect(badgeMap['spring_equinox']!.isEarned, isTrue);
      expect(badgeMap['hallows']!.isEarned, isTrue);
      expect(badgeMap['yule']!.isEarned, isFalse);
      // Late-night but not owl-hours; midday is not dawn.
      expect(badgeMap['night_owl']!.isEarned, isFalse);
      expect(badgeMap['dawnbreaker']!.isEarned, isFalse);
    });

    test('Evaluation: goal chapter tiers', () {
      GoalData goal(String id, bool done) => GoalData(
            id: id,
            title: 'Goal $id',
            emoji: '🏁',
            createdAt: DateTime(2026, 1, 1),
            completedAt: done ? DateTime(2026, 8, 1) : null,
          );

      final goals = [
        for (var i = 0; i < 7; i++) goal('g_$i', true),
        goal('g_open', false),
      ];

      final dummyProfile = ProfileData(
        id: 1,
        resetMinute: 0,
        weekStart: 1,
        themeMode: 0,
        accent: 'frost',
        digestEnabled: true,
        digestMinute: 540,
      );

      final result = BadgeEngine.evaluate(
        completions: [],
        quests: [],
        goals: goals,
        streakRepairs: [],
        profile: dummyProfile,
        questMaxStreaks: {},
        perfectDays: {},
        seenBadgeKeys: {},
        weekStart: WeekStart.monday,
        today: LocalDate(2026, 8, 31),
      );

      final badgeMap = {for (final b in result) b.definition.key: b};

      expect(badgeMap['goal_getter']!.isEarned, isTrue);
      expect(badgeMap['second_chapter']!.isEarned, isTrue);
      expect(badgeMap['trilogy']!.isEarned, isTrue);
      expect(badgeMap['lucky_seven_goals']!.isEarned, isTrue);
      expect(badgeMap['fifteen_halls']!.isEarned, isFalse);
      expect(badgeMap['polymath']!.isEarned, isTrue);
      expect(badgeMap['decathlon']!.isEarned, isFalse);
    });

    test('Evaluation: economy derives from the log (perfect week = 2)', () {
      final quest = QuestData(
        id: 'q_daily',
        title: 'Daily',
        rule: const DailyEveryDayRule(),
        targetType: 0,
        targetValue: 1,
        difficulty: 1,
        essential: true,
        createdAt: DateTime(2026, 5, 1),
      );
      // Perfect week Mon Jun 1 - Sun Jun 7, evaluated Jun 8 (week closed).
      final completions = [
        for (var d = 1; d <= 7; d++)
          CompletionData(
            id: 'c_$d',
            questId: 'q_daily',
            localDate: '2026-06-${d.toString().padLeft(2, '0')}',
            value: 1,
            timezone: 'UTC',
            createdAt: DateTime(2026, 6, d, 10, 0),
          ),
      ];

      final dummyProfile = ProfileData(
        id: 1,
        resetMinute: 0,
        weekStart: 1,
        themeMode: 0,
        accent: 'frost',
        digestEnabled: true,
        digestMinute: 540,
      );

      final result = BadgeEngine.evaluate(
        completions: completions,
        quests: [quest],
        goals: [],
        streakRepairs: [],
        profile: dummyProfile,
        questMaxStreaks: {},
        perfectDays: {},
        seenBadgeKeys: {},
        weekStart: WeekStart.monday,
        today: LocalDate(2026, 6, 8),
      );

      final badgeMap = {for (final b in result) b.definition.key: b};

      expect(badgeMap['first_freeze']!.isEarned, isTrue);
      expect(badgeMap['first_freeze']!.currentValue, equals(2));
      expect(badgeMap['full_pantry']!.isEarned, isTrue);
      expect(badgeMap['mercy_five']!.isEarned, isFalse);
      expect(badgeMap['first_perfect_week']!.isEarned, isTrue);
      expect(badgeMap['first_grace']!.isEarned, isFalse);
    });
  });

  group('Display ordering', () {
    test('orderBadgesForDisplay: unearned first, catalog order kept', () {
      final defs = BadgeEngine.catalog.take(4).toList();
      BadgeStatus status(int i, bool earned) =>
          BadgeStatus(definition: defs[i], isEarned: earned);

      final mixed = [status(0, true), status(1, false), status(2, true), status(3, false)];
      final ordered = orderBadgesForDisplay(mixed);

      expect(
        ordered.map((b) => b.definition.key).toList(),
        [defs[1].key, defs[3].key, defs[0].key, defs[2].key],
      );
    });

    test('sortQuestsForToday: completed sink, essentials first', () {
      QuestEvaluation make(String title, bool essential, bool done) =>
          QuestEvaluation(
            questId: 'q_$title',
            title: title,
            rule: const DailyEveryDayRule(),
            targetType: TargetType.checkbox,
            targetValue: 1,
            difficulty: Difficulty.easy,
            essential: essential,
            isDueToday: true,
            completedValue: done ? 1 : 0,
            target: 1,
            progress: done ? 1.0 : 0.0,
            isCompleted: done,
            streak: 0,
            visualState: done ? QuestVisual.completed : QuestVisual.pending,
            metaDescription: '',
          );

      final list = [
        make('Zeta', true, true),
        make('Alpha', false, false),
        make('Beta', true, false),
      ]..sort(sortQuestsForToday);

      expect(list.map((q) => q.title).toList(), ['Beta', 'Alpha', 'Zeta']);
    });
  });

  group('Badges UI Widget Tests', () {
    testWidgets('BadgeTile renders locked and earned states', (tester) async {
      final badgeDef = BadgeEngine.catalog.first;

      // Locked tile
      final lockedBadge = BadgeStatus(definition: badgeDef, isEarned: false);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildTheme(isDark: true, accentTheme: AccentTheme.frost),
          home: Scaffold(
            body: BadgeTile(badge: lockedBadge),
          ),
        ),
      );
      expect(find.byType(BadgeTile), findsOneWidget);

      // Earned tile
      final earnedBadge = BadgeStatus(definition: badgeDef, isEarned: true);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildTheme(isDark: true, accentTheme: AccentTheme.frost),
          home: Scaffold(
            body: BadgeTile(badge: earnedBadge),
          ),
        ),
      );
      expect(find.byType(BadgeTile), findsOneWidget);
    });

    testWidgets('BadgesScreen renders categories and tiles', (tester) async {
      // Tall viewport so every lazy section (incl. KEEPER) builds.
      tester.view.physicalSize = const Size(800, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            badgesStateProvider.overrideWithValue(
              AsyncData(
                BadgesScreenState(
                  allBadges: BadgeEngine.catalog.map((b) => BadgeStatus(definition: b, isEarned: false)).toList(),
                  earnedCount: 5,
                  totalCount: 100,
                  groupedByCategory: {
                    for (final cat in BadgeCategory.values)
                      cat: BadgeEngine.catalog
                          .where((b) => b.category == cat)
                          .map((b) => BadgeStatus(definition: b, isEarned: false))
                          .toList(),
                  },
                  sealedCount: 12,
                  revealedSealedCount: 0,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.buildTheme(isDark: true, accentTheme: AccentTheme.frost),
            home: const BadgesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('BADGES'), findsOneWidget);
      expect(find.text('5/100'), findsOneWidget);
      expect(find.text('JOURNEY'), findsOneWidget);
      expect(find.text('STREAKS'), findsOneWidget);
      expect(find.text('KEEPER'), findsOneWidget);
    });
  });
}

