import 'package:drift/drift.dart';
import '../db/database.dart';
import '../db/tables.dart';

part 'quests_dao.g.dart';

@DriftAccessor(tables: [Quests])
class QuestsDao extends DatabaseAccessor<AppDatabase> with _$QuestsDaoMixin {
  QuestsDao(super.db);

  Stream<List<QuestData>> watchActiveQuests() {
    return (select(quests)..where((tbl) => tbl.archivedAt.isNull())).watch();
  }

  Stream<List<QuestData>> watchAllQuests() {
    return select(quests).watch();
  }

  Future<List<QuestData>> getActiveQuests() {
    return (select(quests)..where((tbl) => tbl.archivedAt.isNull())).get();
  }

  Future<List<QuestData>> getAllQuests() {
    return select(quests).get();
  }

  Future<QuestData?> getQuestById(String id) {
    return (select(quests)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertQuest(QuestsCompanion entry) {
    return into(quests).insert(entry);
  }

  Future<bool> updateQuest(QuestsCompanion entry) {
    return update(quests).replace(entry);
  }

  Future<int> archiveQuest(String id, DateTime archivedAt) {
    return (update(quests)..where((tbl) => tbl.id.equals(id)))
        .write(QuestsCompanion(archivedAt: Value(archivedAt)));
  }

  Future<int> pauseQuest(String id, String? pausedUntil) {
    return (update(quests)..where((tbl) => tbl.id.equals(id)))
        .write(QuestsCompanion(pausedUntil: Value(pausedUntil)));
  }

  Future<int> updateTargetValue(String id, int targetValue) {
    return (update(quests)..where((tbl) => tbl.id.equals(id)))
        .write(QuestsCompanion(targetValue: Value(targetValue)));
  }

  Future<int> updateDifficulty(String id, int difficulty) {
    return (update(quests)..where((tbl) => tbl.id.equals(id)))
        .write(QuestsCompanion(difficulty: Value(difficulty)));
  }
}
