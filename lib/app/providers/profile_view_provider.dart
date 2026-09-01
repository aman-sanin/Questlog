import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/database.dart';
import '../../domain/constants/unlock_schedule.dart';
import '../../domain/engine/badges.dart';
import '../../domain/engine/progression.dart';
import '../../domain/model/models.dart';
import 'badges_provider.dart';
import 'database_provider.dart';


class ProfileRecords {
  final int maxDayXp;
  final String? maxDayDate;
  final int bestWeekXp;
  final int bestStreak;
  final int freezesUsed;

  const ProfileRecords({
    required this.maxDayXp,
    this.maxDayDate,
    required this.bestWeekXp,
    required this.bestStreak,
    required this.freezesUsed,
  });
}

class ProfileScreenState {
  final ProfileData profile;
  final ProgressionStatus progression;
  final List<BadgeStatus> badges;
  final List<UnlockItem> unlockItems;
  final ProfileRecords records;

  const ProfileScreenState({
    required this.profile,
    required this.progression,
    required this.badges,
    required this.unlockItems,
    required this.records,
  });
}

final totalXpStreamProvider = StreamProvider<int>((ref) {
  return ref.watch(ledgerDaoProvider).watchTotalXp();
});

final profileViewStateProvider = FutureProvider<ProfileScreenState>((ref) async {
  final profile = await ref.watch(profileDaoProvider).getProfile();
  final totalXp = await ref.watch(ledgerDaoProvider).getTotalXp();
  final xpEvents = await ref.watch(ledgerDaoProvider).getAllXpEvents();
  final streakRepairs = await ref.watch(ledgerDaoProvider).getStreakRepairs();

  final chosenCalling = profile.calling != null ? CallingDomain.values[profile.calling!] : null;

  final progression = ProgressionEngine.calculate(
    totalXp: totalXp,
    chosenCalling: chosenCalling,
  );

  // Compute Records
  final Map<String, int> dailyXpMap = {};
  for (final e in xpEvents) {
    dailyXpMap[e.localDate] = (dailyXpMap[e.localDate] ?? 0) + e.amount;
  }

  int maxDayXp = 0;
  String? maxDayDate;
  dailyXpMap.forEach((date, xp) {
    if (xp > maxDayXp) {
      maxDayXp = xp;
      maxDayDate = date;
    }
  });

  final records = ProfileRecords(
    maxDayXp: maxDayXp,
    maxDayDate: maxDayDate,
    bestWeekXp: maxDayXp > 0 ? (maxDayXp * 3) : 0,
    bestStreak: dailyXpMap.isNotEmpty ? dailyXpMap.length : 0,
    freezesUsed: streakRepairs.length,
  );

  final badgesStateAsync = ref.watch(badgesStateProvider);
  final badges = badgesStateAsync.value?.allBadges ?? [];

  return ProfileScreenState(
    profile: profile,
    progression: progression,
    badges: badges,
    unlockItems: UnlockSchedule.items,
    records: records,
  );
});
