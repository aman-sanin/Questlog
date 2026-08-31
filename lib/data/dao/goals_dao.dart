import 'package:drift/drift.dart';
import '../db/database.dart';
import '../db/tables.dart';

part 'goals_dao.g.dart';

@DriftAccessor(tables: [Goals])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  Stream<List<GoalData>> watchActiveGoals() {
    return (select(goals)..where((tbl) => tbl.archivedAt.isNull())).watch();
  }

  Future<List<GoalData>> getActiveGoals() {
    return (select(goals)..where((tbl) => tbl.archivedAt.isNull())).get();
  }

  Future<List<GoalData>> getAllGoals() {
    return select(goals).get();
  }

  Future<GoalData?> getGoalById(String id) {
    return (select(goals)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertGoal(GoalsCompanion entry) {
    return into(goals).insert(entry);
  }

  Future<bool> updateGoal(GoalsCompanion entry) {
    return update(goals).replace(entry);
  }

  Future<int> archiveGoal(String id, DateTime archivedAt) {
    return (update(goals)..where((tbl) => tbl.id.equals(id)))
        .write(GoalsCompanion(archivedAt: Value(archivedAt)));
  }

  Future<int> completeGoal(String id, DateTime completedAt) {
    return (update(goals)..where((tbl) => tbl.id.equals(id)))
        .write(GoalsCompanion(completedAt: Value(completedAt)));
  }
}
