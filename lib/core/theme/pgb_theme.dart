import 'package:flutter/material.dart';
import 'pgb_colors.dart';
import 'pgb_typography.dart';

abstract class PgbTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: PgbColors.background,
      colorScheme: const ColorScheme.dark(
        surface: PgbColors.surface,
        onSurface: PgbColors.textPrimary,
        primary: PgbColors.primary,
        onPrimary: Colors.black,
        error: PgbColors.error,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: PgbTypography.display,
        headlineMedium: PgbTypography.heading1,
        titleLarge: PgbTypography.heading2,
        bodyLarge: PgbTypography.bodyLarge,
        bodyMedium: PgbTypography.bodyMedium,
        bodySmall: PgbTypography.bodySmall,
        labelMedium: PgbTypography.labelMedium,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PgbColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: PgbColors.textPrimary),
        titleTextStyle: PgbTypography.heading2,
      ),
      dividerTheme: const DividerThemeData(
        color: PgbColors.border,
        thickness: 1,
      ),
    );
  }
}
