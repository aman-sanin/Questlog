import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/data/db/database.dart';
import 'package:questlog/data/packs/quest_pack_service.dart';
import 'package:questlog/domain/engine/schedule_rule.dart';
import 'package:questlog/domain/model/models.dart';

void main() {
  group('P11: Quest Pack Service & Validation Matrix', () {
    test('Title-only minimal quest resolves all default fields properly', () {
      final minimalJson = jsonEncode({
        'format': 'questlog-pack',
        'version': 1,
        'name': 'Minimal Pack',
        'quests': [
          {'title': 'Bare Minimum Quest'},
        ],
      });

      final result = QuestPackService.validatePack(minimalJson);
      expect(result.isValidFormat, isTrue);
      expect(result.validQuests.length, equals(1));
      expect(result.rejectedQuests, isEmpty);

      final q = result.validQuests.first.quest;
      expect(q.title, equals('Bare Minimum Quest'));
      expect(q.cadence, equals(Cadence.daily));
      expect(q.rule, isA<DailyEveryDayRule>());
      expect(q.targetType, equals(TargetType.checkbox));
      expect(q.targetValue, equals(1));
      expect(q.difficulty, equals(Difficulty.medium));
      expect(q.essential, isFalse);
      expect(q.domain, equals(CallingDomain.warrior));
    });

    test('Validation Matrix: row-level rejection for empty title and invalid target', () {
      final mixedJson = jsonEncode({
        'format': 'questlog-pack',
        'version': 1,
        'name': 'Mixed Pack',
        'quests': [
          {'title': 'Valid Quest 1'},
          {'title': '   ', 'cadence': 'daily'}, // Empty title -> Reject
          {'title': 'Valid Quest 2', 'target_value': 0}, // Target < 1 -> Reject
          {'title': 'Valid Quest 3', 'target_value': 5, 'unit': 'reps'},
        ],
      });

      final result = QuestPackService.validatePack(mixedJson);
      expect(result.isValidFormat, isTrue);
      expect(result.validQuests.length, equals(2));
      expect(result.rejectedQuests.length, equals(2));
      expect(result.rejectedQuests.first.reason.contains('mandatory'), isTrue);
      expect(result.rejectedQuests.last.reason.contains('at least 1'), isTrue);
    });

    test('File-level rejection for wrong format or invalid version', () {
      final badFormat = jsonEncode({
        'format': 'unknown-format',
        'version': 1,
        'quests': [],
      });
      final res1 = QuestPackService.validatePack(badFormat);
      expect(res1.isValidFormat, isFalse);
      expect(res1.formatError.contains('Unsupported format'), isTrue);

      final badVersion = jsonEncode({
        'format': 'questlog-pack',
        'version': 99,
        'quests': [],
      });
      final res2 = QuestPackService.validatePack(badVersion);
      expect(res2.isValidFormat, isFalse);
    });

    test('Duplicate titles are flagged and deselected by default', () {
      final packJson = jsonEncode({
        'format': 'questlog-pack',
        'version': 1,
        'name': 'Duplicate Pack',
        'quests': [
          {'title': 'Morning Pushups'},
          {'title': 'Night Reading'},
        ],
      });

      final result = QuestPackService.validatePack(
        packJson,
        existingActiveTitles: {'Morning Pushups'},
      );

      expect(result.validQuests[0].isDuplicate, isTrue);
      expect(result.validQuests[0].isSelectedByDefault, isFalse);

      expect(result.validQuests[1].isDuplicate, isFalse);
      expect(result.validQuests[1].isSelectedByDefault, isTrue);
    });

    test('Caution flag triggers when pack contains >5 essential dailies', () {
      final heavyEssentialsJson = jsonEncode({
        'format': 'questlog-pack',
        'version': 1,
        'name': 'Heavy Pack',
        'quests': List.generate(6, (i) => {
          'title': 'Essential Quest $i',
          'cadence': 'daily',
          'essential': true,
        }),
      });

      final result = QuestPackService.validatePack(heavyEssentialsJson);
      expect(result.essentialDailyCount, equals(6));
      expect(result.hasTooManyEssentials, isTrue);
    });

    test('Database round-trip: import quests + embedded goals -> export -> identical definitions', () async {
      final inMemoryDb = AppDatabase(NativeDatabase.memory());
      final now = DateTime(2025, 1, 1);

      final sampleJson = QuestPackService.sampleTemplate();
      final val = QuestPackService.validatePack(sampleJson);
      expect(val.isValidFormat, isTrue);

      // Import
      final createdIds = await QuestPackService.importPack(
        db: inMemoryDb,
        quests: val.validQuests.map((v) => v.quest).toList(),
        goals: val.goals,
        now: now,
      );

      expect(createdIds.length, equals(3));

      final activeQuests = await inMemoryDb.questsDao.getActiveQuests();
      expect(activeQuests.length, equals(3));

      final activeGoals = await inMemoryDb.goalsDao.getAllGoals();
      expect(activeGoals.length, equals(2));

      // Export
      final exportedJson = QuestPackService.exportPack(
        quests: activeQuests,
        goals: activeGoals,
        packName: 'Exported Pack',
      );

      final revalidated = QuestPackService.validatePack(exportedJson);
      expect(revalidated.isValidFormat, isTrue);
      expect(revalidated.validQuests.length, equals(3));
      expect(revalidated.goals.length, equals(2));

      // Undo Import
      await QuestPackService.undoImport(inMemoryDb, createdIds);
      final remainingQuests = await inMemoryDb.questsDao.getActiveQuests();
      expect(remainingQuests, isEmpty);

      await inMemoryDb.close();
    });
  });
}
