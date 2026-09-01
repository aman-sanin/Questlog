import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app/providers/badges_provider.dart';
import 'package:questlog/data/db/database.dart';
import 'package:questlog/domain/engine/badges.dart';
import 'package:questlog/domain/engine/schedule_rule.dart';
import 'package:questlog/domain/model/models.dart';
import 'package:questlog/ui/screens/badges_screen.dart';
import 'package:questlog/ui/theme/app_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/badge_tile.dart';

void main() {
  group('P9b: 50-Badge Registry & Evaluation Suite', () {
    test('Registry Integrity: exactly 50 badges with unique keys and valid fields', () {
      expect(BadgeEngine.catalog.length, equals(50));

      final keys = <String>{};
      for (final badge in BadgeEngine.catalog) {
        expect(keys.contains(badge.key), isFalse, reason: 'Duplicate badge key: ${badge.key}');
        keys.add(badge.key);

        expect(badge.title.isNotEmpty, isTrue);
        expect(badge.flavor.isNotEmpty, isTrue);
        expect(badge.requirement.isNotEmpty, isTrue);
      }

      // Check category counts
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.journey).length, equals(6));
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.streaks).length, equals(7));
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.perfection).length, equals(6));
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.goals).length, equals(3));
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.economy).length, equals(3));
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.rarities).length, equals(6));
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.calling).length, equals(12));
      expect(BadgeEngine.catalog.where((b) => b.category == BadgeCategory.sealed).length, equals(7));
      expect(BadgeEngine.catalog.where((b) => b.sealed).length, equals(7));
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
        xpEvents: [],
        streakRepairs: [],
        profile: dummyProfile,
        questMaxStreaks: {},
        perfectDays: {},
        seenBadgeKeys: {},
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
        xpEvents: [],
        streakRepairs: [],
        profile: warriorProfile,
        questMaxStreaks: {'q_warrior': 35, 'q_sage': 35},
        perfectDays: {},
        seenBadgeKeys: {},
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
        xpEvents: [],
        streakRepairs: [],
        profile: dummyProfile,
        questMaxStreaks: {},
        perfectDays: {},
        seenBadgeKeys: {},
      );

      final badgeMap = {for (final b in result) b.definition.key: b};

      expect(badgeMap['night_owl']!.isEarned, isTrue);
      expect(badgeMap['dawnbreaker']!.isEarned, isTrue);
      expect(badgeMap['scribe']!.isEarned, isFalse);
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
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            badgesStateProvider.overrideWithValue(
              AsyncData(
                BadgesScreenState(
                  allBadges: BadgeEngine.catalog.map((b) => BadgeStatus(definition: b, isEarned: false)).toList(),
                  earnedCount: 5,
                  totalCount: 50,
                  groupedByCategory: {
                    for (final cat in BadgeCategory.values)
                      cat: BadgeEngine.catalog
                          .where((b) => b.category == cat)
                          .map((b) => BadgeStatus(definition: b, isEarned: false))
                          .toList(),
                  },
                  sealedCount: 7,
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
      expect(find.text('5/50'), findsOneWidget);
      expect(find.text('JOURNEY'), findsOneWidget);
      expect(find.text('STREAKS'), findsOneWidget);
    });
  });
}

