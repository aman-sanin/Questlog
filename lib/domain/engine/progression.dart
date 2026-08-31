import '../constants/titles.dart';
import '../constants/unlock_schedule.dart';
import '../model/models.dart';

class ProgressionStatus {
  final int totalXp;
  final int level;
  final int xpInCurrentLevel;
  final int xpRequiredForNextLevel;
  final double levelProgress;
  final int xpToNextLevel;
  final String title;
  final Map<CallingDomain, double> domainAffinity;
  final bool respecRecommended;
  final CallingDomain? dominantDomain;
  final UnlockItem? nextUnlock;

  const ProgressionStatus({
    required this.totalXp,
    required this.level,
    required this.xpInCurrentLevel,
    required this.xpRequiredForNextLevel,
    required this.levelProgress,
    required this.xpToNextLevel,
    required this.title,
    required this.domainAffinity,
    required this.respecRecommended,
    this.dominantDomain,
    this.nextUnlock,
  });
}

class ProgressionEngine {
  /// Cumulative XP required to reach a specific level L (1-indexed)
  static int cumulativeXpForLevel(int level) {
    if (level <= 1) return 0;
    final lMinus1 = level - 1;
    return 100 * lMinus1 + 25 * lMinus1 * (level - 2);
  }

  /// Calculates level from total XP
  static int levelFromXp(int totalXp) {
    if (totalXp <= 0) return 1;
    int level = 1;
    while (cumulativeXpForLevel(level + 1) <= totalXp) {
      level++;
    }
    return level;
  }

  /// Calculates the full progression status from total XP and domain breakdown
  static ProgressionStatus calculate({
    required int totalXp,
    CallingDomain? chosenCalling,
    Map<CallingDomain, int> domainXp = const {},
  }) {
    final level = levelFromXp(totalXp);
    final currentLevelBaseXp = cumulativeXpForLevel(level);
    final nextLevelBaseXp = cumulativeXpForLevel(level + 1);

    final xpInCurrentLevel = totalXp - currentLevelBaseXp;
    final xpRequiredForNextLevel = nextLevelBaseXp - currentLevelBaseXp;
    final xpToNextLevel = (nextLevelBaseXp - totalXp).clamp(0, nextLevelBaseXp);
    final levelProgress = xpRequiredForNextLevel > 0
        ? (xpInCurrentLevel / xpRequiredForNextLevel).clamp(0.0, 1.0)
        : 1.0;

    final title = CallingTitles.titleFor(calling: chosenCalling, level: level);

    // Calculate domain affinities
    final affinity = <CallingDomain, double>{};
    int totalTrackedDomainXp = 0;
    for (final amount in domainXp.values) {
      totalTrackedDomainXp += amount;
    }

    CallingDomain? topDomain;
    double topAffinity = 0.0;

    for (final domain in CallingDomain.values) {
      final earned = domainXp[domain] ?? 0;
      final ratio = totalTrackedDomainXp > 0 ? (earned / totalTrackedDomainXp) : 0.0;
      affinity[domain] = ratio;
      if (ratio > topAffinity) {
        topAffinity = ratio;
        topDomain = domain;
      }
    }

    final bool respecRecommended = chosenCalling != null &&
        topDomain != null &&
        topDomain != chosenCalling &&
        topAffinity > 0.50;

    final nextUnlock = UnlockSchedule.nextUnlock(level);

    return ProgressionStatus(
      totalXp: totalXp,
      level: level,
      xpInCurrentLevel: xpInCurrentLevel,
      xpRequiredForNextLevel: xpRequiredForNextLevel,
      levelProgress: levelProgress,
      xpToNextLevel: xpToNextLevel,
      title: title,
      domainAffinity: affinity,
      respecRecommended: respecRecommended,
      dominantDomain: topDomain,
      nextUnlock: nextUnlock,
    );
  }
}
