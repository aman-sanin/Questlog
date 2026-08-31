import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../data/db/database.dart';
import '../../domain/constants/xp_constants.dart';
import '../../domain/model/models.dart';

class GoalActions {
  final AppDatabase db;
  final _uuid = const Uuid();

  GoalActions(this.db);

  /// Create a new goal
  Future<String> createGoal({
    required String title,
    required String emoji,
    String? note,
    required DateTime now,
  }) async {
    final id = _uuid.v4();
    await db.goalsDao.insertGoal(
      GoalsCompanion(
        id: Value(id),
        title: Value(title),
        emoji: Value(emoji),
        note: Value(note),
        createdAt: Value(now),
      ),
    );
    return id;
  }

  /// Update an existing goal
  Future<void> updateGoal({
    required String id,
    required String title,
    required String emoji,
    String? note,
    required DateTime createdAt,
    DateTime? archivedAt,
    DateTime? completedAt,
  }) async {
    await db.goalsDao.updateGoal(
      GoalsCompanion(
        id: Value(id),
        title: Value(title),
        emoji: Value(emoji),
        note: Value(note),
        createdAt: Value(createdAt),
        archivedAt: Value(archivedAt),
        completedAt: Value(completedAt),
      ),
    );
  }

  /// Mark a goal complete and grant +250 XP event
  Future<void> completeGoal({
    required String id,
    required LocalDate today,
    required DateTime now,
  }) async {
    await db.transaction(() async {
      await db.goalsDao.completeGoal(id, now);

      await db.ledgerDao.insertXpEvent(
        XpEventsCompanion(
          id: Value(_uuid.v4()),
          type: Value(XpEventType.goal.index),
          ref: Value(id),
          amount: Value(XpConstants.goalCompletionBonus),
          localDate: Value(today.formatted),
          createdAt: Value(now),
        ),
      );
    });
  }

  /// Archive a goal
  Future<void> archiveGoal(String id, DateTime now) async {
    await db.goalsDao.archiveGoal(id, now);
  }
}
