import 'package:flutter/material.dart';
import 'tokens.dart';

class AppTheme {
  static ThemeData buildTheme({
    required bool isDark,
    required AccentTheme accentTheme,
  }) {
    final tokens = AppTokens.build(isDark: isDark, accentTheme: accentTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: tokens.bg,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: tokens.accent,
        onPrimary: tokens.onSolid,
        secondary: tokens.hero,
        onSecondary: tokens.onSolid,
        error: tokens.miss,
        onError: tokens.onSolid,
        background: tokens.bg,
        onBackground: tokens.textPrimary,
        surface: tokens.tonal,
        onSurface: tokens.textPrimary,
        surfaceVariant: tokens.tonal,
        onSurfaceVariant: tokens.textSecondary,
        outline: tokens.lineRest,
        outlineVariant: tokens.lineRule,
        scrim: tokens.scrim,
      ),
      cardTheme: CardThemeData(
        color: tokens.bg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: Border.all(color: tokens.lineRest),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.tonal,
        elevation: 0,
        shape: Border.all(color: tokens.lineRest),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.tonal,
        elevation: 0,
        shape: Border(
          top: BorderSide(color: tokens.lineRest, width: 1),
        ),
      ),
      buttonTheme: const ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: tokens.textPrimary,
          foregroundColor: tokens.onSolid,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: tokens.tonal,
          foregroundColor: tokens.textPrimary,
          side: BorderSide(color: tokens.lineRest),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.textSecondary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: tokens.accent, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: tokens.lineRest, width: 1),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: tokens.lineRule, width: 1),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: tokens.lineRest, width: 1),
        ),
        labelStyle: tokens.bodyStyle,
        hintStyle: tokens.bodyStyle.copyWith(color: tokens.textSecondary),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.lineRule,
        thickness: 1,
        space: 1,
      ),
      extensions: [tokens],
    );
  }
}
