import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const _family = 'JetBrainsMono';

  static const textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _family,
      fontSize: 40,
      fontWeight: FontWeight.w700,
      color: AppColors.ivory,
    ),
    titleLarge: TextStyle(
      fontFamily: _family,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.ivory,
    ),
    titleMedium: TextStyle(
      fontFamily: _family,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.ivory,
    ),
    titleSmall: TextStyle(
      fontFamily: _family,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.ivory,
    ),
    bodyLarge: TextStyle(
      fontFamily: _family,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppColors.ivory,
    ),
    bodyMedium: TextStyle(
      fontFamily: _family,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppColors.ivory,
    ),
    bodySmall: TextStyle(
      fontFamily: _family,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.ivory,
    ),
    labelLarge: TextStyle(
      fontFamily: _family,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.ivory,
      letterSpacing: 2,
    ),
    labelMedium: TextStyle(
      fontFamily: _family,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.ivory,
      letterSpacing: 1.5,
    ),
    labelSmall: TextStyle(
      fontFamily: _family,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.ivory,
      letterSpacing: 1,
    ),
  );
}
