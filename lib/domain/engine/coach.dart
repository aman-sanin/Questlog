import 'dart:math';
import '../constants/tunables.dart';
import '../model/models.dart';
import 'schedule_rule.dart';

enum CoachRuleType {
  welcomeBack,
  backupNudge,
  essentialStumble,
  load,
  zombie,
  stale,
  rightsize,
  mastery,
  milestoneNear,
  perfectWeekNear,
}

enum CoachActionType {
  dismiss,
  pause,
  archive,
  export,
  reviewLoad,
  raiseTarget,
  raiseDifficulty,
  lowerTarget,
  suggestCadence,
  understood,
  continueFlow,
}

class CoachAction {
  final String label;
  final CoachActionType type;
  final dynamic payload;

  const CoachAction({
    required this.label,
    required this.type,
    this.payload,
  });

  @override
  String toString() => 'CoachAction($label, $type)';
}

class CoachSignal implements Comparable<CoachSignal> {
  final CoachRuleType ruleType;
  final String? questId;
  final String title;
  final String message;
  final List<CoachAction> actions;
  final String dedupKey;
  final int cooldownDays;
  final double? rate;
  final int? streak;
  final DateTime? createdAt;
  final List<String>? relatedQuestIds;

  const CoachSignal({
    required this.ruleType,
    this.questId,
    required this.title,
    required this.message,
    required this.actions,
    required this.dedupKey,
    required this.cooldownDays,
    this.rate,
    this.streak,
    this.createdAt,
    this.relatedQuestIds,
  });

  int get rulePriority {
    switch (ruleType) {
      case CoachRuleType.welcomeBack:
        return 0;
      case CoachRuleType.backupNudge:
        return 1;
      case CoachRuleType.essentialStumble:
        return 2;
      case CoachRuleType.load:
        return 3;
      case CoachRuleType.zombie:
        return 4;
      case CoachRuleType.stale:
        return 5;
      case CoachRuleType.rightsize:
        return 6;
      case CoachRuleType.mastery:
        return 7;
      case CoachRuleType.milestoneNear:
        return 8;
      case CoachRuleType.perfectWeekNear:
        return 9;
    }
  }

  @override
  int compareTo(CoachSignal other) {
    final p = rulePriority.compareTo(other.rulePriority);
    if (p != 0) return p;

    // Within-class tiebreaks
    if (ruleType == CoachRuleType.mastery) {
      final s = (other.streak ?? 0).compareTo(streak ?? 0);
      if (s != 0) return s;
    } else if (rate != null && other.rate != null) {
      final r = rate!.compareTo(other.rate!);
      if (r != 0) return r;
    }

    final c = (createdAt ?? DateTime(0)).compareTo(other.createdAt ?? DateTime(0));
    if (c != 0) return c;

    return (questId ?? '').compareTo(other.questId ?? '');
  }
}

class QuestHistoryData {
  final String id;
  final String title;
  final ScheduleRule rule;
  final TargetType targetType;
  final int targetValue;
  final Difficulty difficulty;
  final bool essential;
  final DateTime createdAt;
  final DateTime? archivedAt;
  final LocalDate? pausedUntil;
  final Map<LocalDate, int> completions;
  final int currentStreak;
  final bool isSatisfiedToday;

  const QuestHistoryData({
    required this.id,
    required this.title,
    required this.rule,
    required this.targetType,
    required this.targetValue,
    required this.difficulty,
    required this.essential,
    required this.createdAt,
    this.archivedAt,
    this.pausedUntil,
    required this.completions,
    required this.currentStreak,
    required this.isSatisfiedToday,
  });
}

class CoachEngine {
  /// Pure function that computes 14d scheduled and satisfied periods for a quest
  static ({int scheduled, int satisfied, double rate}) calculate14dRate({
    required QuestHistoryData quest,
    required LocalDate today,
    required WeekStart weekStart,
  }) {
    final createdLocalDate = LocalDate.fromDateTime(quest.createdAt);
    int scheduled = 0;
    int satisfied = 0;

    for (int i = 13; i >= 0; i--) {
      final d = today.subtractDays(i);

      // Exclude days before birth grace
      if (d < createdLocalDate) continue;

      // Exclude paused days
      if (quest.pausedUntil != null && d <= quest.pausedUntil!) continue;

      // Check if scheduled
      if (quest.rule.isScheduledOn(d, weekStart.value)) {
        scheduled++;
        final dayVal = quest.completions[d] ?? 0;
        if (dayVal >= quest.targetValue) {
          satisfied++;
        }
      }
    }

    final rate = scheduled > 0 ? (satisfied / scheduled) : 0.0;
    return (scheduled: scheduled, satisfied: satisfied, rate: rate);
  }

