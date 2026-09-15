import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/domain/keeper/classifier.dart';

void main() {
  group('keeperMoodFor — truth table (keeper.md §5)', () {
    test('nothing due -> quiescent, regardless of the rest', () {
      expect(
        keeperMoodFor(anythingDue: false, completionsToday: 0, essentialsDone: false, dayFraction: 0.0),
        KeeperMood.quiescent,
      );
      expect(
        keeperMoodFor(anythingDue: false, completionsToday: 5, essentialsDone: true, dayFraction: 0.9),
        KeeperMood.quiescent,
      );
    });

    test('no completions today -> dormant', () {
      expect(
        keeperMoodFor(anythingDue: true, completionsToday: 0, essentialsDone: true, dayFraction: 0.0),
        KeeperMood.dormant,
      );
      expect(
        keeperMoodFor(anythingDue: true, completionsToday: 0, essentialsDone: false, dayFraction: 1.0),
        KeeperMood.dormant,
      );
    });

    test('essentials done, early in the day -> content', () {
      expect(
        keeperMoodFor(anythingDue: true, completionsToday: 2, essentialsDone: true, dayFraction: 0.3),
        KeeperMood.content,
      );
    });

    test('essentials done, late in the day -> resting', () {
      expect(
        keeperMoodFor(anythingDue: true, completionsToday: 3, essentialsDone: true, dayFraction: 0.9),
        KeeperMood.resting,
      );
    });

    test('essentials pending -> attentive', () {
      expect(
        keeperMoodFor(anythingDue: true, completionsToday: 1, essentialsDone: false, dayFraction: 0.2),
        KeeperMood.attentive,
      );
      expect(
        keeperMoodFor(anythingDue: true, completionsToday: 4, essentialsDone: false, dayFraction: 0.99),
        KeeperMood.attentive,
      );
    });
  });

  group('no-shame proof', () {
    test('exactly five moods exist — no sad branch to reach', () {
      expect(KeeperMood.values, hasLength(5));
    });

    test('no input combination yields anything but the five moods', () {
      final seen = <KeeperMood>{};
      for (final due in [false, true]) {
        for (final completions in [0, 1, 5]) {
          for (final essentials in [false, true]) {
            for (final fraction in [0.0, 0.25, 0.5, 0.75, 0.9, 1.0]) {
              final mood = keeperMoodFor(
                anythingDue: due,
                completionsToday: completions,
                essentialsDone: essentials,
                dayFraction: fraction,
              );
              seen.add(mood);
              expect(KeeperMood.values, contains(mood));
            }
          }
        }
      }
      expect(
        seen,
        hasLength(5),
        reason: 'the image space should cover every mood it declares',
      );
    });
  });
}