import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/providers/database_provider.dart';
import '../app/providers/today_provider.dart';
import 'root_scaffold.dart';
import 'screens/badges_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/path_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/recap_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/today_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _todayNavigatorKey = GlobalKey<NavigatorState>();
final _insightsNavigatorKey = GlobalKey<NavigatorState>();
final _profileNavigatorKey = GlobalKey<NavigatorState>();

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool _initialized = false;
  bool _hasCompletedOnboarding = true;

  RouterNotifier(this._ref) {
    _init();
  }

  Future<void> _init() async {
    final seen = await _ref.read(ledgerDaoProvider).getSeenMoments();
    final quests = await _ref.read(questsDaoProvider).getAllQuests();
    _hasCompletedOnboarding = seen.contains('onboarding') || quests.isNotEmpty;
    _initialized = true;
    notifyListeners();

    _ref.listen(seenMomentsStreamProvider, (prev, next) {
      if (next.hasValue) {
        final hasOnboarded = next.value!.contains('onboarding');
        if (hasOnboarded != _hasCompletedOnboarding) {
          _hasCompletedOnboarding = hasOnboarded;
          notifyListeners();
        }
      }
    });

    _ref.listen(activeQuestsStreamProvider, (prev, next) {
      if (next.hasValue && next.value!.isNotEmpty && !_hasCompletedOnboarding) {
        _hasCompletedOnboarding = true;
        notifyListeners();
      }
    });
  }

  String? redirect(BuildContext context, GoRouterState state) {
    if (!_initialized) return null;
    final isOnboarding = state.matchedLocation == '/onboarding';
    if (!_hasCompletedOnboarding && !isOnboarding) {
      return '/onboarding';
    }
    if (_hasCompletedOnboarding && isOnboarding) {
      return '/today';
    }
    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/today',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/badges',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BadgesScreen(),
      ),
      GoRoute(
        path: '/path',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PathScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/recap',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MonthlyRecapScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RootScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _todayNavigatorKey,
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _insightsNavigatorKey,
            routes: [
              GoRoute(
                path: '/insights',
                builder: (context, state) => const InsightsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
