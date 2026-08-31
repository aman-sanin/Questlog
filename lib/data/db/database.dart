import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import 'converters.dart';
import '../../domain/engine/schedule_rule.dart';
import '../dao/quests_dao.dart';
import '../dao/completions_dao.dart';
import '../dao/goals_dao.dart';
import '../dao/ledger_dao.dart';
import '../dao/profile_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Profiles, Goals, Quests, Completions, XpEvents, StreakRepairs, SeenMoments, Kvs],
  daos: [QuestsDao, CompletionsDao, GoalsDao, LedgerDao, ProfileDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await into(profiles).insertOnConflictUpdate(
            const ProfilesCompanion(
              id: Value(1),
              weekStart: Value(1),
              resetMinute: Value(0),
              themeMode: Value(0),
              accent: Value('frost'),
              digestEnabled: Value(true),
              digestMinute: Value(540),
            ),
          );
        },
        beforeOpen: (details) async {
          final profile = await (select(profiles)..where((tbl) => tbl.id.equals(1))).getSingleOrNull();
          if (profile == null) {
            await into(profiles).insertOnConflictUpdate(
              const ProfilesCompanion(
                id: Value(1),
                weekStart: Value(1),
                resetMinute: Value(0),
                themeMode: Value(0),
                accent: Value('frost'),
                digestEnabled: Value(true),
                digestMinute: Value(540),
              ),
            );
          }
        },
      );
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'questlog.db'));
    return NativeDatabase(file);
  });
}
