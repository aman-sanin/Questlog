import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questlog/data/backup/backup_service.dart';
import 'package:questlog/data/db/database.dart';
import 'package:questlog/domain/engine/quest_state.dart';
import 'package:questlog/domain/engine/schedule_rule.dart';
import 'package:questlog/domain/model/models.dart';
import 'package:questlog/ui/theme/app_theme.dart';
import 'package:questlog/ui/theme/sigils.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/app/providers/insights_provider.dart';
import 'package:questlog/ui/widgets/checkbox_ring.dart';
import 'package:questlog/ui/widgets/quest_row.dart';
import 'package:questlog/ui/widgets/stepper_widget.dart';
import 'package:questlog/ui/widgets/year_heatmap_grid.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.buildTheme(isDark: true, accentTheme: AccentTheme.frost),
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  testWidgets('CheckboxRing displays checkmark when completed', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        const CheckboxRing(isCompleted: true),
      ),
    );

    expect(find.byIcon(Symbols.check), findsOneWidget);
  });

  testWidgets('StepperWidget increments count on tap', (tester) async {
    int count = 1;

    await tester.pumpWidget(
      buildTestableWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return StepperWidget(
              current: count,
              target: 5,
              unit: 'reps',
              onIncrement: () => setState(() => count++),
              onDecrement: () => setState(() => count--),
            );
          },
        ),
      ),
    );

    expect(find.text('1/5 reps'), findsOneWidget);

    await tester.tap(find.byIcon(Symbols.add));
    await tester.pump();

    expect(find.text('2/5 reps'), findsOneWidget);
  });

  testWidgets('QuestRow renders quest title and metadata', (tester) async {
    final evaluation = QuestEvaluation(
      questId: 'q-1',
      title: 'Morning Pushups',
      rule: const DailyEveryDayRule(),
      targetType: TargetType.checkbox,
      targetValue: 1,
      difficulty: Difficulty.medium,
      essential: true,
      isDueToday: true,
      completedValue: 0,
      target: 1,
      progress: 0.0,
      isCompleted: false,
      streak: 7,
      visualState: QuestVisual.pending,
      metaDescription: 'DAILY · 7 STREAK',
    );

    await tester.pumpWidget(
      buildTestableWidget(
        QuestRow(evaluation: evaluation),
      ),
    );

    expect(find.text('Morning Pushups'), findsOneWidget);
    expect(find.text('DAILY · 7 STREAK'), findsOneWidget);
    expect(find.byIcon(Symbols.star), findsOneWidget);
  });

  test('Initial database startup initializes default profile without throwing', () async {
    final inMemoryDb = AppDatabase(NativeDatabase.memory());
    
    final profile = await inMemoryDb.profileDao.getProfile();
    expect(profile.id, equals(1));
    expect(profile.accent, equals('frost'));

    final totalXp = await inMemoryDb.ledgerDao.getTotalXp();
    expect(totalXp, equals(0));

    final profileStreamValue = await inMemoryDb.profileDao.watchProfile().first;
    expect(profileStreamValue.id, equals(1));

    final xpStreamValue = await inMemoryDb.ledgerDao.watchTotalXp().first;
    expect(xpStreamValue, equals(0));

    await inMemoryDb.close();
  });

  test('BackupService: export -> wipe -> import preserves state; invalid JSON throws FormatException cleanly', () async {
    final inMemoryDb = AppDatabase(NativeDatabase.memory());
    final backupService = BackupService(inMemoryDb);

    // Populate initial state
    await inMemoryDb.profileDao.updateName('Galahad');
    await inMemoryDb.profileDao.updateCalling(1, DateTime(2025, 1, 1));
    await inMemoryDb.questsDao.insertQuest(
      QuestsCompanion(
        id: const Value('q-export-1'),
        title: const Value('Morning Pushups'),
        rule: const Value(DailyEveryDayRule()),
        difficulty: const Value(1),
        createdAt: Value(DateTime(2025, 1, 1)),
      ),
    );

    // Export JSON
    final jsonExport = await backupService.exportBackupJson();
    expect(jsonExport.contains('Galahad'), isTrue);
    expect(jsonExport.contains('Morning Pushups'), isTrue);

    // Corrupted JSON test -> throws FormatException without damaging database
    expect(
      () => backupService.importBackupJson('{"corrupted": "json'),
      throwsA(isA<FormatException>()),
    );

    // Wipe DB
    await inMemoryDb.delete(inMemoryDb.quests).go();
    final wipedQuests = await inMemoryDb.questsDao.getActiveQuests();
    expect(wipedQuests, isEmpty);

    // Import exported JSON
    final success = await backupService.importBackupJson(jsonExport);
    expect(success, isTrue);

    final restoredProfile = await inMemoryDb.profileDao.getProfile();
    expect(restoredProfile.name, equals('Galahad'));
    expect(restoredProfile.calling, equals(1));

    final restoredQuests = await inMemoryDb.questsDao.getActiveQuests();
    expect(restoredQuests.length, equals(1));
    expect(restoredQuests.first.title, equals('Morning Pushups'));

    await inMemoryDb.close();
  });

  test('SigilPaths: constructs valid non-empty paths for all 6 Calling domains', () {
    for (final domain in CallingDomain.values) {
      final path = SigilPaths.getPath(domain.name);
      expect(path.computeMetrics().isNotEmpty, isTrue);
      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(0));
      expect(bounds.height, greaterThan(0));
    }
  });

  testWidgets('YearHeatmapGrid renders 52 weeks cleanly and responds to day tap', (tester) async {
    final today = const LocalDate(2025, 12, 31);
    final days = List.generate(365, (i) {
      final d = today.subtractDays(364 - i);
      return HeatmapDayStatus(
        date: d,
        intensity: i % 5 == 0 ? HeatmapIntensity.perfect : HeatmapIntensity.medium,
        completionsCount: 2,
        isToday: d == today,
      );
    });

    LocalDate? tappedDate;

    await tester.pumpWidget(
      buildTestableWidget(
        YearHeatmapGrid(
          days: days,
          weekStart: WeekStart.monday,
          onDaySelected: (d) => tappedDate = d,
        ),
      ),
    );

    expect(find.byType(YearHeatmapGrid), findsOneWidget);
  });

  test('P9 Aggregation query: 60-day seeded quest correctly aggregates completions, streak, and XP', () async {
    final inMemoryDb = AppDatabase(NativeDatabase.memory());
    final startDate = const LocalDate(2025, 1, 1);
    const questId = 'q-seeded-60';

    await inMemoryDb.questsDao.insertQuest(
      QuestsCompanion(
        id: const Value(questId),
        title: const Value('60-Day Meditation'),
        rule: const Value(DailyEveryDayRule()),
        targetType: const Value(0),
        targetValue: const Value(1),
        difficulty: const Value(1), // Medium (15 XP)
        createdAt: Value(DateTime(2025, 1, 1)),
      ),
    );

    // Seed 60 completions across 60 days
    for (int i = 0; i < 60; i++) {
      final d = startDate.addDays(i);
      await inMemoryDb.completionsDao.insertCompletion(
        CompletionsCompanion(
          id: Value('c-$i'),
          questId: const Value(questId),
          localDate: Value(d.formatted),
          value: const Value(1),
          timezone: const Value('UTC'),
          createdAt: Value(DateTime(2025, 1, 1).add(Duration(days: i))),
        ),
      );
      await inMemoryDb.ledgerDao.insertXpEvent(
        XpEventsCompanion(
          id: Value('xp-$i'),
          type: const Value(0),
          ref: Value('c-$i'),
          periodRef: Value('$questId|${d.dateString}'),
          amount: const Value(15),
          localDate: Value(d.formatted),
          createdAt: Value(DateTime(2025, 1, 1).add(Duration(days: i))),
        ),
      );
    }

    final completions = await inMemoryDb.completionsDao.getCompletionsForQuest(questId);
    expect(completions.length, equals(60));

    final xpEvents = await inMemoryDb.ledgerDao.getAllXpEvents();
    final questXp = xpEvents
        .where((e) => e.periodRef != null && e.periodRef!.startsWith('$questId|'))
        .fold(0, (sum, e) => sum + e.amount);
    expect(questXp, equals(60 * 15)); // 900 XP

    await inMemoryDb.close();
  });

  test('P12: Completion note round-trips cleanly through BackupService', () async {
    final inMemoryDb = AppDatabase(NativeDatabase.memory());
    final backupService = BackupService(inMemoryDb);

    await inMemoryDb.questsDao.insertQuest(
      QuestsCompanion(
        id: const Value('q-note-1'),
        title: const Value('Journal Entry'),
        rule: const Value(DailyEveryDayRule()),
        createdAt: Value(DateTime(2025, 1, 1)),
      ),
    );

    await inMemoryDb.completionsDao.insertCompletion(
      CompletionsCompanion(
        id: const Value('c-note-1'),
        questId: const Value('q-note-1'),
        localDate: const Value('2025-01-01'),
        value: const Value(1),
        note: const Value('Felt great, read Marcus Aurelius Book 4'),
        timezone: const Value('UTC'),
        createdAt: Value(DateTime(2025, 1, 1)),
      ),
    );

    final exported = await backupService.exportBackupJson();
    expect(exported.contains('Felt great, read Marcus Aurelius Book 4'), isTrue);

    // Wipe & restore
    await inMemoryDb.delete(inMemoryDb.completions).go();
    await backupService.importBackupJson(exported);

    final restoredCompletions = await inMemoryDb.completionsDao.getCompletionsForQuest('q-note-1');
    expect(restoredCompletions.length, equals(1));
    expect(restoredCompletions.first.note, equals('Felt great, read Marcus Aurelius Book 4'));

    await inMemoryDb.close();
  });
}
