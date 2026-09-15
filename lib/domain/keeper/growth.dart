import '../../data/db/database.dart';
import '../model/models.dart';
import 'tunables.dart';

/// The Keeper's growth stages (keeper.md §8). Purely a function of derived
/// facts — perfect days witnessed and the player's level — so respec (calling
/// change) can never touch it: _the witness changes robes, never self._
enum KeeperStage { summoned, waking, adorned, trimmed, gilded }

/// Maps a lifetime perfect-day count to a stage. Thresholds from
/// [KeeperTunables]. `gilded` additionally requires [level] >= 30.
KeeperStage keeperStageFor({required int perfectDays, required int level}) {
  final KeeperStage byDays;
  if (perfectDays >= KeeperTunables.growthTrimmed) {
    byDays = KeeperStage.trimmed;
  } else if (perfectDays >= KeeperTunables.growthAdorned) {
    byDays = KeeperStage.adorned;
  } else if (perfectDays >= KeeperTunables.growthWaking) {
    byDays = KeeperStage.waking;
  } else {
    byDays = KeeperStage.summoned;
  }
  if (level >= KeeperTunables.gildLevel) return KeeperStage.gilded;
  return byDays;
}

/// Which stage the progression bar next reaches (for the Growth track).
KeeperStage? nextStageAfter(KeeperStage stage) {
  final order = KeeperStage.values;
  final idx = order.indexOf(stage);
  if (idx + 1 >= order.length) return null;
  return order[idx + 1];
}

/// Perfect days witnessed: every date where every essential quest scheduled
/// that day was met. Pure — used by growth and the Keeper sheet. Duplicates
/// the badge-time definition so the Keeper never depends on badge state.
Set<LocalDate> derivePerfectDays({
  required Iterable<QuestData> essentialQuests,
  required Map<String, Map<LocalDate, int>> completionsByQuest,
  required WeekStart weekStart,
}) {
  final perfect = <LocalDate>{};
  final essentials = essentialQuests.toList();
  if (essentials.isEmpty) return perfect;

  final allDates = <LocalDate>{
    for (final perQuest in completionsByQuest.values)
      ...perQuest.keys,
  };

  for (final d in allDates) {
    int due = 0;
    int done = 0;
    for (final e in essentials) {
      final created = LocalDate.fromDateTime(e.createdAt);
      if (d < created) continue;
      if (e.rule.isScheduledOn(d, weekStart.value)) {
        due++;
        final value = completionsByQuest[e.id]?[d] ?? 0;
        if (value >= e.targetValue) done++;
      }
    }
    if (due > 0 && due == done) perfect.add(d);
  }
  return perfect;
}