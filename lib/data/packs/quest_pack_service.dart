import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/engine/schedule_rule.dart';
import '../../domain/model/models.dart';
import '../db/database.dart';

class QuestPackGoal {
  final String title;
  final String emoji;

  const QuestPackGoal({required this.title, this.emoji = '🎯'});

  Map<String, dynamic> toJson() => {
        'title': title,
        'emoji': emoji,
      };

  factory QuestPackGoal.fromJson(Map<String, dynamic> json) {
    return QuestPackGoal(
      title: json['title'] as String? ?? 'Untitled Goal',
      emoji: json['emoji'] as String? ?? '🎯',
    );
  }
}

class QuestPackQuest {
  final String title;
  final String? note;
  final String? goal; // Title of the referenced goal
  final Cadence cadence;
  final ScheduleRule rule;
  final TargetType targetType;
  final int targetValue;
  final String? unit;
  final Difficulty difficulty;
  final bool essential;
  final CallingDomain domain;

  const QuestPackQuest({
    required this.title,
    this.note,
    this.goal,
    this.cadence = Cadence.daily,
    this.rule = const DailyEveryDayRule(),
    this.targetType = TargetType.checkbox,
    this.targetValue = 1,
    this.unit,
    this.difficulty = Difficulty.medium,
    this.essential = false,
    this.domain = CallingDomain.warrior,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        if (note != null) 'note': note,
        if (goal != null) 'goal': goal,
        'cadence': cadence.name,
        'rule': rule.toJson(),
        'target_type': targetType.name,
        'target_value': targetValue,
        if (unit != null) 'unit': unit,
        'difficulty': difficulty.name,
        'essential': essential,
        'domain': domain.name,
      };
}

class ValidPackQuest {
  final QuestPackQuest quest;
  final bool isDuplicate;
  final bool isSelectedByDefault;

  ValidPackQuest({
    required this.quest,
    required this.isDuplicate,
    required this.isSelectedByDefault,
  });
}

class RejectedPackQuest {
  final Map<String, dynamic> rawJson;
  final String reason;

  const RejectedPackQuest({required this.rawJson, required this.reason});
}

class QuestPackValidationResult {
  final bool isValidFormat;
  final String formatError;
  final String packName;
  final String? packDescription;
  final List<QuestPackGoal> goals;
  final List<ValidPackQuest> validQuests;
  final List<RejectedPackQuest> rejectedQuests;
  final int essentialDailyCount;
  final bool hasTooManyEssentials;

  const QuestPackValidationResult({
    required this.isValidFormat,
    this.formatError = '',
    this.packName = '',
    this.packDescription,
    this.goals = const [],
    this.validQuests = const [],
    this.rejectedQuests = const [],
    this.essentialDailyCount = 0,
    this.hasTooManyEssentials = false,
  });
}

class QuestPackService {
  static const String formatIdentifier = 'questlog-pack';
  static const int currentVersion = 1;
  static const int maxQuestsLimit = 200;
  static const int maxSizeBytes = 500 * 1024; // 500 KB
  static const _uuid = Uuid();

