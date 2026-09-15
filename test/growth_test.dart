import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/data/db/database.dart';
import 'package:questlog/domain/engine/schedule_rule.dart';
import 'package:questlog/domain/keeper/growth.dart';
import 'package:questlog/domain/model/models.dart';

void main() {
  group('keeperStageFor — growth thresholds (keeper.md §8)', () {
    test('summoned until 10 perfect days', () {
      expect(keeperStageFor(perfectDays: 0, level: 1), KeeperStage.summoned);
      expect(keeperStageFor(perfectDays: 9, level: 1), KeeperStage.summoned);
      expect(keeperStageFor(perfectDays: 10, level: 1), KeeperStage.waking);
    });

    test('waking until 30; adorned until 100', () {
      expect(keeperStageFor(perfectDays: 29, level: 1), KeeperStage.waking);
      expect(keeperStageFor(perfectDays: 30, level: 1), KeeperStage.adorned);
      expect(keeperStageFor(perfectDays: 99, level: 1), KeeperStage.adorned);
      expect(keeperStageFor(perfectDays: 100, level: 1), KeeperStage.trimmed);
    });

    test('gilded at level 30 — the Legend capstone', () {
      expect(keeperStageFor(perfectDays: 0, level: 30), KeeperStage.gilded);
      expect(keeperStageFor(perfectDays: 100, level: 30), KeeperStage.gilded);
    });

    test('respec preserves growth: the stage has no calling input', () {
      // No calling parameter exists; growth can only come from derived facts.
      // A calling change therefore cannot move the stage (the witness changes
      // robes, never self).
      expect(keeperStageFor(perfectDays: 30, level: 12), KeeperStage.adorned);
      expect(keeperStageFor(perfectDays: 30, level: 12), KeeperStage.adorned);
    });
  });

  group('derivePerfectDays (pure, keeper.md §8)', () {
    QuestData essentialQuest(String id, DateTime created) => QuestData(
      id: id,
      title: id,
      rule: const DailyEveryDayRule(),
      targetType: 0,
      targetValue: 1,
      difficulty: 1,
      essential: true,
      createdAt: created,
    );

    LocalDate d(int day) => LocalDate(2026, 1, day);

    test('perfect only when every scheduled essential met', () {
      final quests = [
        essentialQuest('a', DateTime(2026, 1, 1)),
        essentialQuest('b', DateTime(2026, 1, 1)),
      ];
      final partiallyMet = {
        'a': {d(5): 1},
        'b': {d(5): 0},
      };
      expect(
        derivePerfectDays(
          essentialQuests: quests,
          completionsByQuest: partiallyMet,
          weekStart: WeekStart.monday,
        ),
        isEmpty,
      );

      final fullyMet = {
        'a': {d(5): 1},
        'b': {d(5): 1},
      };
      expect(
        derivePerfectDays(
          essentialQuests: quests,
          completionsByQuest: fullyMet,
          weekStart: WeekStart.monday,
        ),
        contains(d(5)),
      );
    });

    test('quests created after the date never count against it', () {
      final quests = [essentialQuest('late', DateTime(2026, 1, 20))];
      final metEarly = {
        'late': {d(5): 1},
      };
      expect(
        derivePerfectDays(
          essentialQuests: quests,
          completionsByQuest: metEarly,
          weekStart: WeekStart.monday,
        ),
        isEmpty,
      );
    });

    test('no essentials -> no perfect days (no invented praise)', () {
      expect(
        derivePerfectDays(
          essentialQuests: const [],
          completionsByQuest: const {'x': {}},
          weekStart: WeekStart.monday,
        ),
        isEmpty,
      );
    });
  });
}
