import 'dart:convert';
import 'package:drift/drift.dart';
import '../db/database.dart';

class BackupService {
  final AppDatabase db;

  BackupService(this.db);

  Future<String> exportBackupJson() async {
    final profile = await db.profileDao.getProfile();
    final goals = await (db.select(db.goals)).get();
    final quests = await (db.select(db.quests)).get();
    final completions = await (db.select(db.completions)).get();
    final xpEvents = await db.ledgerDao.getAllXpEvents();
    final streakRepairs = await db.ledgerDao.getStreakRepairs();
    final seenMoments = await (db.select(db.seenMoments)).get();

    final data = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'profile': {
        'name': profile.name,
        'calling': profile.calling,
        'calling_chosen_at': profile.callingChosenAt?.toIso8601String(),
        'reset_minute': profile.resetMinute,
        'week_start': profile.weekStart,
        'theme_mode': profile.themeMode,
        'accent': profile.accent,
        'digest_enabled': profile.digestEnabled,
        'digest_minute': profile.digestMinute,
      },
      'goals': goals
          .map((g) => {
                'id': g.id,
                'title': g.title,
                'emoji': g.emoji,
                'note': g.note,
                'created_at': g.createdAt.toIso8601String(),
                'archived_at': g.archivedAt?.toIso8601String(),
                'completed_at': g.completedAt?.toIso8601String(),
              })
          .toList(),
      'quests': quests
          .map((q) => {
                'id': q.id,
                'title': q.title,
                'note': q.note,
                'rule': q.rule.toJson(),
                'target_type': q.targetType,
                'target_value': q.targetValue,
                'unit': q.unit,
                'difficulty': q.difficulty,
                'essential': q.essential,
                'goal_id': q.goalId,
                'domain': q.domain,
                'reminder_minute': q.reminderMinute,
                'paused_until': q.pausedUntil,
                'created_at': q.createdAt.toIso8601String(),
                'archived_at': q.archivedAt?.toIso8601String(),
              })
          .toList(),
      'completions': completions
          .map((c) => {
                'id': c.id,
                'quest_id': c.questId,
                'local_date': c.localDate,
                'value': c.value,
                'timezone': c.timezone,
                'created_at': c.createdAt.toIso8601String(),
              })
          .toList(),
      'xp_events': xpEvents
          .map((x) => {
                'id': x.id,
                'type': x.type,
                'ref': x.ref,
                'period_ref': x.periodRef,
                'amount': x.amount,
                'local_date': x.localDate,
                'created_at': x.createdAt.toIso8601String(),
              })
          .toList(),
      'streak_repairs': streakRepairs
          .map((s) => {
                'id': s.id,
                'quest_id': s.questId,
                'period_key': s.periodKey,
                'applied_at': s.appliedAt.toIso8601String(),
              })
          .toList(),
      'seen_moments': seenMoments
          .map((m) => {
                'key': m.key,
                'seen_at': m.seenAt.toIso8601String(),
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