  /// Parse and validate quest pack JSON string against constraints
  static QuestPackValidationResult validatePack(
    String jsonString, {
    Set<String> existingActiveTitles = const {},
  }) {
    if (jsonString.length > maxSizeBytes) {
      return const QuestPackValidationResult(
        isValidFormat: false,
        formatError: 'File exceeds maximum size limit of 500 KB',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (e) {
      return QuestPackValidationResult(
        isValidFormat: false,
        formatError: 'Invalid JSON format: $e',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      return const QuestPackValidationResult(
        isValidFormat: false,
        formatError: 'Pack must be a valid JSON object',
      );
    }

    final format = decoded['format'] as String?;
    final version = decoded['version'] as int?;

    if (format != formatIdentifier || version != currentVersion) {
      return QuestPackValidationResult(
        isValidFormat: false,
        formatError: 'Unsupported format "$format" (version: $version). Expected "$formatIdentifier" v$currentVersion',
      );
    }

    final packName = decoded['name'] as String? ?? 'Imported Pack';
    final packDescription = decoded['description'] as String?;

    // Parse Goals
    final List<QuestPackGoal> goals = [];
    if (decoded['goals'] is List) {
      for (final g in decoded['goals']) {
        if (g is Map<String, dynamic> && (g['title'] as String?)?.isNotEmpty == true) {
          goals.add(QuestPackGoal.fromJson(g));
        }
      }
    }

    final List<ValidPackQuest> validQuests = [];
    final List<RejectedPackQuest> rejectedQuests = [];

    if (decoded['quests'] is! List) {
      return QuestPackValidationResult(
        isValidFormat: true,
        packName: packName,
        packDescription: packDescription,
        goals: goals,
        validQuests: [],
        rejectedQuests: [],
      );
    }

    final questList = decoded['quests'] as List;
    if (questList.length > maxQuestsLimit) {
      return QuestPackValidationResult(
        isValidFormat: false,
        formatError: 'Pack contains ${questList.length} quests (maximum allowed is $maxQuestsLimit)',
      );
    }

    int essentialDailyCount = 0;

    for (final raw in questList) {
      if (raw is! Map<String, dynamic>) {
        rejectedQuests.add(RejectedPackQuest(
          rawJson: {'raw': raw.toString()},
          reason: 'Row is not a valid JSON object',
        ));
        continue;
      }

      final title = raw['title'] as String?;
      if (title == null || title.trim().isEmpty) {
        rejectedQuests.add(RejectedPackQuest(
          rawJson: raw,
          reason: 'Quest title is missing or empty (mandatory field)',
        ));
        continue;
      }

      // Parse Cadence (default daily)
      final cadenceStr = (raw['cadence'] as String?)?.toLowerCase();
      final cadence = Cadence.values.firstWhere(
        (c) => c.name == cadenceStr,
        orElse: () => Cadence.daily,
      );

      // Parse Schedule Rule (default every_day)
      ScheduleRule rule;
      try {
        if (raw['rule'] is Map<String, dynamic>) {
          rule = ScheduleRule.fromJson(raw['rule'] as Map<String, dynamic>);
        } else {
          rule = const DailyEveryDayRule();
        }
      } catch (e) {
        rule = UnsupportedRule(raw['rule'] is Map<String, dynamic> ? raw['rule'] as Map<String, dynamic> : {'raw': raw['rule']});
      }

      // Parse Target Type (default checkbox)
      final targetTypeStr = (raw['target_type'] as String?)?.toLowerCase();
      final targetType = TargetType.values.firstWhere(
        (t) => t.name == targetTypeStr,
        orElse: () => TargetType.checkbox,
      );

      final targetValue = raw['target_value'] as int? ?? 1;
      if (targetValue < 1) {
        rejectedQuests.add(RejectedPackQuest(
          rawJson: raw,
          reason: 'Target value must be at least 1 (got $targetValue)',
        ));
        continue;
      }

      // Parse Difficulty (default medium)
      final diffStr = (raw['difficulty'] as String?)?.toLowerCase();
      final diff = Difficulty.values.firstWhere(
        (d) => d.name == diffStr,
        orElse: () => Difficulty.medium,
      );

      // Parse Domain (default warrior)
      final domainStr = (raw['domain'] as String?)?.toLowerCase();
      final domain = CallingDomain.values.firstWhere(
        (d) => d.name == domainStr,
        orElse: () => CallingDomain.warrior,
      );

      final essential = raw['essential'] as bool? ?? false;
      final note = raw['note'] as String?;
      final goalRef = raw['goal'] as String?;
      final unit = raw['unit'] as String?;

      if (cadence == Cadence.daily && essential) {
        essentialDailyCount++;
      }

      final isDuplicate = existingActiveTitles.contains(title.trim());

      final quest = QuestPackQuest(
        title: title.trim(),
        note: note,
        goal: goalRef,
        cadence: cadence,
        rule: rule,
        targetType: targetType,
        targetValue: targetValue,
        unit: unit,
        difficulty: diff,
        essential: essential,
        domain: domain,
      );

      validQuests.add(ValidPackQuest(
        quest: quest,
        isDuplicate: isDuplicate,
        isSelectedByDefault: !isDuplicate,
      ));
    }

    return QuestPackValidationResult(
      isValidFormat: true,
      packName: packName,
      packDescription: packDescription,
      goals: goals,
      validQuests: validQuests,
      rejectedQuests: rejectedQuests,
      essentialDailyCount: essentialDailyCount,
      hasTooManyEssentials: essentialDailyCount > 5,
    );
  }

  /// Import validated pack quests and embedded goals atomically into the database
  static Future<List<String>> importPack({
    required AppDatabase db,
    required List<QuestPackQuest> quests,
    required List<QuestPackGoal> goals,
    required DateTime now,
  }) async {
    final createdQuestIds = <String>[];

    await db.transaction(() async {
      // 1. Insert Goals and map titles to created Goal IDs
      final Map<String, String> goalIdMap = {};
      final existingGoals = await db.goalsDao.getAllGoals();
      for (final eg in existingGoals) {
        goalIdMap[eg.title.toLowerCase()] = eg.id;
      }

      for (final g in goals) {
        if (!goalIdMap.containsKey(g.title.toLowerCase())) {
          final gId = _uuid.v4();
          await db.goalsDao.insertGoal(
            GoalsCompanion(
              id: Value(gId),
              title: Value(g.title),
              emoji: Value(g.emoji),
              createdAt: Value(now),
            ),
          );
          goalIdMap[g.title.toLowerCase()] = gId;
        }
      }

      // 2. Insert Quests
      for (final q in quests) {
        final qId = _uuid.v4();
        String? resolvedGoalId;
        if (q.goal != null) {
          resolvedGoalId = goalIdMap[q.goal!.toLowerCase()];
        }

        await db.questsDao.insertQuest(
          QuestsCompanion(
            id: Value(qId),
            title: Value(q.title),
            note: Value(q.note),
            rule: Value(q.rule),
            targetType: Value(q.targetType.index),
            targetValue: Value(q.targetValue),
            unit: Value(q.unit),
            difficulty: Value(q.difficulty.index),
            essential: Value(q.essential),
            goalId: Value(resolvedGoalId),
            domain: Value(q.domain.index),
            createdAt: Value(now),
          ),
        );

        createdQuestIds.add(qId);
      }
    });

    return createdQuestIds;
  }

  /// Roll back an imported batch of quests (undo within 5s window)
  static Future<void> undoImport(AppDatabase db, List<String> createdIds) async {
    await db.transaction(() async {
      for (final id in createdIds) {
        await (db.delete(db.quests)..where((tbl) => tbl.id.equals(id))).go();
      }
    });
  }

  /// Export selected active quests and their referenced goals as a JSON Quest Pack
  static String exportPack({
    required List<QuestData> quests,
    required List<GoalData> goals,
    required String packName,
    String? description,
  }) {
    final Map<String, GoalData> goalMap = {for (final g in goals) g.id: g};
    final Set<String> referencedGoalIds = {};

    final List<Map<String, dynamic>> questsJson = [];
    for (final q in quests) {
      if (q.goalId != null) {
        referencedGoalIds.add(q.goalId!);
      }

      final goalTitle = q.goalId != null ? goalMap[q.goalId]?.title : null;
      final targetType = TargetType.values[q.targetType];
      final difficulty = Difficulty.values[q.difficulty];
      final domain = q.domain != null ? CallingDomain.values[q.domain!] : CallingDomain.warrior;

      final packQuest = QuestPackQuest(
        title: q.title,
        note: q.note,
        goal: goalTitle,
        cadence: q.rule.cadence,
        rule: q.rule,
        targetType: targetType,
        targetValue: q.targetValue,
        unit: q.unit,
        difficulty: difficulty,
        essential: q.essential,
        domain: domain,
      );

      questsJson.add(packQuest.toJson());
    }

    final List<Map<String, dynamic>> goalsJson = [];
    for (final gId in referencedGoalIds) {
      final g = goalMap[gId];
      if (g != null) {
        goalsJson.add({
          'title': g.title,
          'emoji': g.emoji,
        });
      }
    }

    final pack = {
      'format': formatIdentifier,
      'version': currentVersion,
      'name': packName,
      if (description != null) 'description': description,
      'goals': goalsJson,
      'quests': questsJson,
    };

    return const JsonEncoder.withIndent('  ').convert(pack);
  }

  /// Generate a ready-to-import sample Quest Pack template with diverse cadences
  static String sampleTemplate() {
    final samplePack = {
      'format': formatIdentifier,
      'version': currentVersion,
      'name': 'Disciplined Scholar Pack',
      'description': 'A foundational pack balancing physical endurance, reading, and creative practice.',
      'goals': [
        {'title': 'Mental Fortitude', 'emoji': '🏛️'},
        {'title': 'Vital Conditioning', 'emoji': '⚔️'},
      ],
      'quests': [
        {
          'title': 'Morning Pushups',
          'goal': 'Vital Conditioning',
          'cadence': 'daily',
          'rule': {'cadence': 'daily', 'mode': 'every_day'},
          'target_type': 'checkbox',
          'difficulty': 'medium',
          'essential': true,
          'domain': 'warrior',
        },
        {
          'title': 'Hydration Target',
          'goal': 'Vital Conditioning',
          'cadence': 'daily',
          'rule': {'cadence': 'daily', 'mode': 'every_day'},
          'target_type': 'counter',
          'target_value': 4,
          'unit': 'bottles',
          'difficulty': 'easy',
          'essential': false,
          'domain': 'monk',
        },
        {
          'title': 'Classical Philosophy Reading',
          'goal': 'Mental Fortitude',
          'cadence': 'weekly',
          'rule': {'cadence': 'weekly', 'mode': 'times', 'times': 3},
          'target_type': 'checkbox',
          'difficulty': 'hard',
          'essential': false,
          'domain': 'sage',
        },
      ],
    };

    return const JsonEncoder.withIndent('  ').convert(samplePack);
  }
}
