import 'package:flutter/material.dart';
import 'pgb_colors.dart';

abstract class PgbTypography {
  static const TextStyle display = TextStyle(
    fontFamily: 'Syne',
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: PgbColors.textPrimary,
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Syne',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: PgbColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Syne',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: PgbColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: PgbColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: PgbColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: PgbColors.textTertiary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: PgbColors.textPrimary,
  );
}
