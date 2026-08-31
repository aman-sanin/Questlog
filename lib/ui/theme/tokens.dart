import 'package:flutter/material.dart';

enum AccentTheme {
  frost,
  sage,
  ice,
  copper,
  ember;

  String get key => name;

  static AccentTheme fromKey(String key) {
    return AccentTheme.values.firstWhere(
      (e) => e.key == key,
      orElse: () => AccentTheme.frost,
    );
  }
}

class AppTokens extends ThemeExtension<AppTokens> {
  final Color bg;
  final Color tonal;
  final Color textPrimary;
  final Color textSecondary;
  final Color lineRest;
  final Color lineRule;
  final Color lineFull;
  final Color accent; // Frost / Sage / Ice / Copper
  final Color hero;   // Ember
  final Color heroText; // Ember text (for light mode text contrast)
  final Color onSolid;
  final Color miss;
  final Color scrim;

  // Base typography
  final TextStyle displayStyle;
  final TextStyle headlineStyle;
  final TextStyle headlineMStyle;
  final TextStyle titleStyle;
  final TextStyle rowTitleStyle;
  final TextStyle bodyLGStyle;
  final TextStyle bodyStyle;
  final TextStyle labelCapsStyle;

  AppTokens({
    required this.bg,
    required this.tonal,
    required this.textPrimary,
    required this.textSecondary,
    required this.lineRest,
    required this.lineRule,
    required this.lineFull,
    required this.accent,
    required this.hero,
    required this.heroText,
    required this.onSolid,
    required this.miss,
    required this.scrim,
    required this.displayStyle,
    required this.headlineStyle,
    required this.headlineMStyle,
    required this.titleStyle,
    required this.rowTitleStyle,
    required this.bodyLGStyle,
    required this.bodyStyle,
    required this.labelCapsStyle,
  });

  // Typography helper methods
  TextStyle monoText({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: fontSize ?? 13,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? textPrimary,
      letterSpacing: letterSpacing,
    );
  }

