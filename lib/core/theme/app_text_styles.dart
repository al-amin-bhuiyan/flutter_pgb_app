import 'package:flutter/material.dart';
import 'dimensions.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get display => TextStyle(
        fontFamily: 'Inter',
        fontSize: AppDimensions.fontDisplayS,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.48,
      );

  static TextStyle get titleLarge => TextStyle(
        fontFamily: 'Inter',
        fontSize: AppDimensions.fontTitleL,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.44,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: 'Inter',
        fontSize: AppDimensions.fontTitleM,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleSmall => TextStyle(
        fontFamily: 'Inter',
        fontSize: AppDimensions.fontTitleS,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontFamily: 'Inter',
        fontSize: AppDimensions.fontXXL,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: 'Inter',
        fontSize: AppDimensions.fontXL,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: 'Inter',
        fontSize: AppDimensions.fontL,
        color: AppColors.textSecondary,
      );

  static TextStyle get label => TextStyle(
        fontFamily: 'Inter',
        fontSize: AppDimensions.fontS,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );

  static TextStyle get badge => TextStyle(
        fontFamily: 'Inter',
        fontSize: AppDimensions.fontXS,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );
}
