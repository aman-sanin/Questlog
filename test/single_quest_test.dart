import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app/providers/profile_provider.dart';
import 'package:questlog/app/providers/today_provider.dart';
import 'package:questlog/domain/constants/xp_constants.dart';
import 'package:questlog/domain/engine/quest_state.dart';
import 'package:questlog/domain/engine/schedule_rule.dart';
import 'package:questlog/domain/engine/streak.dart';
import 'package:questlog/domain/model/models.dart';
import 'package:questlog/ui/sheets/quest_editor_sheet.dart';
import 'package:questlog/ui/theme/app_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

void main() {
  group('Single / One-Off Quests Suite', () {
    test('SingleRule serialization round-trip', () {
      final ruleWithDate = SingleRule(targetDate: LocalDate(2026, 9, 15));
      final jsonWithDate = ruleWithDate.toJson();
      expect(jsonWithDate['cadence'], equals('single'));
      expect(jsonWithDate['target_date'], equals('2026-09-15'));

      final deserializedWithDate = ScheduleRule.fromJson(jsonWithDate) as SingleRule;
      expect(deserializedWithDate.targetDate, equals(LocalDate(2026, 9, 15)));

      const ruleNoDate = SingleRule();
      final jsonNoDate = ruleNoDate.toJson();
      expect(jsonNoDate['cadence'], equals('single'));
      expect(jsonNoDate.containsKey('target_date'), isFalse);

      final deserializedNoDate = ScheduleRule.fromJson(jsonNoDate) as SingleRule;
      expect(deserializedNoDate.targetDate, isNull);
    });

    test('SingleRule XP payout is base 15', () {
      expect(XpConstants.baseForCadence(Cadence.single), equals(15));
    });

    test('SingleRule streak calculation is always 0', () {
      final result = StreakEngine.calculate(
        rule: const SingleRule(),
        targetValue: 1,
        completionValues: {LocalDate(2026, 9, 1): 1},
        existingRepairs: {},
        today: LocalDate(2026, 9, 1),
        weekStart: WeekStart.monday,
        firstCompletionDate: LocalDate(2026, 9, 1),
      );
      expect(result.streak, equals(0));
      expect(result.bestStreak, equals(0));
    });

    test('QuestEvaluation: Uncompleted single quest without due date is due today', () {
      final eval = QuestEvaluation.evaluate(
        questId: 'q_single_1',
        title: 'Fix bike tire',
        rule: const SingleRule(),
        targetType: TargetType.checkbox,
        targetValue: 1,
        difficulty: Difficulty.medium,
        essential: false,
        completionDates: [],
        completionValues: {},
        today: LocalDate(2026, 9, 1),
        now: DateTime(2026, 9, 1, 10, 0),
        weekStart: WeekStart.monday,
        streak: 0,
      );

      expect(eval.isDueToday, isTrue);
      expect(eval.isCompleted, isFalse);
      expect(eval.metaDescription, contains('SINGLE'));
    });

    test('QuestEvaluation: Single quest with future due date is NOT due today', () {
      final eval = QuestEvaluation.evaluate(
        questId: 'q_single_future',
        title: 'File taxes',
        rule: SingleRule(targetDate: LocalDate(2026, 9, 15)),
        targetType: TargetType.checkbox,
        targetValue: 1,
        difficulty: Difficulty.hard,
        essential: true,
        completionDates: [],
        completionValues: {},
        today: LocalDate(2026, 9, 1),
        now: DateTime(2026, 9, 1, 10, 0),
        weekStart: WeekStart.monday,
        streak: 0,
      );

      expect(eval.isDueToday, isFalse);
      expect(eval.isCompleted, isFalse);
    });

    test('QuestEvaluation: Single quest completed today shows completed', () {
      final today = LocalDate(2026, 9, 1);
      final eval = QuestEvaluation.evaluate(
        questId: 'q_single_done',
        title: 'Send invoice',
        rule: SingleRule(targetDate: today),
        targetType: TargetType.checkbox,
        targetValue: 1,
        difficulty: Difficulty.easy,
        essential: false,
        completionDates: [today],
        completionValues: {today: 1},
        today: today,
        now: DateTime(2026, 9, 1, 12, 0),
        weekStart: WeekStart.monday,
        streak: 0,
      );

      expect(eval.isDueToday, isTrue);
      expect(eval.isCompleted, isTrue);
      expect(eval.visualState, equals(QuestVisual.completed));
    });

    test('QuestEvaluation: Single quest completed yesterday is NOT due today', () {
      final yesterday = LocalDate(2026, 8, 31);
      final today = LocalDate(2026, 9, 1);
      final eval = QuestEvaluation.evaluate(
        questId: 'q_single_past_done',
        title: 'Send invoice',
        rule: SingleRule(targetDate: yesterday),
        targetType: TargetType.checkbox,
        targetValue: 1,
        difficulty: Difficulty.easy,
        essential: false,
        completionDates: [yesterday],
        completionValues: {yesterday: 1},
        today: today,
        now: DateTime(2026, 9, 1, 12, 0),
        weekStart: WeekStart.monday,
        streak: 0,
      );

      expect(eval.isDueToday, isFalse);
      expect(eval.isCompleted, isTrue);
    });
  });

  group('QuestEditorSheet Single Quest Widget Test', () {
    testWidgets('Can select Single cadence and due date options in QuestEditorSheet', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeGoalsStreamProvider.overrideWith((ref) => Stream.value([])),
            effectiveLocalDateProvider.overrideWithValue(LocalDate(2026, 9, 1)),
            weekStartProvider.overrideWithValue(WeekStart.monday),
          ],
          child: MaterialApp(
            theme: AppTheme.buildTheme(isDark: true, accentTheme: AccentTheme.frost),
            home: const Scaffold(
              body: QuestEditorSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find 'SINGLE' cadence segment
      final singleCadenceItem = find.text('SINGLE');
      expect(singleCadenceItem, findsOneWidget);

      // Tap 'SINGLE' cadence
      await tester.tap(singleCadenceItem);
      await tester.pumpAndSettle();

      // Verify Single sub-rule panel appears
      expect(find.text('DUE DATE'), findsOneWidget);
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('TOMORROW'), findsOneWidget);
      expect(find.text('NO DUE DATE'), findsOneWidget);
    });
  });
}
