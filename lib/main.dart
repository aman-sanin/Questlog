import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/providers/profile_provider.dart';
import 'ui/app_router.dart';
import 'ui/theme/app_theme.dart';
import 'ui/theme/tokens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: QuestLogApp(),
    ),
  );
}

class QuestLogApp extends ConsumerWidget {
  const QuestLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
