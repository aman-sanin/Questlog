import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/database.dart';
import '../../domain/constants/unlock_schedule.dart';
import '../../domain/engine/badges.dart';
import '../../domain/engine/progression.dart';
import '../../domain/model/models.dart';
import 'database_provider.dart';
import 'profile_provider.dart';

class ProfileScreenState {
  final ProfileData profile;
  final ProgressionStatus progression;
  final List<BadgeStatus> badges;
  final List<UnlockItem> unlockItems;

  const ProfileScreenState({
    required this.profile,
    required this.progression,
    required this.badges,
    required this.unlockItems,
  });
}

final totalXpStreamProvider = StreamProvider<int>((ref) {
  return ref.watch(ledgerDaoProvider).watchTotalXp();
});

final profileViewStateProvider = Provider<AsyncValue<ProfileScreenState>>((ref) {
  final profileAsync = ref.watch(profileStreamProvider);
  final totalXpAsync = ref.watch(totalXpStreamProvider);
  final seenMomentsAsync = ref.watch(ledgerDaoProvider).watchSeenMoments();

  if (profileAsync is AsyncLoading || totalXpAsync is AsyncLoading) {
    return const AsyncLoading();
  }

  if (profileAsync.hasError) return AsyncError(profileAsync.error!, profileAsync.stackTrace!);
  if (totalXpAsync.hasError) return AsyncError(totalXpAsync.error!, totalXpAsync.stackTrace!);

  final profile = profileAsync.value!;
  final totalXp = totalXpAsync.value ?? 0;
  final chosenCalling = profile.calling != null ? CallingDomain.values[profile.calling!] : null;

  final progression = ProgressionEngine.calculate(
    totalXp: totalXp,
    chosenCalling: chosenCalling,
  );

  final badges = BadgeEngine.evaluate(
    totalCompletions: totalXp ~/ 15,
    maxStreak: 23,
    perfectDaysCount: 12,
    domainsWithCompletions: CallingDomain.values.toSet(),
    completedGoalsCount: 1,
    earnedBadgeKeys: {'first_step', 'streak_7', 'streak_30', 'centurion'},
  );

  return AsyncData(ProfileScreenState(
    profile: profile,
    progression: progression,
    badges: badges,
    unlockItems: UnlockSchedule.items,
  ));
});