  /// Pure function evaluating all detectors, returning candidate signals sorted deterministically
  static List<CoachSignal> evaluateAll({
    required List<QuestHistoryData> activeQuests,
    required LocalDate today,
    required WeekStart weekStart,
    String? userName,
    LocalDate? lastActiveDate,
    LocalDate? lastExportDate,
    int lifetimeCompletions = 0,
    int daysLeftInWeek = 0,
    int unsatisfiedEssentialThisWeek = 0,
  }) {
    final signals = <CoachSignal>[];
    final trimmedName = userName?.trim();
    final namePrefix = (trimmedName != null && trimmedName.isNotEmpty) ? '$trimmedName, ' : '';
    final nameTitle = (trimmedName != null && trimmedName.isNotEmpty) ? 'COACH · ${trimmedName.toUpperCase()}' : 'COACH';

    // 1. welcome_back detector
    if (lastActiveDate != null) {
      final absentDays = today.differenceInDays(lastActiveDate);
      if (absentDays >= CoachTunables.coachZombieDays) {
        signals.add(CoachSignal(
          ruleType: CoachRuleType.welcomeBack,
          title: nameTitle,
          message: '${namePrefix}away $absentDays days — today is unwritten.',
          actions: const [
            CoachAction(label: 'Continue', type: CoachActionType.continueFlow),
            CoachAction(label: 'Review quests', type: CoachActionType.reviewLoad),
          ],
          dedupKey: 'welcome_back',
          cooldownDays: CoachTunables.coachWelcomeCooldown,
        ));
      }
    }

    // 2. backup_nudge detector
    if (lifetimeCompletions >= CoachTunables.coachBackupMinCompletions) {
      final needsExport = lastExportDate == null || today.differenceInDays(lastExportDate) > CoachTunables.coachBackupDays;
      if (needsExport) {
        signals.add(CoachSignal(
          ruleType: CoachRuleType.backupNudge,
          title: nameTitle,
          message: '$namePrefix$lifetimeCompletions completions live on this device alone. Export a backup?',
          actions: const [
            CoachAction(label: 'Export', type: CoachActionType.export),
          ],
          dedupKey: 'backup_nudge',
          cooldownDays: CoachTunables.coachBaseCooldown,
        ));
      }
    }

    final lowRateQuestIds = <String>[];
    final ruleTriggerCounts = <CoachRuleType, List<CoachSignal>>{};

    for (final q in activeQuests) {
      if (q.archivedAt != null) continue;

      final stats = calculate14dRate(quest: q, today: today, weekStart: weekStart);
      if (stats.rate < CoachTunables.coachRightsizePct && stats.scheduled >= CoachTunables.coachMasteryPeriods) {
        lowRateQuestIds.add(q.id);
      }

      // Check per-quest health & momentum detectors:

      // 3. essential_stumble: >= 3 consecutive closed unsatisfied essential units
      if (q.essential) {
        int consecutiveMisses = 0;
        final createdLocalDate = LocalDate.fromDateTime(q.createdAt);
        // Look back from yesterday backwards over closed periods
        for (int i = 1; i <= 30; i++) {
          final d = today.subtractDays(i);
          if (d < createdLocalDate) break;
          if (q.pausedUntil != null && d <= q.pausedUntil!) continue;
          if (q.rule.isScheduledOn(d, weekStart.value)) {
            final val = q.completions[d] ?? 0;
            if (val < q.targetValue) {
              consecutiveMisses++;
              if (consecutiveMisses >= CoachTunables.coachStumbleCount) break;
            } else {
              break;
            }
          }
        }

        if (consecutiveMisses >= CoachTunables.coachStumbleCount) {
          final s = CoachSignal(
            ruleType: CoachRuleType.essentialStumble,
            questId: q.id,
            title: nameTitle,
            message: '${namePrefix}three misses in a row on ${q.title} — still the right quest?',
            actions: [
              CoachAction(label: 'Pause', type: CoachActionType.pause, payload: {'questId': q.id, 'days': 14}),
              const CoachAction(label: 'Keep going', type: CoachActionType.dismiss),
            ],
            dedupKey: 'essential_stumble:${q.id}',
            cooldownDays: CoachTunables.coachStumbleCooldown,
            createdAt: q.createdAt,
            rate: stats.rate,
          );
          ruleTriggerCounts.putIfAbsent(CoachRuleType.essentialStumble, () => []).add(s);
          signals.add(s);
        }
      }

      // 5. zombie: created >= 14d & zero completions ever
      final totalCompletions = q.completions.values.fold(0, (sum, v) => sum + v);
      final daysSinceCreation = today.differenceInDays(LocalDate.fromDateTime(q.createdAt));
      if (daysSinceCreation >= CoachTunables.coachZombieDays && totalCompletions == 0) {
        final s = CoachSignal(
          ruleType: CoachRuleType.zombie,
          questId: q.id,
          title: nameTitle,
          message: '$namePrefix${q.title} was never started.',
          actions: [
            CoachAction(label: 'Right-size', type: CoachActionType.lowerTarget, payload: {'questId': q.id}),
            CoachAction(label: 'Archive', type: CoachActionType.archive, payload: {'questId': q.id}),
          ],
          dedupKey: 'zombie:${q.id}',
          cooldownDays: CoachTunables.coachBaseCooldown,
          createdAt: q.createdAt,
          rate: 0.0,
        );
        ruleTriggerCounts.putIfAbsent(CoachRuleType.zombie, () => []).add(s);
        signals.add(s);
      }

      // 6. stale: last completion >= 30d & active & >= 1 completion ever
      if (totalCompletions > 0 && (q.pausedUntil == null || today > q.pausedUntil!)) {
        LocalDate? lastCompDate;
        for (final entry in q.completions.entries) {
          if (entry.value > 0) {
            if (lastCompDate == null || entry.key > lastCompDate) {
              lastCompDate = entry.key;
            }
          }
        }
        if (lastCompDate != null) {
          final daysSinceComp = today.differenceInDays(lastCompDate);
          if (daysSinceComp >= CoachTunables.coachStaleDays) {
            final s = CoachSignal(
              ruleType: CoachRuleType.stale,
              questId: q.id,
              title: nameTitle,
              message: "$namePrefix${q.title} hasn't been logged in $daysSinceComp days.",
              actions: [
                CoachAction(label: 'Pause 30 days', type: CoachActionType.pause, payload: {'questId': q.id, 'days': 30}),
                CoachAction(label: 'Archive', type: CoachActionType.archive, payload: {'questId': q.id}),
              ],
              dedupKey: 'stale:${q.id}',
              cooldownDays: CoachTunables.coachBaseCooldown,
              createdAt: q.createdAt,
              rate: 0.0,
            );
            ruleTriggerCounts.putIfAbsent(CoachRuleType.stale, () => []).add(s);
            signals.add(s);
          }
        }
      }

      // 7. rightsize: rate < 0.50 & >= 10 periods & past grace
      if (stats.scheduled >= CoachTunables.coachMasteryPeriods && stats.rate < CoachTunables.coachRightsizePct) {
        final pct = (stats.rate * 100).round();
        final actions = <CoachAction>[];
        if (q.rule is DailyRule || (q.rule is WeeklyRule && (q.rule as WeeklyRule).allowedDays != null && (q.rule as WeeklyRule).allowedDays!.length >= 5)) {
          actions.add(CoachAction(label: 'Daily → 3× weekly', type: CoachActionType.suggestCadence, payload: {'questId': q.id, 'rule': const WeeklyRule.times(3)}));
        }
        if (q.targetType == TargetType.counter) {
          actions.add(CoachAction(label: 'Lower target', type: CoachActionType.lowerTarget, payload: {'questId': q.id}));
        } else if (actions.isEmpty) {
          actions.add(CoachAction(label: 'Right-size', type: CoachActionType.lowerTarget, payload: {'questId': q.id}));
        }
        actions.add(const CoachAction(label: 'Keep', type: CoachActionType.dismiss));

        final s = CoachSignal(
          ruleType: CoachRuleType.rightsize,
          questId: q.id,
          title: nameTitle,
          message: '$namePrefix${q.title} is at $pct% over two weeks — right-size it?',
          actions: actions,
          dedupKey: 'rightsize:${q.id}',
          cooldownDays: CoachTunables.coachBaseCooldown,
          rate: stats.rate,
          createdAt: q.createdAt,
        );
        ruleTriggerCounts.putIfAbsent(CoachRuleType.rightsize, () => []).add(s);
        signals.add(s);
      }

      // 8. mastery: rate >= 0.90 & >= 10 periods & streak >= 7
      if (stats.scheduled >= CoachTunables.coachMasteryPeriods && stats.rate >= CoachTunables.coachMasteryPct && q.currentStreak >= 7) {
        final pct = (stats.rate * 100).round();
        final actions = <CoachAction>[];
        if (q.targetType == TargetType.counter) {
          final step = max(1, q.targetValue ~/ 2);
          final nextVal = q.targetValue + step;
          actions.add(CoachAction(label: '${q.targetValue} → $nextVal', type: CoachActionType.raiseTarget, payload: {'questId': q.id, 'targetValue': nextVal}));
        } else {
          final nextDiff = q.difficulty == Difficulty.easy ? 'Easy → Medium' : 'Medium → Hard';
          final newDiff = q.difficulty == Difficulty.easy ? Difficulty.medium : Difficulty.hard;
          actions.add(CoachAction(label: nextDiff, type: CoachActionType.raiseDifficulty, payload: {'questId': q.id, 'difficulty': newDiff}));
        }
        actions.add(const CoachAction(label: 'Keep', type: CoachActionType.dismiss));

        final s = CoachSignal(
          ruleType: CoachRuleType.mastery,
          questId: q.id,
          title: nameTitle,
          message: '$namePrefix${q.title} is at $pct% over two weeks — raise the bar?',
          actions: actions,
          dedupKey: 'mastery:${q.id}',
          cooldownDays: CoachTunables.coachBaseCooldown,
          rate: stats.rate,
          streak: q.currentStreak,
          createdAt: q.createdAt,
        );
        ruleTriggerCounts.putIfAbsent(CoachRuleType.mastery, () => []).add(s);
        signals.add(s);
      }

      // 9. milestone_near: currentStreak in {6, 29, 99, 364} & current unit unsatisfied
      if (!q.isSatisfiedToday && {6, 29, 99, 364}.contains(q.currentStreak)) {
        final int targetMilestone;
        final int milestoneXp;
        switch (q.currentStreak) {
          case 6:
            targetMilestone = 7;
            milestoneXp = 50;
            break;
          case 29:
            targetMilestone = 30;
            milestoneXp = 150;
            break;
          case 99:
            targetMilestone = 100;
            milestoneXp = 500;
            break;
          case 364:
          default:
            targetMilestone = 365;
            milestoneXp = 2000;
            break;
        }

        signals.add(CoachSignal(
          ruleType: CoachRuleType.milestoneNear,
          questId: q.id,
          title: nameTitle,
          message: '${namePrefix}one completion banks a $targetMilestone-period milestone — +$milestoneXp XP.',
          actions: const [
            CoachAction(label: 'Understood', type: CoachActionType.understood),
          ],
          dedupKey: 'coach:milestone:${q.id}:$targetMilestone',
          cooldownDays: 99999, // Once ever
          createdAt: q.createdAt,
        ));
      }
    }

    // 4. load detector: >= 6 active quests with 14d rate < 0.50, OR >= 3 quests triggering the same health rule
    bool triggersLoad = lowRateQuestIds.length >= CoachTunables.coachLoadQuests;
    CoachRuleType? suppressedRule;

    for (final entry in ruleTriggerCounts.entries) {
      if (entry.value.length >= CoachTunables.coachLoadCap) {
        triggersLoad = true;
        suppressedRule = entry.key;
        break;
      }
    }

    if (triggersLoad) {
      // Suppress individual cards if >= 3 share a rule
      if (suppressedRule != null) {
        signals.removeWhere((s) => s.ruleType == suppressedRule);
      }

      final count = max(lowRateQuestIds.length, suppressedRule != null ? (ruleTriggerCounts[suppressedRule]?.length ?? 0) : 0);
      signals.add(CoachSignal(
        ruleType: CoachRuleType.load,
        title: nameTitle,
        message: '$namePrefix$count quests are under 50% — time to lighten the load?',
        actions: const [
          CoachAction(label: 'Review', type: CoachActionType.reviewLoad),
          CoachAction(label: 'Keep all', type: CoachActionType.dismiss),
        ],
        dedupKey: 'load',
        cooldownDays: CoachTunables.coachBaseCooldown,
        relatedQuestIds: lowRateQuestIds,
      ));
    }

    // 10. perfect_week_near: calendar days to week-window close <= 1 & exactly 1 unsatisfied essential unit
    if (daysLeftInWeek <= 1 && unsatisfiedEssentialThisWeek == 1) {
      signals.add(CoachSignal(
        ruleType: CoachRuleType.perfectWeekNear,
        title: nameTitle,
        message: '${namePrefix}one quest from a Perfect Week — +75 XP and a freeze.',
        actions: const [
          CoachAction(label: 'Understood', type: CoachActionType.understood),
        ],
        dedupKey: 'perfect_week_near',
        cooldownDays: CoachTunables.coachBaseCooldown,
      ));
    }

    signals.sort();
    return signals;
  }
}
