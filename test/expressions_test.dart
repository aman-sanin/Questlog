import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/domain/keeper/classifier.dart';
import 'package:questlog/domain/keeper/expressions.dart';

void main() {
  group('resolveKeeperExpression — affect, never judgment (keeper.md §7)', () {
    const allPoses = KeeperPose.values;
    const moods = KeeperMood.values;

    test('every pose × mood resolves to a valid expression', () {
      for (final mood in moods) {
        for (final pose in allPoses) {
          final expr = resolveKeeperExpression(
            poses: {pose},
            mood: mood,
          );
          expect(KeeperExpression.values, contains(expr));
        }
      }
    });

    test('no plain mood can reach an unhappy face (no-shame by construction)',
        () {
      for (final mood in moods) {
        final expr = resolveKeeperExpression(poses: const {}, mood: mood);
        expect(expr, isNot(KeeperExpression.sad));
        expect(expr, isNot(KeeperExpression.grumpy));
      }
    });

    test('posed sadness and grumpiness are only reachable via a pose', () {
      expect(
        resolveKeeperExpression(poses: {KeeperPose.sad}, mood: KeeperMood.attentive),
        KeeperExpression.sad,
      );
      expect(
        resolveKeeperExpression(poses: {KeeperPose.grumpy}, mood: KeeperMood.content),
        KeeperExpression.grumpy,
      );
    });

    test('poses win over the resting/dormant baseline', () {
      expect(
        resolveKeeperExpression(poses: {KeeperPose.inLove}, mood: KeeperMood.resting),
        KeeperExpression.inLove,
      );
      expect(
        resolveKeeperExpression(poses: {KeeperPose.shocked}, mood: KeeperMood.dormant),
        KeeperExpression.shocked,
      );
    });

    test('resting and dormant without a pose sleep', () {
      expect(
        resolveKeeperExpression(poses: const {}, mood: KeeperMood.resting),
        KeeperExpression.sleepy,
      );
      expect(
        resolveKeeperExpression(poses: const {}, mood: KeeperMood.dormant),
        KeeperExpression.sleepy,
      );
    });

    test('occupied moods rest happy', () {
      for (final mood in [KeeperMood.attentive, KeeperMood.content, KeeperMood.quiescent]) {
        expect(
          resolveKeeperExpression(poses: const {}, mood: mood),
          KeeperExpression.happy,
        );
      }
    });

    test('all nine expressions are reachable', () {
      final expr = <KeeperExpression>{};
      for (final p in allPoses) {
        expr.add(resolveKeeperExpression(poses: {p}, mood: KeeperMood.content));
      }
      expr.add(resolveKeeperExpression(poses: const {}, mood: KeeperMood.attentive));
      expr.add(resolveKeeperExpression(poses: const {}, mood: KeeperMood.dormant));
      expect(expr, containsAll(KeeperExpression.values));
      expect(expr, hasLength(KeeperExpression.values.length));
    });

    test('pose priority: defensive before warm', () {
      expect(
        resolveKeeperExpression(
          poses: {KeeperPose.sad, KeeperPose.cheeky, KeeperPose.inLove},
          mood: KeeperMood.content,
        ),
        KeeperExpression.sad,
      );
      expect(
        resolveKeeperExpression(
          poses: {KeeperPose.grumpy, KeeperPose.skeptical, KeeperPose.ecstatic},
          mood: KeeperMood.content,
        ),
        KeeperExpression.grumpy,
      );
      expect(
        resolveKeeperExpression(
          poses: {KeeperPose.sad, KeeperPose.grumpy},
          mood: KeeperMood.content,
        ),
        KeeperExpression.grumpy,
      );
    });
  });

  group('KeeperThought — rotating feed (keeper.md §7)', () {
    test('every expression has a line for every index', () {
      for (final e in KeeperExpression.values) {
        for (var i = 0; i < 8; i++) {
          final line = KeeperThought.pick(e, i);
          expect(line, isNotEmpty);
        }
      }
    });

    test('index rotation is deterministic and repeats', () {
      expect(KeeperThought.pick(KeeperExpression.happy, 0),
          KeeperThought.pick(KeeperExpression.happy, 0));
      expect(
        KeeperThought.pick(KeeperExpression.happy, 0),
        KeeperThought.pick(KeeperExpression.happy, 5),
      );
    });
  });
}