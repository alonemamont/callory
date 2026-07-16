import 'package:callory/ui/theme/app_colors.dart';
import 'package:callory/ui/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mammoth theme color tokens match the approved dark palette', () {
    expect(AppColors.graphiteDark, const Color(0xFF13161A));
    expect(AppColors.graphite, const Color(0xFF212428));
    expect(AppColors.graphiteLight, const Color(0xFF3E4348));
    expect(AppColors.ivory, const Color(0xFFEBE8DF));
    expect(AppColors.amberLamp, const Color(0xFFD58042));
    expect(AppColors.lampGlow, const Color(0xFFA65C20));
    expect(AppColors.error, const Color(0xFFE5484D));
  });

  test('Mammoth theme spacing and radius tokens match the approved scale', () {
    expect(AppSpacing.xs, 4);
    expect(AppSpacing.sm, 8);
    expect(AppSpacing.md, 12);
    expect(AppSpacing.lg, 16);
    expect(AppSpacing.xl, 24);
    expect(AppSpacing.xxl, 32);
    expect(AppSpacing.xxxl, 40);
    expect(AppSpacing.radiusSmall, 4);
    expect(AppSpacing.radiusMedium, 6);
    expect(AppSpacing.radiusLarge, 22);
  });
}
