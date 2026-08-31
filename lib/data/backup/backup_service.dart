import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/engine/schedule_rule.dart';
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
        'settled_through': profile.settledThrough,
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
                'settled_through': q.settledThrough,
              })
          .toList(),
      'completions': completions
          .map((c) => {
                'id': c.id,
                'quest_id': c.questId,
                'local_date': c.localDate,
                'value': c.value,
                'note': c.note,
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

  /// Parses, validates, and performs a transactional swap of the database from JSON backup
  Future<bool> importBackupJson(String jsonString) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (_) {
      throw const FormatException('Invalid JSON payload');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backup JSON root must be an object');
    }

    final version = decoded['version'] as int? ?? 1;
    if (version > 1) {
      throw FormatException('Unsupported backup version ($version). Please update QuestLog.');
    }

    final profileMap = decoded['profile'] as Map<String, dynamic>?;
    final goalsList = (decoded['goals'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final questsList = (decoded['quests'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final completionsList = (decoded['completions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final xpEventsList = (decoded['xp_events'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final streakRepairsList = (decoded['streak_repairs'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final seenMomentsList = (decoded['seen_moments'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    // Stage all objects in memory first to validate integrity before touching the DB
    final stagedGoals = goalsList.map((g) {
      return GoalsCompanion(
        id: Value(g['id'] as String),
        title: Value(g['title'] as String),
        emoji: Value(g['emoji'] as String? ?? '🎯'),
        note: Value(g['note'] as String?),
        createdAt: Value(DateTime.parse(g['created_at'] as String)),
        archivedAt: Value(g['archived_at'] != null ? DateTime.parse(g['archived_at'] as String) : null),
        completedAt: Value(g['completed_at'] != null ? DateTime.parse(g['completed_at'] as String) : null),
      );
    }).toList();

    final stagedQuests = questsList.map((q) {
      ScheduleRule rule;
      try {
        rule = ScheduleRule.fromJson(q['rule'] as Map<String, dynamic>);
      } catch (_) {
        rule = UnsupportedRule(q['rule'] as Map<String, dynamic>);
      }

      return QuestsCompanion(
        id: Value(q['id'] as String),
        title: Value(q['title'] as String),
        note: Value(q['note'] as String?),
        rule: Value(rule),
        targetType: Value(q['target_type'] as int? ?? 0),
        targetValue: Value(q['target_value'] as int? ?? 1),
        unit: Value(q['unit'] as String?),
        difficulty: Value(q['difficulty'] as int? ?? 1),
        essential: Value(q['essential'] as bool? ?? false),
        goalId: Value(q['goal_id'] as String?),
        domain: Value(q['domain'] as int?),
        reminderMinute: Value(q['reminder_minute'] as int?),
        pausedUntil: Value(q['paused_until'] as String?),
        createdAt: Value(DateTime.parse(q['created_at'] as String)),
        archivedAt: Value(q['archived_at'] != null ? DateTime.parse(q['archived_at'] as String) : null),
        settledThrough: Value(q['settled_through'] as String?),
      );
    }).toList();

    final stagedCompletions = completionsList.map((c) {
      return CompletionsCompanion(
        id: Value(c['id'] as String),
        questId: Value(c['quest_id'] as String),
        localDate: Value(c['local_date'] as String),
        value: Value(c['value'] as int? ?? 1),
        note: Value(c['note'] as String?),
        timezone: Value(c['timezone'] as String? ?? 'UTC'),
        createdAt: Value(DateTime.parse(c['created_at'] as String)),
      );
    }).toList();

    final stagedXpEvents = xpEventsList.map((x) {
      return XpEventsCompanion(
        id: Value(x['id'] as String),
        type: Value(x['type'] as int),
        ref: Value(x['ref'] as String),
        periodRef: Value(x['period_ref'] as String?),
        amount: Value(x['amount'] as int),
        localDate: Value(x['local_date'] as String),
        createdAt: Value(DateTime.parse(x['created_at'] as String)),
      );
    }).toList();

    final stagedStreakRepairs = streakRepairsList.map((s) {
      return StreakRepairsCompanion(
        id: Value(s['id'] as String? ?? s['period_key'] as String),
        questId: Value(s['quest_id'] as String),
        periodKey: Value(s['period_key'] as String),
        appliedAt: Value(DateTime.parse(s['applied_at'] as String)),
      );
    }).toList();

    final stagedSeenMoments = seenMomentsList.map((m) {
      return SeenMomentsCompanion(
        key: Value(m['key'] as String),
        seenAt: Value(DateTime.parse(m['seen_at'] as String)),
      );
    }).toList();

    // Atomic transactional database swap
    await db.transaction(() async {
      // Clear existing records
      await db.delete(db.seenMoments).go();
      await db.delete(db.streakRepairs).go();
      await db.delete(db.xpEvents).go();
      await db.delete(db.completions).go();
      await db.delete(db.quests).go();
      await db.delete(db.goals).go();

      // Insert staged records
      if (profileMap != null) {
        await db.into(db.profiles).insertOnConflictUpdate(
              ProfilesCompanion(
                id: const Value(1),
                name: Value(profileMap['name'] as String? ?? 'Wanderer'),
                calling: Value(profileMap['calling'] as int?),
                callingChosenAt: Value(profileMap['calling_chosen_at'] != null
                    ? DateTime.parse(profileMap['calling_chosen_at'] as String)
                    : null),
                resetMinute: Value(profileMap['reset_minute'] as int? ?? 0),
                weekStart: Value(profileMap['week_start'] as int? ?? 1),
                themeMode: Value(profileMap['theme_mode'] as int? ?? 0),
                accent: Value(profileMap['accent'] as String? ?? 'frost'),
                digestEnabled: Value(profileMap['digest_enabled'] as bool? ?? false),
                digestMinute: Value(profileMap['digest_minute'] as int? ?? 480),
                settledThrough: Value(profileMap['settled_through'] as String?),
              ),
            );
      }

      for (final g in stagedGoals) {
        await db.into(db.goals).insert(g);
      }
      for (final q in stagedQuests) {
        await db.into(db.quests).insert(q);
      }
      for (final c in stagedCompletions) {
        await db.into(db.completions).insert(c);
      }
      for (final x in stagedXpEvents) {
        await db.into(db.xpEvents).insert(x);
      }
      for (final s in stagedStreakRepairs) {
        await db.into(db.streakRepairs).insert(s);
      }
      for (final m in stagedSeenMoments) {
        await db.into(db.seenMoments).insert(m);
      }
    });

    return true;
  }
}
