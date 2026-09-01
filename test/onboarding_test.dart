import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:questlog/app/providers/database_provider.dart';
import 'package:questlog/app/providers/profile_provider.dart';
import 'package:questlog/data/db/database.dart';
import 'package:questlog/domain/model/models.dart';
import 'package:questlog/ui/screens/onboarding_screen.dart';
import 'package:questlog/ui/theme/app_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Onboarding Flow Tests', () {
    testWidgets('OnboardingScreen renders 3-step wizard and saves starter quests', (tester) async {
      final router = GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => const OnboardingScreen(),
          ),
          GoRoute(
            path: '/today',
            builder: (context, state) => const Scaffold(body: Text('TODAY_SCREEN')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            effectiveLocalDateProvider.overrideWithValue(LocalDate(2026, 9, 1)),
            weekStartProvider.overrideWithValue(WeekStart.monday),
          ],
          child: MaterialApp.router(
            theme: AppTheme.buildTheme(isDark: true, accentTheme: AccentTheme.frost),
            routerConfig: router,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Step 0: Welcome
      expect(find.text('QUESTLOG'), findsOneWidget);
      expect(find.text('BEGIN'), findsOneWidget);

      await tester.tap(find.text('BEGIN'));
      await tester.pump(const Duration(milliseconds: 100));

      // Step 1: Name entry
      expect(find.text('How should the ledger address you?'), findsOneWidget);
      expect(find.text('CONTINUE'), findsOneWidget);

      final nameInput = find.byType(TextField);
      expect(nameInput, findsOneWidget);
      await tester.enterText(nameInput, 'Galahad');
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(milliseconds: 100));

      // Step 2: Starter Quests selection
      expect(find.text('Select starter quests'), findsOneWidget);
      expect(find.text('ENTER THE LEDGER'), findsOneWidget);

      // Finish Onboarding
      await tester.tap(find.text('ENTER THE LEDGER'));
      await tester.pump(const Duration(milliseconds: 200));

      // Verify Database state
      final profile = await db.profileDao.getProfile();
      expect(profile.name, equals('Galahad'));

      final quests = await db.questsDao.getAllQuests();
      expect(quests.length, equals(3));

      final seenMoments = await db.ledgerDao.getSeenMoments();
      expect(seenMoments.contains('onboarding'), isTrue);
    });

    test('Fresh install with empty database has onboarding incomplete', () async {
      final seenMoments = await db.ledgerDao.getSeenMoments();
      final quests = await db.questsDao.getAllQuests();

      expect(seenMoments.contains('onboarding'), isFalse);
      expect(quests.isEmpty, isTrue);
    });

    test('After marking onboarding seen, status is complete', () async {
      await db.ledgerDao.markMomentSeen('onboarding', DateTime.now());
      final seenMoments = await db.ledgerDao.getSeenMoments();

      expect(seenMoments.contains('onboarding'), isTrue);
    });
  });
}
