import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/ui/theme/tokens.dart';

void main() {
  group('Unified Accent & Completion Theme System', () {
    test('All theme accents unify hero with the selected accent palette', () {
      for (final theme in AccentTheme.values) {
        for (final isDark in [true, false]) {
          final tokens = AppTokens.build(isDark: isDark, accentTheme: theme);
          expect(
            tokens.hero,
            equals(tokens.accent),
            reason: '${theme.name} hero should match accent in isDark=$isDark',
          );
        }
      }
    });

    test('Exact palette hex values in Dark and Light mode', () {
      // Frost
      expect(AppTokens.getAccentColor(AccentTheme.frost, true).value, equals(0xFF4A90E2));
      expect(AppTokens.getAccentColor(AccentTheme.frost, false).value, equals(0xFF0060AC));

      // Sage
      expect(AppTokens.getAccentColor(AccentTheme.sage, true).value, equals(0xFF9CAF9C));
      expect(AppTokens.getAccentColor(AccentTheme.sage, false).value, equals(0xFF5F7A66));

      // Ice
      expect(AppTokens.getAccentColor(AccentTheme.ice, true).value, equals(0xFF8FD3E8));
      expect(AppTokens.getAccentColor(AccentTheme.ice, false).value, equals(0xFF005C7A));

      // Copper
      expect(AppTokens.getAccentColor(AccentTheme.copper, true).value, equals(0xFFCD7F32));
      expect(AppTokens.getAccentColor(AccentTheme.copper, false).value, equals(0xFF8B4513));

      // Ember (L16 unlock)
      expect(AppTokens.getAccentColor(AccentTheme.ember, true).value, equals(0xFFE0A458));
      expect(AppTokens.getAccentColor(AccentTheme.ember, false).value, equals(0xFFA9762B));
    });
  });
}
