import '../model/models.dart';

class CallingTitles {
  static const List<String> _genericTitles = [
    'Recruit',    // L1
    'Squire',     // L2-3
    'Soldier',    // L4-6
    'Veteran',    // L7-10
    'Champion',   // L11-15
    'Warlord',    // L16-20
    'Paragon',    // L21-29
    'Legend',     // L30+
  ];

  static const Map<CallingDomain, List<String>> _titles = {
    CallingDomain.warrior: [
      'Recruit',       // L1
      'Squire',        // L2-3
      'Soldier',       // L4-6
      'Veteran',       // L7-10
      'Champion',      // L11-15
      'Warlord',       // L16-20
      'Paragon',       // L21-29
      'Legendary Warlord', // L30+
    ],
    CallingDomain.sage: [
      'Student',       // L1
      'Scholar',       // L2-3
      'Librarian',     // L4-6
      'Sage',          // L7-10
      'Master Scholar',// L11-15
      'Arch-Scholar',  // L16-20
      'Oracle',        // L21-29
      'Archmage',      // L30+
    ],
    CallingDomain.monk: [
      'Seeker',        // L1
      'Novice',        // L2-3
      'Disciple',      // L4-6
      'Adept',         // L7-10
      'Ascetic',       // L11-15
      'Master Monk',   // L16-20
      'Grandmaster',   // L21-29
      'Enlightened One',// L30+
    ],
    CallingDomain.bard: [
      'Busker',        // L1
      'Minstrel',      // L2-3
      'Skald',         // L4-6
      'Troubadour',    // L7-10
      'Virtuoso',      // L11-15
      'Maestro',       // L16-20
      'Luminary',      // L21-29
      'Arch-Bard',     // L30+
    ],
    CallingDomain.ranger: [
      'Tracker',       // L1
      'Scout',         // L2-3
      'Pathfinder',    // L4-6
      'Wayfarer',      // L7-10
      'Ranger',        // L11-15
      'Master Ranger', // L16-20
      'Warden',        // L21-29
      'Sovereign Ranger',// L30+
    ],
    CallingDomain.artificer: [
      'Tinkerer',      // L1
      'Apprentice',    // L2-3
      'Builder',       // L4-6
      'Artificer',     // L7-10
      'Architect',     // L11-15
      'Grand Artificer',// L16-20
      'Master Craftsman',// L21-29
      'Demiurge',      // L30+
    ],
  };

  static String titleFor({CallingDomain? calling, required int level}) {
    final list = calling != null ? _titles[calling]! : _genericTitles;
    
    int index;
    if (level <= 1) {
      index = 0;
    } else if (level <= 3) {
      index = 1;
    } else if (level <= 6) {
      index = 2;
    } else if (level <= 10) {
      index = 3;
    } else if (level <= 15) {
      index = 4;
    } else if (level <= 20) {
      index = 5;
    } else if (level <= 29) {
      index = 6;
    } else {
      index = 7;
    }

    final baseTitle = list[index];
    if (level > 30) {
      return '$baseTitle ★${level - 30}';
    }
    return baseTitle;
  }
}
