import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app/providers/insights_provider.dart';
import 'package:questlog/app/providers/profile_provider.dart';
import 'package:questlog/app/providers/recap_provider.dart';
import 'package:questlog/app/providers/today_provider.dart';
import 'package:questlog/data/db/database.dart';
import 'package:questlog/domain/engine/insights.dart';
import 'package:questlog/domain/engine/schedule_rule.dart';
import 'package:questlog/domain/model/models.dart';
import 'package:questlog/ui/screens/insights_screen.dart';
import 'package:questlog/ui/screens/recap_screen.dart';
import 'package:questlog/ui/theme/app_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

const _monday = WeekStart.monday;

/// June 2026 recap fixture (Jun 1 = Monday, 30 days; May = prev, 31 days).
/// q1: daily essential, done every June day but the 5th; May misses 5 days.
/// q2: weekly 1x (window), done Jun 1/8/15/22/29 and May 4/11/18/25.
Map<String, Map<LocalDate, int>> _completions() {
  final map = <String, Map<LocalDate, int>>{};
  for (var d = 1; d <= 30; d++) {
    if (d == 5) continue;
    map.putIfAbsent('q1', () => {})[LocalDate(2026, 6, d)] = 1;
  }
  for (final d in [1, 8, 15, 22, 29]) {
    map.putIfAbsent('q2', () => {})[LocalDate(2026, 6, d)] = 1;
  }
  for (var d = 1; d <= 31; d++) {
    if ({1, 8, 15, 22, 29}.contains(d)) continue;
    map.putIfAbsent('q1', () => {})[LocalDate(2026, 5, d)] = 1;
  }
  for (final d in [4, 11, 18, 25]) {
    map.putIfAbsent('q2', () => {})[LocalDate(2026, 5, d)] = 1;
  }
  return map;
}

List<QuestData> _quests() => [
      QuestData(
        id: 'q1',
        title: 'Daily',
        rule: const DailyEveryDayRule(),
        targetType: 0,
        targetValue: 1,
        difficulty: 1,
        essential: true,
        domain: CallingDomain.warrior.index,
        createdAt: DateTime(2026, 5, 1),
      ),
      QuestData(
        id: 'q2',
        title: 'Weekly',
        rule: const WeeklyRule.times(1),
        targetType: 0,
        targetValue: 1,
        difficulty: 1,
        essential: false,
        domain: CallingDomain.sage.index,
        createdAt: DateTime(2026, 5, 1),
      ),
    ];

MonthlyRecapData _recap() => InsightsEngine.buildMonthlyRecap(
      month: LocalDate(2026, 6, 1),
      prevMonth: LocalDate(2026, 5, 1),
      quests: _quests(),
      completionsByQuest: _completions(),
      monthXpEvents: [
        XpEventData(
          id: 'x1',
          type: 0,
          ref: 'c',
          periodRef: null,
          amount: 100,
          localDate: '2026-06-10',
          createdAt: DateTime(2026, 6, 10, 10, 0),
        ),
        XpEventData(
          id: 'x2',
          type: 2,
          ref: 'perfect_week:2026-06-01',
          periodRef: null,
          amount: 50,
          localDate: '2026-06-07',
          createdAt: DateTime(2026, 6, 8, 0, 0),
        ),
      ],
      monthRepairs: [
        StreakRepairData(
          id: 'r1',
          questId: 'q1',
          periodKey: '2026-06-05',
          appliedAt: DateTime(2026, 6, 6, 10, 0),
        ),
      ],
      repairsByQuest: const {},
      perfectDaysInMonth: {
        LocalDate(2026, 6, 1),
        LocalDate(2026, 6, 2),
      },
      weekStart: _monday,
      today: LocalDate(2026, 7, 5),
    );

