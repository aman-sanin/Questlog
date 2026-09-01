import 'package:drift/drift.dart';
import '../db/database.dart';
import '../db/tables.dart';

part 'completions_dao.g.dart';

@DriftAccessor(tables: [Completions])
class CompletionsDao extends DatabaseAccessor<AppDatabase> with _$CompletionsDaoMixin {
  CompletionsDao(super.db);

  Stream<List<CompletionData>> watchAllCompletions() {
    return select(completions).watch();
  }

  Future<List<CompletionData>> getAllCompletions() {
    return select(completions).get();
  }

  Stream<List<CompletionData>> watchCompletionsForDate(String date) {
    return (select(completions)..where((tbl) => tbl.localDate.equals(date))).watch();
  }

  Stream<List<CompletionData>> watchCompletionsInDateRange(String start, String end) {
    return (select(completions)
          ..where((tbl) => tbl.localDate.isBiggerOrEqualValue(start) & tbl.localDate.isSmallerOrEqualValue(end)))
        .watch();
  }

  Future<List<CompletionData>> getCompletionsInDateRange(String start, String end) {
    return (select(completions)
          ..where((tbl) => tbl.localDate.isBiggerOrEqualValue(start) & tbl.localDate.isSmallerOrEqualValue(end)))
        .get();
  }

  Future<List<CompletionData>> getCompletionsForQuest(String questId) {
    return (select(completions)..where((tbl) => tbl.questId.equals(questId))).get();
  }

  Future<CompletionData?> getLatestCompletionForQuest(String questId) {
    return (select(completions)
          ..where((tbl) => tbl.questId.equals(questId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> insertCompletion(CompletionsCompanion entry) {
    return into(completions).insert(entry);
  }

  Future<int> deleteCompletion(String id) {
    return (delete(completions)..where((tbl) => tbl.id.equals(id))).go();
  }
}
