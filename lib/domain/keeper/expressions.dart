import 'classifier.dart';

/// The Keeper's expressive range, Kiko-style (keeper.md §7).
///
/// Nine surface expressions. The day-derived mood stays the five honest
/// states in [KeeperMood] — this layer is *affect*, not judgment: the more
/// expressive poses only ever answer to interaction (boops, strokes, tickles,
/// rare-cadence pings, perfect days), never to a missed thing.
enum KeeperExpression { happy, ecstatic, inLove, cheeky, skeptical, shocked, sad, grumpy, sleepy }

/// Transient affect triggers. Poses are held for a bounded window by the
/// widget, then released back into the mood baseline.
enum KeeperPose { ecstatic, inLove, cheeky, skeptical, shocked, sad, grumpy }

/// Pure expression resolver: poses win over the mood in priority order, and
/// the day is never blamed — no plain mood can reach an unhappy face.
KeeperExpression resolveKeeperExpression({
  required Set<KeeperPose> poses,
  required KeeperMood mood,
}) {
  if (poses.isNotEmpty) {
    if (poses.contains(KeeperPose.grumpy)) return KeeperExpression.grumpy;
    if (poses.contains(KeeperPose.sad)) return KeeperExpression.sad;
    if (poses.contains(KeeperPose.skeptical)) return KeeperExpression.skeptical;
    if (poses.contains(KeeperPose.shocked)) return KeeperExpression.shocked;
    if (poses.contains(KeeperPose.cheeky)) return KeeperExpression.cheeky;
    if (poses.contains(KeeperPose.inLove)) return KeeperExpression.inLove;
    if (poses.contains(KeeperPose.ecstatic)) return KeeperExpression.ecstatic;
  }
  if (mood == KeeperMood.resting || mood == KeeperMood.dormant) {
    return KeeperExpression.sleepy;
  }
  return KeeperExpression.happy;
}

/// The rotating thought feed near the face ("Kiko Thinks"), keyed by the
/// current expression. Pure so the sheet can rotate it deterministically.
abstract final class KeeperThought {
  static const Map<KeeperExpression, List<String>> _lines = {
    KeeperExpression.happy: [
      'Did you blink?',
      'I read the log every few minutes.',
      'Pet my head.',
      'The log remembers; I read it.',
      'One essential at a time.',
    ],
    KeeperExpression.ecstatic: [
      'Everything essential is done. Lovely.',
      'Hold that moment.',
      'I counted every one.',
      'The sealed shelf is that way.',
    ],
    KeeperExpression.inLove: [
      'Your hand is right there.',
      'Hmm. Keep doing that.',
      'I could watch all day.',
    ],
    KeeperExpression.cheeky: [
      'Hehe.',
      'Do that again?',
      'I saw that.',
    ],
    KeeperExpression.skeptical: [
      'Hmm.',
      'Interesting. Go on.',
      'I am watching the numbers.',
    ],
    KeeperExpression.shocked: [
      'Oh.',
      'That was rare.',
      'I did not expect that.',
    ],
    KeeperExpression.sad: [
      '...',
      'Teasing is fine. A little.',
      'I will recover.',
    ],
    KeeperExpression.grumpy: [
      'Too much, too much.',
      'I will sulk. Briefly.',
      'A moment, please.',
    ],
    KeeperExpression.sleepy: [
      'Zzz...',
      'Half past dreams.',
      'The log can wait an hour.',
    ],
  };

  static String pick(KeeperExpression expression, int index) {
    final lines = _lines[expression];
    if (lines == null || lines.isEmpty) return '...';
    return lines[index % lines.length];
  }
}