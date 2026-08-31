import 'engine/schedule_rule.dart';
import 'model/models.dart';

class QuestTemplate {
  final String title;
  final String category;
  final ScheduleRule rule;
  final TargetType targetType;
  final int targetValue;
  final String? unit;
  final Difficulty difficulty;
  final bool essential;
  final CallingDomain domain;

  const QuestTemplate({
    required this.title,
    required this.category,
    required this.rule,
    this.targetType = TargetType.checkbox,
    this.targetValue = 1,
    this.unit,
    this.difficulty = Difficulty.medium,
    this.essential = false,
    required this.domain,
  });
}

class StarterTemplates {
  static const List<QuestTemplate> templates = [
    // FITNESS (Warrior)
    QuestTemplate(
      title: 'Morning Pushups & Core',
      category: 'FITNESS',
      rule: DailyEveryDayRule(),
      difficulty: Difficulty.medium,
      essential: true,
      domain: CallingDomain.warrior,
    ),
    QuestTemplate(
      title: 'Gym Strength Workout',
      category: 'FITNESS',
      rule: WeeklyTimesRule(times: 3),
      difficulty: Difficulty.hard,
      essential: true,
      domain: CallingDomain.warrior,
    ),
    QuestTemplate(
      title: 'Drink 8 Glasses of Water',
      category: 'FITNESS',
      rule: DailyEveryDayRule(),
      targetType: TargetType.counter,
      targetValue: 8,
      unit: 'glasses',
      difficulty: Difficulty.easy,
      essential: false,
      domain: CallingDomain.warrior,
    ),
    QuestTemplate(
      title: 'Evening Stretch & Mobility',
      category: 'FITNESS',
      rule: DailyEveryDayRule(),
      difficulty: Difficulty.easy,
      essential: false,
      domain: CallingDomain.warrior,
    ),

    // MIND (Monk)
    QuestTemplate(
      title: 'Mindful Meditation',
      category: 'MIND',
      rule: DailyEveryDayRule(),
      difficulty: Difficulty.medium,
      essential: true,
      domain: CallingDomain.monk,
    ),
    QuestTemplate(
      title: 'Evening Gratitude Log',
      category: 'MIND',
      rule: DailyEveryDayRule(),
      difficulty: Difficulty.easy,
      essential: false,
      domain: CallingDomain.monk,
    ),
    QuestTemplate(
      title: 'No Phone First 30 Min',
      category: 'MIND',
      rule: DailyEveryDayRule(),
      difficulty: Difficulty.medium,
      essential: true,
      domain: CallingDomain.monk,
    ),
    QuestTemplate(
      title: 'Digital Sabbath',
      category: 'MIND',
      rule: WeeklyOnDaysRule(days: [7]), // Sunday
      difficulty: Difficulty.hard,
      essential: false,
      domain: CallingDomain.monk,
    ),

    // LEARNING (Sage)
    QuestTemplate(
      title: 'Read Non-Fiction (20 min)',
      category: 'LEARNING',
      rule: DailyEveryDayRule(),
      difficulty: Difficulty.medium,
      essential: true,
      domain: CallingDomain.sage,
    ),
    QuestTemplate(
      title: 'Language Lesson Practice',
      category: 'LEARNING',
      rule: DailyWeekdaysRule(days: [1, 2, 3, 4, 5]),
      difficulty: Difficulty.easy,
      essential: false,
      domain: CallingDomain.sage,
    ),
    QuestTemplate(
      title: 'Read 25 Pages of Book',
      category: 'LEARNING',
      rule: DailyEveryDayRule(),
      targetType: TargetType.counter,
      targetValue: 25,
      unit: 'pages',
      difficulty: Difficulty.medium,
      essential: false,
      domain: CallingDomain.sage,
    ),
    QuestTemplate(
      title: 'Deep Research Session',
      category: 'LEARNING',
      rule: WeeklyTimesRule(times: 2),
      difficulty: Difficulty.hard,
      essential: false,
      domain: CallingDomain.sage,
    ),

    // CRAFT (Artificer)
    QuestTemplate(
      title: 'Deep Work Coding Session',
      category: 'CRAFT',
      rule: DailyWeekdaysRule(days: [1, 2, 3, 4, 5]),
      difficulty: Difficulty.hard,
      essential: true,
      domain: CallingDomain.artificer,
    ),
    QuestTemplate(
      title: 'Practice Tool Mastery',
      category: 'CRAFT',
      rule: WeeklyTimesRule(times: 3),
      difficulty: Difficulty.medium,
      essential: false,
      domain: CallingDomain.artificer,
    ),
    QuestTemplate(
      title: 'Clean Workspace & Organize Desk',
      category: 'CRAFT',
      rule: DailyEveryDayRule(),
      difficulty: Difficulty.easy,
      essential: false,
      domain: CallingDomain.artificer,
    ),
    QuestTemplate(
      title: 'Ship a Project Milestone',
      category: 'CRAFT',
      rule: MonthlyTimesRule(times: 1),
      difficulty: Difficulty.hard,
      essential: true,
      domain: CallingDomain.artificer,
    ),

    // CREATIVE (Bard)
    QuestTemplate(
      title: 'Practice Musical Instrument',
      category: 'CREATIVE',
      rule: DailyEveryDayRule(),
      difficulty: Difficulty.medium,
      essential: false,
      domain: CallingDomain.bard,
    ),
    QuestTemplate(
      title: 'Freeform Writing (500 words)',
      category: 'CREATIVE',
      rule: DailyEveryDayRule(),
      difficulty: Difficulty.medium,
      essential: false,
      domain: CallingDomain.bard,
    ),
    QuestTemplate(
      title: 'Sketch or Visual Study',
      category: 'CREATIVE',
      rule: WeeklyTimesRule(times: 4),
      difficulty: Difficulty.medium,
      essential: false,
      domain: CallingDomain.bard,
    ),
    QuestTemplate(
      title: 'Record & Publish an Audio Note',
      category: 'CREATIVE',
      rule: WeeklyTimesRule(times: 1),
      difficulty: Difficulty.medium,
      essential: false,
      domain: CallingDomain.bard,
    ),

    // RANGER (Ranger)
    QuestTemplate(
      title: 'Outdoor Walk (10,000 steps)',
      category: 'RANGER',
      rule: DailyEveryDayRule(),
      targetType: TargetType.counter,
      targetValue: 10,
      unit: 'k steps',
      difficulty: Difficulty.medium,
      essential: true,
      domain: CallingDomain.ranger,
    ),
    QuestTemplate(
      title: 'Weekend Trail Hike or Run',
      category: 'RANGER',
      rule: WeeklyOnDaysRule(days: [6, 7]), // Sat or Sun
      difficulty: Difficulty.hard,
      essential: false,
      domain: CallingDomain.ranger,
    ),
    QuestTemplate(
      title: 'Sunlight Exposure in Morning',
      category: 'RANGER',
      rule: DailyEveryDayRule(),
      difficulty: Difficulty.easy,
      essential: false,
      domain: CallingDomain.ranger,
    ),

    // HOME (Artificer)
    QuestTemplate(
      title: 'Evening Kitchen Reset',
      category: 'HOME',
      rule: DailyEveryDayRule(),
      difficulty: Difficulty.easy,
      essential: true,
      domain: CallingDomain.artificer,
    ),
    QuestTemplate(
      title: 'Laundry & Linens Cycle',
      category: 'HOME',
      rule: WeeklyTimesRule(times: 2),
      difficulty: Difficulty.medium,
      essential: false,
      domain: CallingDomain.artificer,
    ),
    QuestTemplate(
      title: 'Deep Clean One Room',
      category: 'HOME',
      rule: WeeklyTimesRule(times: 1),
      difficulty: Difficulty.hard,
      essential: false,
      domain: CallingDomain.artificer,
    ),

    // SOCIAL (Bard)
    QuestTemplate(
      title: 'Reach Out to a Friend',
      category: 'SOCIAL',
      rule: WeeklyTimesRule(times: 2),
      difficulty: Difficulty.easy,
      essential: false,
      domain: CallingDomain.bard,
    ),
    QuestTemplate(
      title: 'Family Dinner Without Screens',
      category: 'SOCIAL',
      rule: DailyEveryDayRule(),
      difficulty: Difficulty.medium,
      essential: false,
      domain: CallingDomain.bard,
    ),
  ];

  static List<String> get categories => [
    'ALL',
    'FITNESS',
    'MIND',
    'LEARNING',
    'CRAFT',
    'CREATIVE',
    'RANGER',
    'HOME',
    'SOCIAL',
  ];
}
