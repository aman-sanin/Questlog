import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/constants/tunables.dart';
import '../../domain/engine/coach.dart';
import '../../domain/model/models.dart';
import 'database_provider.dart';
import 'profile_provider.dart';

final coachShownMapProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return ref.watch(ledgerDaoProvider).watchKv('coach_shown').map((raw) {
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return <String, dynamic>{};
  });
});

final activeCoachSignalProvider = FutureProvider<CoachSignal?>((ref) async {
  final today = ref.watch(effectiveLocalDateProvider);
  final weekStart = ref.watch(weekStartProvider);
  final profileAsync = ref.watch(profileStreamProvider);
  final profile = profileAsync.value;
  final userName = profile?.name;

  final questsDao = ref.watch(questsDaoProvider);
  final completionsDao = ref.watch(completionsDaoProvider);
  final ledgerDao = ref.watch(ledgerDaoProvider);

  final activeQuests = await questsDao.getAllQuests();
  final completions = await completionsDao.getAllCompletions();
  final shownMapAsync = ref.watch(coachShownMapProvider);
  final shownMap = shownMapAsync.value ?? <String, dynamic>{};

  // Group completions by questId and date
  final completionsByQuest = <String, Map<LocalDate, int>>{};
  int lifetimeCompletions = completions.length;
  LocalDate? lastActiveDate;

  for (final c in completions) {
    final d = LocalDate.parse(c.localDate);
    completionsByQuest.putIfAbsent(c.questId, () => {})[d] = (completionsByQuest[c.questId]?[d] ?? 0) + c.value;
    if (lastActiveDate == null || d > lastActiveDate) {
      lastActiveDate = d;
    }
  }

  // Get lastExportAt from KV
  final lastExportRaw = await ledgerDao.getKv('lastExportAt');
  final LocalDate? lastExportDate = lastExportRaw != null ? LocalDate.parse(lastExportRaw) : null;

  // Build QuestHistoryData list
  final historyList = <QuestHistoryData>[];
  int unsatisfiedEssentialThisWeek = 0;

  for (final q in activeQuests) {
    final questCompletions = completionsByQuest[q.id] ?? {};
    final isSatisfiedToday = (questCompletions[today] ?? 0) >= q.targetValue;
    
    // Calculate simple streak
    int streak = 0;
    if (questCompletions.isNotEmpty) {
      for (int i = 0; i < 365; i++) {
        final d = today.subtractDays(i);
        if (q.rule.isScheduledOn(d, weekStart.value)) {
          if ((questCompletions[d] ?? 0) >= q.targetValue) {
            streak++;
          } else if (i > 0) {
            break;
          }
        }
      }
    }

    if (q.essential && q.archivedAt == null) {
      final period = q.rule.periodOf(today, weekStart.value);
      int periodCompleted = 0;
      for (final entry in questCompletions.entries) {
        if (entry.key >= period.startLocalDate && entry.key <= period.endLocalDate) {
          periodCompleted += entry.value;
        }
      }
      if (periodCompleted < q.targetValue) {
        unsatisfiedEssentialThisWeek++;
      }
    }

    historyList.add(QuestHistoryData(
      id: q.id,
      title: q.title,
      rule: q.rule,
      targetType: TargetType.values[q.targetType],
      targetValue: q.targetValue,
      difficulty: Difficulty.values[q.difficulty],
      essential: q.essential,
      createdAt: q.createdAt,
      archivedAt: q.archivedAt,
      pausedUntil: q.pausedUntil != null ? LocalDate.parse(q.pausedUntil!) : null,
      completions: questCompletions,
      currentStreak: streak,
      isSatisfiedToday: isSatisfiedToday,
    ));
  }

  final nowDt = today.toDateTime();
  final daysLeftInWeek = (weekStart == WeekStart.monday ? 7 - nowDt.weekday : (7 - (nowDt.weekday % 7)));

  final rawSignals = CoachEngine.evaluateAll(
    activeQuests: historyList,
    today: today,
    weekStart: weekStart,
    userName: userName,
    lastActiveDate: lastActiveDate,
    lastExportDate: lastExportDate,
    lifetimeCompletions: lifetimeCompletions,
    daysLeftInWeek: max(0, daysLeftInWeek),
    unsatisfiedEssentialThisWeek: unsatisfiedEssentialThisWeek,
  );

  // Filter against KV cooldowns
  for (final signal in rawSignals) {
    final entry = shownMap[signal.dedupKey];
    if (entry != null) {
      if (entry['once'] == true) {
        continue;
      }
      if (entry['last'] != null) {
        final lastDate = LocalDate.parse(entry['last']);
        final dismissCount = (entry['dismissCount'] as num?)?.toInt() ?? 0;
        final baseCooldown = signal.cooldownDays;
        final effectiveCooldown = dismissCount > 0
            ? min(baseCooldown * (1 << dismissCount), CoachTunables.coachMaxCooldown)
            : baseCooldown;

        if (today.differenceInDays(lastDate) < effectiveCooldown) {
          continue; // Cooldown still active
        }
      }
    }

    // First valid candidate wins
    return signal;
  }

  return null;
});

class CoachController {
  final Ref ref;

  CoachController(this.ref);

  Future<void> dismiss(CoachSignal signal) async {
    final today = ref.read(effectiveLocalDateProvider);
    final ledgerDao = ref.read(ledgerDaoProvider);
    final raw = await ledgerDao.getKv('coach_shown');
    Map<String, dynamic> map = {};
    if (raw != null && raw.isNotEmpty) {
      try {
        map = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }

    if (signal.ruleType == CoachRuleType.milestoneNear) {
      map[signal.dedupKey] = {'once': true};
    } else {
      final prevCount = (map[signal.dedupKey]?['dismissCount'] as num?)?.toInt() ?? 0;
      map[signal.dedupKey] = {
        'last': today.dateString,
        'dismissCount': prevCount + 1,
      };
    }

    await ledgerDao.setKv('coach_shown', jsonEncode(map));
  }

  Future<void> markAccepted(CoachSignal signal) async {
    final today = ref.read(effectiveLocalDateProvider);
    final ledgerDao = ref.read(ledgerDaoProvider);
    final raw = await ledgerDao.getKv('coach_shown');
    Map<String, dynamic> map = {};
    if (raw != null && raw.isNotEmpty) {
      try {
        map = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }

    if (signal.ruleType == CoachRuleType.milestoneNear) {
      map[signal.dedupKey] = {'once': true};
    } else {
      map[signal.dedupKey] = {
        'last': today.dateString,
        'dismissCount': 0,
      };
    }

    await ledgerDao.setKv('coach_shown', jsonEncode(map));
  }
}

final coachControllerProvider = Provider<CoachController>((ref) {
  return CoachController(ref);
});
