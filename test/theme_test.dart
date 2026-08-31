import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/ui/theme/tokens.dart';

void main() {
  group('P7 Theme & Accent Tokens', () {
    test('Structural accents (Frost, Sage, Ice, Copper) MUST NEVER equal hero (Ember)', () {
      final structuralThemes = [
        AccentTheme.frost,
        AccentTheme.sage,
        AccentTheme.ice,
        AccentTheme.copper,
      ];

      for (final isDark in [true, false]) {
        for (final theme in structuralThemes) {
          final tokens = AppTokens.build(isDark: isDark, accentTheme: theme);
          expect(
            tokens.accent,
            isNot(equals(tokens.hero)),
            reason: '${theme.name} accent should not equal hero in isDark=$isDark',
          );
        }
      }
    });

    test('Ember accent theme unifies accent and hero color values', () {
      final darkTokens = AppTokens.build(isDark: true, accentTheme: AccentTheme.ember);
      expect(darkTokens.accent, equals(darkTokens.hero));
      expect(darkTokens.hero, equals(const Color(0xFFE0A458)));

      final lightTokens = AppTokens.build(isDark: false, accentTheme: AccentTheme.ember);
      expect(lightTokens.accent, equals(lightTokens.hero));
      expect(lightTokens.hero, equals(const Color(0xFFA9762B)));
    });

    test('Frost accent exact hexes: Dark #4A90E2, Light #0060AC', () {
      final darkFrost = AppTokens.getAccentColor(AccentTheme.frost, true);
      expect(darkFrost.value, equals(0xFF4A90E2));

      final lightFrost = AppTokens.getAccentColor(AccentTheme.frost, false);
      expect(lightFrost.value, equals(0xFF0060AC));
    });

    test('Hero Ember exact hexes: Dark #E0A458, Light #A9762B, Light Text #8A5A13', () {
      final darkTokens = AppTokens.build(isDark: true, accentTheme: AccentTheme.frost);
      expect(darkTokens.hero.value, equals(0xFFE0A458));

      final lightTokens = AppTokens.build(isDark: false, accentTheme: AccentTheme.frost);
      expect(lightTokens.hero.value, equals(0xFFA9762B));
      expect(lightTokens.heroText.value, equals(0xFF8A5A13));
    });
  });
}