  TextStyle title({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    FontStyle? fontStyle,
    double? letterSpacing,
  }) {
    return titleStyle.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
    );
  }

  TextStyle body({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    FontStyle? fontStyle,
    double? letterSpacing,
  }) {
    return bodyStyle.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
    );
  }

  TextStyle headline({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return headlineStyle.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      letterSpacing: letterSpacing,
    );
  }

  TextStyle headlineM({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return headlineMStyle.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      letterSpacing: letterSpacing,
    );
  }

  TextStyle display({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return displayStyle.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      letterSpacing: letterSpacing,
    );
  }

  // Default color palettes
  static Color getAccentColor(AccentTheme theme, bool isDark) {
    switch (theme) {
      case AccentTheme.frost:
        return isDark ? const Color(0xFF4A90E2) : const Color(0xFF0060AC);
      case AccentTheme.sage:
        return isDark ? const Color(0xFF9CAF9C) : const Color(0xFF5F7A66);
      case AccentTheme.ice:
        return isDark ? const Color(0xFF8FD3E8) : const Color(0xFF005C7A);
      case AccentTheme.copper:
        return isDark ? const Color(0xFFCD7F32) : const Color(0xFF8B4513);
      case AccentTheme.ember:
        return isDark ? const Color(0xFFE0A458) : const Color(0xFFA9762B);
    }
  }

  static AppTokens build({
    required bool isDark,
    required AccentTheme accentTheme,
  }) {
    final bg = isDark ? const Color(0xFF000000) : const Color(0xFFFAF7F2);
    final tonal = isDark ? const Color(0xFF121212) : const Color(0xFFFFFCF7);
    final textPrimary = isDark ? const Color(0xFFFAF7F2) : const Color(0xFF1A1815);
    final textSecondary = isDark ? const Color(0xFF888681) : const Color(0xFF6B675E);
    
    final lineRest = isDark ? textPrimary.withOpacity(0.20) : textPrimary.withOpacity(0.10);
    final lineRule = isDark ? textPrimary.withOpacity(0.12) : textPrimary.withOpacity(0.06);
    final lineFull = textPrimary;

    final accent = getAccentColor(accentTheme, isDark);
    final hero = accent; // Unified with active accent palette
    final heroText = accent;
    final onSolid = isDark ? const Color(0xFF1A1815) : const Color(0xFFFAF7F2);
    final miss = isDark ? const Color(0xFFC25B52) : const Color(0xFFA34E46);
    final scrim = isDark ? const Color(0x33000000) : const Color(0x8C1A1815);

    // Typography
    const displayStyleInit = TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 48,
      fontWeight: FontWeight.w700,
      letterSpacing: -48 * 0.02,
    );

    const headlineStyleInit = TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 32,
      fontWeight: FontWeight.w600,
    );

    const headlineMStyleInit = TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 28,
      fontWeight: FontWeight.w600,
    );

    const titleStyleInit = TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );

    const rowTitleStyleInit = TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );

    const bodyLGStyleInit = TextStyle(
      fontFamily: 'Geist',
      fontSize: 18,
      fontWeight: FontWeight.w400,
    );

    const bodyStyleInit = TextStyle(
      fontFamily: 'Geist',
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );

    const labelCapsStyleInit = TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 12 * 0.10,
    );

    return AppTokens(
      bg: bg,
      tonal: tonal,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      lineRest: lineRest,
      lineRule: lineRule,
      lineFull: lineFull,
      accent: accent,
      hero: hero,
      heroText: heroText,
      onSolid: onSolid,
      miss: miss,
      scrim: scrim,
      displayStyle: displayStyleInit.copyWith(color: textPrimary),
      headlineStyle: headlineStyleInit.copyWith(color: textPrimary),
      headlineMStyle: headlineMStyleInit.copyWith(color: textPrimary),
      titleStyle: titleStyleInit.copyWith(color: textPrimary),
      rowTitleStyle: rowTitleStyleInit.copyWith(color: textPrimary),
      bodyLGStyle: bodyLGStyleInit.copyWith(color: textPrimary),
      bodyStyle: bodyStyleInit.copyWith(color: textPrimary),
      labelCapsStyle: labelCapsStyleInit.copyWith(color: textSecondary),
    );
  }

  @override
  ThemeExtension<AppTokens> copyWith({
    Color? bg,
    Color? tonal,
    Color? textPrimary,
    Color? textSecondary,
    Color? lineRest,
    Color? lineRule,
    Color? lineFull,
    Color? accent,
    Color? hero,
    Color? heroText,
    Color? onSolid,
    Color? miss,
    Color? scrim,
    TextStyle? displayStyle,
    TextStyle? headlineStyle,
    TextStyle? headlineMStyle,
    TextStyle? titleStyle,
    TextStyle? rowTitleStyle,
    TextStyle? bodyLGStyle,
    TextStyle? bodyStyle,
    TextStyle? labelCapsStyle,
  }) {
    return AppTokens(
      bg: bg ?? this.bg,
      tonal: tonal ?? this.tonal,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      lineRest: lineRest ?? this.lineRest,
      lineRule: lineRule ?? this.lineRule,
      lineFull: lineFull ?? this.lineFull,
      accent: accent ?? this.accent,
      hero: hero ?? this.hero,
      heroText: heroText ?? this.heroText,
      onSolid: onSolid ?? this.onSolid,
      miss: miss ?? this.miss,
      scrim: scrim ?? this.scrim,
      displayStyle: displayStyle ?? this.displayStyle,
      headlineStyle: headlineStyle ?? this.headlineStyle,
      headlineMStyle: headlineMStyle ?? this.headlineMStyle,
      titleStyle: titleStyle ?? this.titleStyle,
      rowTitleStyle: rowTitleStyle ?? this.rowTitleStyle,
      bodyLGStyle: bodyLGStyle ?? this.bodyLGStyle,
      bodyStyle: bodyStyle ?? this.bodyStyle,
      labelCapsStyle: labelCapsStyle ?? this.labelCapsStyle,
    );
  }

  @override
  ThemeExtension<AppTokens> lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      bg: Color.lerp(bg, other.bg, t)!,
      tonal: Color.lerp(tonal, other.tonal, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      lineRest: Color.lerp(lineRest, other.lineRest, t)!,
      lineRule: Color.lerp(lineRule, other.lineRule, t)!,
      lineFull: Color.lerp(lineFull, other.lineFull, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      hero: Color.lerp(hero, other.hero, t)!,
      heroText: Color.lerp(heroText, other.heroText, t)!,
      onSolid: Color.lerp(onSolid, other.onSolid, t)!,
      miss: Color.lerp(miss, other.miss, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      displayStyle: TextStyle.lerp(displayStyle, other.displayStyle, t)!,
      headlineStyle: TextStyle.lerp(headlineStyle, other.headlineStyle, t)!,
      headlineMStyle: TextStyle.lerp(headlineMStyle, other.headlineMStyle, t)!,
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t)!,
      rowTitleStyle: TextStyle.lerp(rowTitleStyle, other.rowTitleStyle, t)!,
      bodyLGStyle: TextStyle.lerp(bodyLGStyle, other.bodyLGStyle, t)!,
      bodyStyle: TextStyle.lerp(bodyStyle, other.bodyStyle, t)!,
      labelCapsStyle: TextStyle.lerp(labelCapsStyle, other.labelCapsStyle, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
