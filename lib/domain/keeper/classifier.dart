/// The Keeper's mood states. Exactly five — the signature cannot express
/// disappointment. Downswings map through [quiescent]/[dormant], never sorrow.
enum KeeperMood { quiescent, dormant, attentive, content, resting }

/// Pure mood classifier. Mirrors presence, never absence: the five moods are
/// the entire image space, so a "sad" branch is unreachable by construction.
KeeperMood keeperMoodFor({
  required bool anythingDue,
  required int completionsToday,
  required bool essentialsDone,
  required double dayFraction,
}) {
  // Nothing scheduled today → settled rest, chin up, still warm (keeper.md §5).
  if (!anythingDue) return KeeperMood.quiescent;
  if (completionsToday == 0) return KeeperMood.dormant;
  if (essentialsDone) {
    return dayFraction > 0.75 ? KeeperMood.resting : KeeperMood.content;
  }
  return KeeperMood.attentive;
}