import 'package:flutter/material.dart';
import 'dawn_palette.dart';
import 'dawn_type.dart';

class DawnTheme {
  static ThemeData build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: DawnPalette.dusk,
      primary: DawnPalette.duskDeep,
      secondary: DawnPalette.dawn,
      surface: DawnPalette.surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: DawnPalette.canvas,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: DawnPalette.ink,
      ),
      cardTheme: CardThemeData(
        color: DawnPalette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: DawnPalette.hairline,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DawnPalette.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        hintStyle: DawnType.body(color: DawnPalette.inkFaint),
        border: _border(DawnPalette.hairline),
        enabledBorder: _border(DawnPalette.hairline),
        focusedBorder: _border(DawnPalette.dusk),
        errorBorder: _border(DawnPalette.strained),
        focusedErrorBorder: _border(DawnPalette.strained),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: DawnPalette.ink,
        contentTextStyle: DawnType.bodyStrong(color: Colors.white),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: c, width: 1.3),
      );
}
