import 'package:flutter/material.dart';
import 'pgb_colors.dart';
import 'pgb_typography.dart';

abstract class PgbTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: PgbColors.lightBackground,
      colorScheme: const ColorScheme.light(
        surface: PgbColors.lightSurface,
        onSurface: PgbColors.lightTextPrimary,
        primary: PgbColors.primary,
        onPrimary: Colors.white,
        error: PgbColors.error,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: PgbTypography.display.copyWith(color: PgbColors.lightTextPrimary),
        headlineMedium: PgbTypography.heading1.copyWith(color: PgbColors.lightTextPrimary),
        titleLarge: PgbTypography.heading2.copyWith(color: PgbColors.lightTextPrimary),
        bodyLarge: PgbTypography.bodyLarge.copyWith(color: PgbColors.lightTextPrimary),
        bodyMedium: PgbTypography.bodyMedium.copyWith(color: PgbColors.lightTextSecondary),
        bodySmall: PgbTypography.bodySmall.copyWith(color: PgbColors.lightTextSecondary),
        labelMedium: PgbTypography.labelMedium.copyWith(color: PgbColors.lightTextPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PgbColors.lightBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: PgbColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: PgbColors.lightTextPrimary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: PgbColors.lightBorder,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: PgbColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        surface: PgbColors.darkSurface,
        onSurface: PgbColors.darkTextPrimary,
        primary: PgbColors.primary,
        onPrimary: Colors.white,
        error: PgbColors.error,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: PgbTypography.display.copyWith(color: PgbColors.darkTextPrimary),
        headlineMedium: PgbTypography.heading1.copyWith(color: PgbColors.darkTextPrimary),
        titleLarge: PgbTypography.heading2.copyWith(color: PgbColors.darkTextPrimary),
        bodyLarge: PgbTypography.bodyLarge.copyWith(color: PgbColors.darkTextPrimary),
        bodyMedium: PgbTypography.bodyMedium.copyWith(color: PgbColors.darkTextSecondary),
        bodySmall: PgbTypography.bodySmall.copyWith(color: PgbColors.darkTextSecondary),
        labelMedium: PgbTypography.labelMedium.copyWith(color: PgbColors.darkTextPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PgbColors.darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: PgbColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: PgbColors.darkTextPrimary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: PgbColors.darkBorder,
        thickness: 1,
      ),
    );
  }
}
