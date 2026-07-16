import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'JetBrainsMono',
    scaffoldBackgroundColor: AppColors.graphiteDark,
    textTheme: AppTypography.textTheme,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.graphite,
      onSurface: AppColors.ivory,
      primary: AppColors.amberLamp,
      onPrimary: AppColors.graphiteDark,
      secondary: AppColors.lampGlow,
      onSecondary: AppColors.ivory,
      error: AppColors.error,
      onError: AppColors.ivory,
      outline: AppColors.graphiteLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.graphite,
      foregroundColor: AppColors.ivory,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(
        bottom: BorderSide(color: AppColors.graphiteLight, width: 1),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.graphite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        side: const BorderSide(color: AppColors.graphiteLight, width: 1),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.graphiteDark,
      indicatorColor: AppColors.amberLamp.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.amberLamp
              : AppColors.ivory.withValues(alpha: 0.6),
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => AppTypography.textTheme.labelMedium?.copyWith(
          color: states.contains(WidgetState.selected)
              ? AppColors.amberLamp
              : AppColors.ivory.withValues(alpha: 0.6),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.amberLamp,
        foregroundColor: AppColors.graphiteDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.amberLamp,
        foregroundColor: AppColors.graphiteDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.graphite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        borderSide: const BorderSide(color: AppColors.graphiteLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        borderSide: const BorderSide(color: AppColors.graphiteLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        borderSide: const BorderSide(color: AppColors.amberLamp, width: 2),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.graphiteLight,
      thickness: 1,
    ),
  );
}
