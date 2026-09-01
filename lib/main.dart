import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/providers/database_provider.dart';
import 'app/providers/profile_provider.dart';
import 'app/providers/today_provider.dart';
import 'ui/app_router.dart';
import 'ui/theme/app_theme.dart';
import 'ui/theme/tokens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    const ProviderScope(
      child: QuestLogApp(),
    ),
  );
}

class QuestLogApp extends ConsumerStatefulWidget {
  const QuestLogApp({super.key});

  @override
  ConsumerState<QuestLogApp> createState() => _QuestLogAppState();
}

class _QuestLogAppState extends ConsumerState<QuestLogApp> with WidgetsBindingObserver {
  Timer? _minuteTicker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startMinuteTicker();
  }

  @override
  void dispose() {
    _minuteTicker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-invalidate time and profile state on app resume
      ref.invalidate(currentDateTimeProvider);
      ref.invalidate(profileStreamProvider);
      _syncWidgetsAndNotifications();
    }
  }

  void _startMinuteTicker() {
    _minuteTicker?.cancel();
    _minuteTicker = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(currentDateTimeProvider);
    });
  }

  void _syncWidgetsAndNotifications() {
    try {
      final todayState = ref.read(todayStateProvider).value;
      final profile = ref.read(profileStreamProvider).value;
      final quests = ref.read(activeQuestsStreamProvider).value;

      if (todayState != null && profile != null && quests != null) {
        // Sync notifications
        ref.read(notificationServiceProvider).reconcile(
              profile: profile,
              activeQuests: quests,
              evaluations: todayState.allQuests,
              today: todayState.today,
            );

        // Sync home widget
        ref.read(widgetServiceProvider).updateSnapshot(
              evaluations: todayState.allQuests,
              streak: todayState.allQuests.isEmpty
                  ? 0
                  : todayState.allQuests.map((e) => e.streak).reduce((a, b) => a > b ? a : b),
              accentHex: profile.accent,
            );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(activeThemeModeProvider);
    final accentKey = ref.watch(activeAccentProvider);
    final accentTheme = AccentTheme.fromKey(accentKey);

    final darkTheme = AppTheme.buildTheme(isDark: true, accentTheme: accentTheme);
    final lightTheme = AppTheme.buildTheme(isDark: false, accentTheme: accentTheme);

    return MaterialApp.router(
      title: 'QuestLog',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: router,
    );
  }
}
