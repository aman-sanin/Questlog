import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';
import '../../data/backup/backup_service.dart';
import '../../data/dao/completions_dao.dart';
import '../../data/dao/goals_dao.dart';
import '../../data/dao/ledger_dao.dart';
import '../../data/dao/profile_dao.dart';
import '../../data/dao/quests_dao.dart';
import '../../data/db/database.dart';
import '../write/goal_actions.dart';
import '../write/profile_actions.dart';
import '../write/quest_actions.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final questsDaoProvider = Provider<QuestsDao>((ref) {
  return ref.watch(databaseProvider).questsDao;
});

final completionsDaoProvider = Provider<CompletionsDao>((ref) {
  return ref.watch(databaseProvider).completionsDao;
});

final goalsDaoProvider = Provider<GoalsDao>((ref) {
  return ref.watch(databaseProvider).goalsDao;
});

final ledgerDaoProvider = Provider<LedgerDao>((ref) {
  return ref.watch(databaseProvider).ledgerDao;
});

final profileDaoProvider = Provider<ProfileDao>((ref) {
  return ref.watch(databaseProvider).profileDao;
});

final questActionsProvider = Provider<QuestActions>((ref) {
  return QuestActions(ref.watch(databaseProvider));
});

final goalActionsProvider = Provider<GoalActions>((ref) {
  return GoalActions(ref.watch(databaseProvider));
});

final profileActionsProvider = Provider<ProfileActions>((ref) {
  return ProfileActions(ref.watch(databaseProvider));
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(databaseProvider));
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final widgetServiceProvider = Provider<WidgetService>((ref) {
  return WidgetService();
});

final seenMomentsStreamProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(ledgerDaoProvider).watchSeenMoments();
});

