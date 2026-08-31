enum UnlockType {
  calling,
  accent,
  widgetStyle,
  launcherIcon,
  celebrationStyle,
  crestFlair,
}

class UnlockItem {
  final int level;
  final String key;
  final String title;
  final String description;
  final UnlockType type;
  final String? assetRef;

  const UnlockItem({
    required this.level,
    required this.key,
    required this.title,
    required this.description,
    required this.type,
    this.assetRef,
  });
}

class UnlockSchedule {
  static const List<UnlockItem> items = [
    UnlockItem(
      level: 2,
      key: 'calling',
      title: 'Choose Your Calling',
      description: 'Shapes your title ladder and crest sigil.',
      type: UnlockType.calling,
    ),
    UnlockItem(
      level: 3,
      key: 'sage_accent',
      title: 'Sage Accent',
      description: 'Calm earthy green palette for the motion accent.',
      type: UnlockType.accent,
      assetRef: 'sage',
    ),
    UnlockItem(
      level: 4,
      key: 'widget_style_2',
      title: 'Widget Style II',
      description: 'Ring and metric home-screen widget variants.',
      type: UnlockType.widgetStyle,
    ),
    UnlockItem(
      level: 5,
      key: 'ice_accent',
      title: 'Ice Accent',
      description: 'Crisp pale cyan palette for the motion accent.',
      type: UnlockType.accent,
      assetRef: 'ice',
    ),
    UnlockItem(
      level: 7,
      key: 'crest_launcher',
      title: 'Crest Launcher Icon',
      description: 'Custom home-screen app icon reflecting your calling crest.',
      type: UnlockType.launcherIcon,
    ),
    UnlockItem(
      level: 9,
      key: 'celebration_2',
      title: 'Celebration Style II',
      description: 'Extended geometric 12-lobe ceremony animation.',
      type: UnlockType.celebrationStyle,
    ),
    UnlockItem(
      level: 10,
      key: 'crest_flair',
      title: 'Crest Flair',
      description: 'Ember-stroked geometric flourishes around your calling crest.',
      type: UnlockType.crestFlair,
    ),
    UnlockItem(
      level: 13,
      key: 'copper_accent',
      title: 'Copper Accent',
      description: 'Warm metallic copper palette for the motion accent.',
      type: UnlockType.accent,
      assetRef: 'copper',
    ),
    UnlockItem(
      level: 16,
      key: 'ember_accent',
      title: 'Ember Accent',
      description: 'Prestige arrival gold palette for the motion accent.',
      type: UnlockType.accent,
      assetRef: 'ember',
    ),
  ];

  static List<UnlockItem> unlocksForLevel(int level) {
    return items.where((item) => item.level == level).toList();
  }

  static UnlockItem? nextUnlock(int currentLevel) {
    for (final item in items) {
      if (item.level > currentLevel) return item;
    }
    return null;
  }
}
