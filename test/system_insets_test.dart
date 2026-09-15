import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:questlog/app/providers/keeper_provider.dart';
import 'package:questlog/app/providers/profile_provider.dart';
import 'package:questlog/domain/keeper/classifier.dart';
import 'package:questlog/domain/keeper/growth.dart';
import 'package:questlog/domain/model/models.dart';
import 'package:questlog/ui/root_scaffold.dart';
import 'package:questlog/ui/sheets/keeper_sheet.dart';
import 'package:questlog/ui/theme/app_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

/// System-inset guards (keeper.md §10 / root shell): the Keeper sheet must
/// stop below the status bar and never reach the notification bar, and the
/// root nav bar must clear the bottom system inset (3-button nav = 48px,
/// gesture pill = 24px). Insets are injected via the test view so they flow
/// through MaterialApp's own MediaQuery.
GoRouter _rootRouter() => GoRouter(
      initialLocation: '/today',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return RootScaffold(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/today', builder: (_, __) => const SizedBox.expand()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/insights', builder: (_, __) => const SizedBox.expand()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/profile', builder: (_, __) => const SizedBox.expand()),
              ],
            ),
          ],
        ),
      ],
    );

const _ui = KeeperUiState(
  mood: KeeperMood.content,
  anticipation: false,
  stage: KeeperStage.adorned,
  calling: CallingDomain.warrior,
  perfectDays: 30,
  level: 15,
);

const _journal = KeeperJournal(
  daysKeptCompany: 30,
  perfectDays: 30,
  goalsSeenCompleted: 5,
  favoriteQuest: 'Write',
);

void main() {
  ThemeData theme() => AppTheme.buildTheme(
        isDark: true,
        accentTheme: AccentTheme.frost,
      );

  group('system insets', () {
    testWidgets('the root nav bar clears the bottom inset (3-button nav)', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(400, 800);
      tester.view.padding =
          const FakeViewPadding(left: 0, top: 56, right: 0, bottom: 48);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            soundEnabledProvider.overrideWith((ref) => Stream.value(true)),
          ],
          child: MaterialApp.router(theme: theme(), routerConfig: _rootRouter()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      final bar = find.byKey(const ValueKey('root-bottom-nav'));
      expect(bar, findsOneWidget);
      // SafeArea(top:false) pads the 64dp bar up by the inset.
      expect(
        tester.getBottomLeft(bar).dy,
        closeTo(800 - 48, 0.5),
        reason: 'the nav bar must not sit behind the nav buttons',
      );
      expect(
        tester.getTopLeft(bar).dy,
        closeTo(800 - 48 - 64, 0.5),
        reason: 'the bar keeps its 64dp height',
      );

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the root nav bar is unchanged when the inset is zero', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(400, 800);
      tester.view.padding = FakeViewPadding.zero;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            soundEnabledProvider.overrideWith((ref) => Stream.value(true)),
          ],
          child: MaterialApp.router(theme: theme(), routerConfig: _rootRouter()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      final bar = find.byKey(const ValueKey('root-bottom-nav'));
      expect(
        tester.getBottomLeft(bar).dy,
        closeTo(800, 0.5),
        reason: 'zero inset must not move the bar',
      );

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the Keeper sheet clears the status bar and the nav buttons', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(400, 800);
      tester.view.padding =
          const FakeViewPadding(left: 0, top: 56, right: 0, bottom: 48);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            keeperUiStateProvider.overrideWithValue(_ui),
            keeperJournalProvider.overrideWithValue(_journal),
          ],
          child: MaterialApp(
            theme: theme(),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => KeeperSheet.show(context),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      final panel = find.byKey(const ValueKey('keeper-sheet-panel'));
      expect(panel, findsOneWidget);

      // A tall panel (bubble + face + journal + growth rows) must stop below
      // the status bar instead of reaching the notification bar.
      expect(
        tester.getTopLeft(panel).dy,
        greaterThanOrEqualTo(56),
        reason: 'the sheet must not slide under the notification bar',
      );

      // Content clears the system bottom inset (nav buttons), not just the
      // keyboard inset.
      final scroll = find.descendant(
        of: panel,
        matching: find.byType(SingleChildScrollView),
      );
      expect(
        tester.getBottomRight(scroll).dy,
        lessThanOrEqualTo(800 - 48 + 0.5),
        reason: 'the sheet content must not sit behind the nav buttons',
      );

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the Keeper sheet keeps its layout when insets are zero', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(400, 800);
      tester.view.padding = FakeViewPadding.zero;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            keeperUiStateProvider.overrideWithValue(_ui),
            keeperJournalProvider.overrideWithValue(_journal),
          ],
          child: MaterialApp(
            theme: theme(),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => KeeperSheet.show(context),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      final panel = find.byKey(const ValueKey('keeper-sheet-panel'));
      expect(panel, findsOneWidget);
      expect(
        tester.getBottomLeft(panel).dy,
        closeTo(800, 0.5),
        reason: 'a zero inset sheet stays flush to the screen bottom',
      );

      await tester.pumpWidget(const SizedBox());
    });
  });
}