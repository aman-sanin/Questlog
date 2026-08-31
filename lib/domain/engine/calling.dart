import '../model/models.dart';

class CallingInfo {
  final CallingDomain domain;
  final String name;
  final String tagline;
  final String description;
  final List<String> focusAreas;
  final String trialName;
  final String trialDescription;

  const CallingInfo({
    required this.domain,
    required this.name,
    required this.tagline,
    required this.description,
    required this.focusAreas,
    required this.trialName,
    required this.trialDescription,
  });
}

class CallingEngine {
  static const Map<CallingDomain, CallingInfo> callings = {
    CallingDomain.warrior: CallingInfo(
      domain: CallingDomain.warrior,
      name: 'Warrior',
      tagline: 'The discipline of iron and sinew.',
      description: 'Forged through physical resilience, strength workouts, and enduring daily vitality.',
      focusAreas: ['Strength', 'Mobility', 'Conditioning', 'Discipline'],
      trialName: 'Trial of the Vanguard',
      trialDescription: 'Maintain a 30-day streak on any Warrior quest.',
    ),
    CallingDomain.sage: CallingInfo(
      domain: CallingDomain.sage,
      name: 'Sage',
      tagline: 'The clarity of mind and illuminated study.',
      description: 'Dedicated to relentless reading, deep intellectual inquiry, and technical mastery.',
      focusAreas: ['Reading', 'Research', 'Languages', 'Study'],
      trialName: 'Trial of the Archon',
      trialDescription: 'Log 50 reading or learning sessions.',
    ),
    CallingDomain.monk: CallingInfo(
      domain: CallingDomain.monk,
      name: 'Monk',
      tagline: 'The stillness of spirit and quiet awareness.',
      description: 'Anchored in meditation, breathwork, mindful detachment, and intentional presence.',
      focusAreas: ['Meditation', 'Reflection', 'Gratitude', 'Sabbath'],
      trialName: 'Trial of the Lotus',
      trialDescription: 'Complete 21 consecutive days of meditation or mindfulness.',
    ),
    CallingDomain.bard: CallingInfo(
      domain: CallingDomain.bard,
      name: 'Bard',
      tagline: 'The pulse of art, rhythm, and story.',
      description: 'Channeling expression through music, creative writing, social connection, and performance.',
      focusAreas: ['Music', 'Writing', 'Art', 'Community'],
      trialName: 'Trial of the Skald',
      trialDescription: 'Earn 1,000 XP through creative quests.',
    ),
    CallingDomain.ranger: CallingInfo(
      domain: CallingDomain.ranger,
      name: 'Ranger',
      tagline: 'The instinct of the open wild.',
      description: 'Attuned to outdoor movement, trail hiking, wilderness exploration, and natural daylight.',
      focusAreas: ['Hiking', 'Trail Running', 'Sunlight', 'Outdoors'],
      trialName: 'Trial of the Pathfinder',
      trialDescription: 'Log outdoor activity on 10 consecutive weekends.',
    ),
    CallingDomain.artificer: CallingInfo(
      domain: CallingDomain.artificer,
      name: 'Artificer',
      tagline: 'The mastery of tools, logic, and craft.',
      description: 'Building tools, shipping code, designing systems, and maintaining clean workspaces.',
      focusAreas: ['Code', 'Engineering', 'Craft', 'Order'],
      trialName: 'Trial of the Demiurge',
      trialDescription: 'Ship 5 project milestones or craft completions.',
    ),
  };

  static CallingInfo getInfo(CallingDomain domain) {
    return callings[domain]!;
  }

  static const List<int> milestoneThresholds = [250, 1000, 5000];

  /// Calculate derived stats and progression tier for a specific calling domain
  static DomainStats calculateDomainStats({
    required CallingDomain domain,
    required int domainXp,
    required int completionsCount,
  }) {
    int tier = 0;
    for (int i = 0; i < milestoneThresholds.length; i++) {
      if (domainXp >= milestoneThresholds[i]) {
        tier = i + 1;
      }
    }

    int prevThreshold = tier == 0 ? 0 : milestoneThresholds[tier - 1];
    int nextThreshold = tier < milestoneThresholds.length
        ? milestoneThresholds[tier]
        : milestoneThresholds.last;

    double progress = 1.0;
    if (tier < milestoneThresholds.length) {
      final range = nextThreshold - prevThreshold;
      final currentInRange = (domainXp - prevThreshold).clamp(0, range);
      progress = range > 0 ? currentInRange / range : 1.0;
    }

    return DomainStats(
      domain: domain,
      info: getInfo(domain),
      totalXp: domainXp,
      completionsCount: completionsCount,
      tier: tier,
      tierTitle: tier == 0 ? '${domain.name.toUpperCase()} RECRUIT' : '${domain.name.toUpperCase()} ${tierRoman(tier)}',
      progressToNext: progress,
      nextThreshold: nextThreshold,
    );
  }

  static String tierRoman(int tier) {
    switch (tier) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      default:
        return 'III';
    }
  }
}

class DomainStats {
  final CallingDomain domain;
  final CallingInfo info;
  final int totalXp;
  final int completionsCount;
  final int tier; // 0, 1 (250), 2 (1000), 3 (5000)
  final String tierTitle;
  final double progressToNext;
  final int nextThreshold;

  const DomainStats({
    required this.domain,
    required this.info,
    required this.totalXp,
    required this.completionsCount,
    required this.tier,
    required this.tierTitle,
    required this.progressToNext,
    required this.nextThreshold,
  });
}
