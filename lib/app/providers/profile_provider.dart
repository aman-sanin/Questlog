import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/database.dart';
import '../../domain/model/models.dart';
import '../services/sound_service.dart';
import 'database_provider.dart';

final profileStreamProvider = StreamProvider<ProfileData>((ref) {
  return ref.watch(profileDaoProvider).watchProfile();
});

final debugClockOffsetProvider = StateProvider<Duration>((ref) => Duration.zero);

final currentDateTimeProvider = Provider<DateTime>((ref) {
  final offset = ref.watch(debugClockOffsetProvider);
  return DateTime.now().add(offset);
});

final effectiveLocalDateProvider = Provider<LocalDate>((ref) {
  final profileAsync = ref.watch(profileStreamProvider);
  final resetMinute = profileAsync.value?.resetMinute ?? 0;
  final now = ref.watch(currentDateTimeProvider);

  // If resetMinute > 0, the day shifts at (resetMinute) minutes past midnight
  final effectiveNow = now.subtract(Duration(minutes: resetMinute));
  return LocalDate(effectiveNow.year, effectiveNow.month, effectiveNow.day);
});

final activeThemeModeProvider = Provider<ThemeMode>((ref) {
  final profileAsync = ref.watch(profileStreamProvider);
  final modeIndex = profileAsync.value?.themeMode ?? 0;
  switch (modeIndex) {
    case 1:
      return ThemeMode.dark;
    case 2:
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
});

final activeAccentProvider = Provider<String>((ref) {
  final profileAsync = ref.watch(profileStreamProvider);
  return profileAsync.value?.accent ?? 'frost';
});

final weekStartProvider = Provider<WeekStart>((ref) {
  final profileAsync = ref.watch(profileStreamProvider);
  final ws = profileAsync.value?.weekStart ?? 1;
  return ws == 7 ? WeekStart.sunday : WeekStart.monday;
});

final soundEnabledProvider = StreamProvider<bool>((ref) {
  return ref.watch(ledgerDaoProvider).watchKv('sound_enabled').map((val) {
    final enabled = val == 'true';
    SoundService.soundEnabled = enabled;
    return enabled;
  });
});

