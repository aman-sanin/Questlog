import '../model/models.dart';

class BadgeDefinition {
  final String key;
  final String title;
  final String flavor;
  final String icon;
  final String requirement;

  const BadgeDefinition({
    required this.key,
    required this.title,
    required this.flavor,
    required this.icon,
    required this.requirement,
  });
}

class BadgeStatus {
  final BadgeDefinition definition;
  final bool isEarned;
  final String? earnedDate;

  const BadgeStatus({
    required this.definition,
    required this.isEarned,
    this.earnedDate,
  });
}

class BadgeEngine {
  static const List<BadgeDefinition> catalog = [
    BadgeDefinition(
      key: 'first_step',
      title: 'First Step',
      flavor: 'Every legend begins with a single mark upon the scroll.',
      icon: 'footprint',
      requirement: 'Complete your first quest.',
    ),
    BadgeDefinition(
      key: 'streak_7',
      title: 'Sevenfold',
      flavor: 'One full cycle of discipline completed without falter.',
      icon: 'repeat',
      requirement: 'Reach a 7-period streak on any quest.',
    ),
    BadgeDefinition(
      key: 'streak_30',
      title: 'Iron Will',
      flavor: 'A habit etched into the stone of daily routine.',
      icon: 'shield',
      requirement: 'Reach a 30-period streak on any quest.',
    ),
    BadgeDefinition(
      key: 'streak_100',
      title: 'Centurial Streak',
      flavor: 'One hundred intervals unbroken.',
      icon: 'workspace_premium',
      requirement: 'Reach a 100-period streak on any quest.',
    ),
    BadgeDefinition(
      key: 'streak_365',
      title: 'Unbroken Circle',
      flavor: 'A full turn of the seasons. Rare, unyielding devotion.',
      icon: 'military_tech',
      requirement: 'Reach a 365-day streak on any daily quest.',
    ),
    BadgeDefinition(
      key: 'centurion',
      title: 'Centurion',
      flavor: 'One hundred deeds recorded in the great ledger.',
      icon: 'counter_1',
      requirement: 'Complete 100 total quest events.',
    ),
    BadgeDefinition(
      key: 'millennial',
      title: 'Millennial',
      flavor: 'One thousand deeds. The hallmark of a true master.',
      icon: 'diamond',
      requirement: 'Complete 1,000 total quest events.',
    ),
    BadgeDefinition(
      key: 'perfect_ten',
      title: 'Ten Perfect Days',
      flavor: 'Ten days where every essential quest was answered in full.',
      icon: 'hotel_class',
      requirement: 'Achieve 10 Perfect Days.',
    ),
    BadgeDefinition(
      key: 'polymath',
      title: 'Polymath',
      flavor: 'Your journey traverses all six paths of human endeavor.',
      icon: 'all_inclusive',
      requirement: 'Complete quests across all 6 calling domains.',
    ),
    BadgeDefinition(
      key: 'goal_getter',
      title: 'Goal Getter',
      flavor: 'An overarching ambition seen through to completion.',
      icon: 'flag',
      requirement: 'Complete an overarching goal.',
    ),
    BadgeDefinition(
      key: 'early_bird',
      title: 'Dawn Chorus',
      flavor: 'Claiming the quiet morning before the world stirs.',
      icon: 'wb_sunny',
      requirement: 'Complete a quest before 07:00.',
    ),
    BadgeDefinition(
      key: 'comeback',
      title: 'The Return',
      flavor: 'A hiatus ended; the flame rekindled.',
      icon: 'refresh',
      requirement: 'Log a completion after 30+ days away.',
    ),
  ];

  static List<BadgeStatus> evaluate({
    required int totalCompletions,
    required int maxStreak,
    required int perfectDaysCount,
    required Set<CallingDomain> domainsWithCompletions,
    required int completedGoalsCount,
    required Set<String> earnedBadgeKeys,
  }) {
    return catalog.map((badge) {
      bool earned = earnedBadgeKeys.contains(badge.key);

      if (!earned) {
        switch (badge.key) {
          case 'first_step':
            earned = totalCompletions >= 1;
            break;
          case 'centurion':
            earned = totalCompletions >= 100;
            break;
          case 'millennial':
            earned = totalCompletions >= 1000;
            break;
          case 'streak_7':
            earned = maxStreak >= 7;
            break;
          case 'streak_30':
            earned = maxStreak >= 30;
            break;
          case 'streak_100':
            earned = maxStreak >= 100;
            break;
          case 'streak_365':
            earned = maxStreak >= 365;
            break;
          case 'perfect_ten':
            earned = perfectDaysCount >= 10;
            break;
          case 'polymath':
            earned = domainsWithCompletions.length >= 6;
            break;
          case 'goal_getter':
            earned = completedGoalsCount >= 1;
            break;
        }
      }

      return BadgeStatus(
        definition: badge,
        isEarned: earned,
      );
    }).toList();
  }
}
