import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/constants/unlock_schedule.dart';

abstract class CeremonyEvent {
  const CeremonyEvent();
}

class LevelUpCeremonyEvent extends CeremonyEvent {
  final int newLevel;
  final String title;
  final List<UnlockItem> unlocks;

  const LevelUpCeremonyEvent({
    required this.newLevel,
    required this.title,
    required this.unlocks,
  });
}

class CallingChoiceCeremonyEvent extends CeremonyEvent {
  const CallingChoiceCeremonyEvent();
}

class GoalCompletionCeremonyEvent extends CeremonyEvent {
  final String goalTitle;
  final int xpEarned;

  const GoalCompletionCeremonyEvent({
    required this.goalTitle,
    required this.xpEarned,
  });
}

final activeCeremonyProvider = StateProvider<CeremonyEvent?>((ref) => null);