void main() {
  group('buildMonthlyRecap', () {
    test('completion rate uses scheduled day-unit math', () {
      final recap = _recap();
      // June: q1 29/30 + q2 5/30 (window-due every day) = 34/60.
      expect(recap.completionRate, closeTo(34 / 60, 1e-9));
      // May: q1 26/31 + q2 4/31 = 30/62; trend is the difference.
      expect(
        recap.completionTrendVsLastMonth,
        closeTo(34 / 60 - 30 / 62, 1e-9),
      );
    });

    test('xp, perfect days, freezes, totals', () {
      final recap = _recap();
      expect(recap.totalXpEarned, equals(150));
      expect(recap.perfectDaysCount, equals(2));
      expect(recap.freezesSavedCount, equals(1));
      expect(recap.totalCompletions, equals(29 + 5));
      // q1 all June days but the 5th; q2's days are a subset of those.
      expect(recap.activeDays, equals(29));
      expect(recap.year, equals(2026));
      expect(recap.month, equals(6));
    });

    test('domain affinity, busiest domain, quest of the month', () {
      final recap = _recap();
      expect(
        recap.domainAffinity[CallingDomain.warrior],
        closeTo(29 / 34, 1e-9),
      );
      expect(
        recap.domainAffinity[CallingDomain.sage],
        closeTo(5 / 34, 1e-9),
      );
      expect(recap.busiestDomain, equals(CallingDomain.warrior));
      expect(recap.mostCompletedQuestTitle, equals('Daily'));
      expect(recap.mostCompletedQuestCount, equals(29));
    });

    test('best streak is the historical max, not the current run', () {
      // q1's current run is dead (nothing logged in July) but the
      // Jun 6-30 run of 25 survives via the bestStreak fix.
      expect(_recap().bestStreak, equals(25));
    });

    test('empty month reports zeros, never NaN', () {
      final recap = InsightsEngine.buildMonthlyRecap(
        month: LocalDate(2026, 6, 1),
        prevMonth: LocalDate(2026, 5, 1),
        quests: const [],
        completionsByQuest: const {},
        monthXpEvents: const [],
        monthRepairs: const [],
        repairsByQuest: const {},
        perfectDaysInMonth: const {},
        weekStart: _monday,
        today: LocalDate(2026, 7, 5),
      );
      expect(recap.completionRate, equals(0.0));
      expect(recap.completionTrendVsLastMonth, equals(0.0));
      expect(recap.totalXpEarned, equals(0));
      expect(recap.busiestDomain, isNull);
      expect(recap.mostCompletedQuestTitle, isNull);
      expect(recap.bestStreak, equals(0));
      expect(recap.domainAffinity, isEmpty);
    });
  });

  group('MonthlyRecapScreen', () {
    const fixture = MonthlyRecapData(
      year: 2026,
      month: 6,
      completionRate: 34 / 60,
      totalXpEarned: 150,
      perfectDaysCount: 2,
      freezesSavedCount: 1,
      domainAffinity: {
        CallingDomain.warrior: 29 / 34,
        CallingDomain.sage: 5 / 34,
      },
      bestStreak: 25,
      totalCompletions: 34,
      completionTrendVsLastMonth: 34 / 60 - 30 / 62,
      busiestDomain: CallingDomain.warrior,
      mostCompletedQuestTitle: 'Daily',
      mostCompletedQuestCount: 29,
      activeDays: 29,
    );

    Future<void> pumpRecap(WidgetTester tester) {
      return tester.pumpWidget(
        ProviderScope(
          overrides: [
            monthlyRecapProvider.overrideWithValue(const AsyncData(fixture)),
          ],
          child: MaterialApp(
            theme: AppTheme.buildTheme(isDark: true, accentTheme: AccentTheme.frost),
            home: const MonthlyRecapScreen(),
          ),
        ),
      );
    }

    testWidgets('renders computed values, never the October mock', (tester) async {
      await pumpRecap(tester);
      await tester.pump(); // BurstWidget animates: no settle

      expect(find.text('JUNE 2026 RECAP'), findsOneWidget);
      expect(find.text('JUNE 2026'), findsOneWidget);
      expect(find.text('57%'), findsOneWidget);
      expect(find.text('+150'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('+8.3 PTS'), findsOneWidget);
      expect(find.text('WARRIOR 85%'), findsOneWidget);
      expect(find.text('SAGE 15%'), findsOneWidget);
      expect(find.text('QUEST OF THE MONTH'), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('SHARE RECAP MANUSCRIPT'), findsOneWidget);

      expect(find.text('OCTOBER RECAP'), findsNothing);
      expect(find.text('THE UNBROKEN SCROLL'), findsNothing);
      expect(find.text('92%'), findsNothing);
    });
  });

  group('recap teaser gating', () {
    InsightsScreenState state(bool recap) => InsightsScreenState(
          selectedMonth: LocalDate(2026, 7, 1),
          heatmapDays: const [],
          yearHeatmapDays: const [],
          streakLeaderboard: const [],
          weeklyInsight: const WeeklyInsightData(
            headline: 'H',
            stat: 'S',
            detail: 'D',
          ),
          hasMonthlyRecap: recap,
        );

    Future<void> pumpInsights(WidgetTester tester, bool recap) {
      return tester.pumpWidget(
        ProviderScope(
          overrides: [
            insightsStateProvider.overrideWithValue(AsyncData(state(recap))),
            freezeWalletProvider.overrideWithValue(const AsyncData(0)),
            effectiveLocalDateProvider.overrideWithValue(LocalDate(2026, 7, 5)),
            weekStartProvider.overrideWithValue(WeekStart.monday),
          ],
          child: MaterialApp(
            theme: AppTheme.buildTheme(isDark: true, accentTheme: AccentTheme.frost),
            home: const InsightsScreen(),
          ),
        ),
      );
    }

    testWidgets('teaser shows in the first week only', (tester) async {
      await pumpInsights(tester, true);
      await tester.pumpAndSettle();
      expect(find.text('MONTHLY RECAP AVAILABLE'), findsOneWidget);
    });

    testWidgets('teaser hidden after the first week', (tester) async {
      await pumpInsights(tester, false);
      await tester.pumpAndSettle();
      expect(find.text('MONTHLY RECAP AVAILABLE'), findsNothing);
    });
  });
}
