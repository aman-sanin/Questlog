import 'package:drift/drift.dart';
import '../db/database.dart';
import '../db/tables.dart';

part 'ledger_dao.g.dart';

@DriftAccessor(tables: [XpEvents, StreakRepairs, SeenMoments, Kvs])
class LedgerDao extends DatabaseAccessor<AppDatabase> with _$LedgerDaoMixin {
  LedgerDao(super.db);

  Stream<int> watchTotalXp() {
    final amountCol = xpEvents.amount.sum();
    final query = selectOnly(xpEvents)..addColumns([amountCol]);
    return query.map((row) => row.read(amountCol) ?? 0).watchSingleOrNull().map((v) => v ?? 0);
  }

  Future<int> getTotalXp() async {
    final amountCol = xpEvents.amount.sum();
    final query = selectOnly(xpEvents)..addColumns([amountCol]);
    final row = await query.getSingleOrNull();
    return row?.read(amountCol) ?? 0;
  }

  Stream<List<XpEventData>> watchRecentXpEvents([int limit = 50]) {
    return (select(xpEvents)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
          ..limit(limit))
        .watch();
  }

  Future<List<XpEventData>> getAllXpEvents() {
    return select(xpEvents).get();
  }

  Future<int> insertXpEvent(XpEventsCompanion entry) {
    return into(xpEvents).insertOnConflictUpdate(entry);
  }

  Future<int> deleteXpEventsByRef(String ref) {
    return (delete(xpEvents)..where((tbl) => tbl.ref.equals(ref))).go();
  }

  // Streak Repairs
  Stream<List<StreakRepairData>> watchStreakRepairs() {
    return select(streakRepairs).watch();
  }

  Future<List<StreakRepairData>> getStreakRepairs() {
    return select(streakRepairs).get();
  }

  Future<int> insertStreakRepair(StreakRepairsCompanion entry) {
    return into(streakRepairs).insertOnConflictUpdate(entry);
  }

  Future<int> deleteStreakRepair(String questId, String periodKey) {
    return (delete(streakRepairs)
          ..where((tbl) => tbl.questId.equals(questId) & tbl.periodKey.equals(periodKey)))
        .go();
  }

  // Seen Moments
  Stream<Set<String>> watchSeenMoments() {
    return select(seenMoments).watch().map((list) => list.map((m) => m.key).toSet());
  }

  Future<Set<String>> getSeenMoments() async {
    final list = await select(seenMoments).get();
    return list.map((m) => m.key).toSet();
  }

  Future<int> markMomentSeen(String key, DateTime seenAt) {
    return into(seenMoments).insertOnConflictUpdate(
      SeenMomentsCompanion(
        key: Value(key),
        seenAt: Value(seenAt),
      ),
    );
  }

  // KV Store
  Future<String?> getKv(String key) async {
    final row = await (select(kvs)..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watchKv(String key) {
    return (select(kvs)..where((tbl) => tbl.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<Map<String, String>> getAllKvs() async {
    final rows = await select(kvs).get();
    return {for (final r in rows) r.key: r.value};
  }

  Stream<Map<String, String>> watchAllKvs() {
    return select(kvs).watch().map((rows) => {for (final r in rows) r.key: r.value});
  }

  Future<int> setKv(String key, String value) {
    return into(kvs).insertOnConflictUpdate(
      KvsCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }

  Future<int> deleteKv(String key) {
    return (delete(kvs)..where((tbl) => tbl.key.equals(key))).go();
  }
}
