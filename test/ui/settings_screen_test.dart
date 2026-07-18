import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:callory/data/settings_service.dart';
import 'package:callory/db/database.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/settings/settings_screen.dart';
import '../test_helpers.dart';

void main() {
  testWidgets('releasing the gap-window slider persists the new value', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs);

    expect(settingsService.gapWindow, const Duration(minutes: 90));

    await tester.pumpWidget(ProviderScope(
      overrides: [settingsServiceProvider.overrideWithValue(settingsService)],
      child: wrapWithLocalizations(const SettingsScreen()),
    ));
    await tester.pumpAndSettle();

    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(180);
    slider.onChangeEnd!(180);
    await tester.pumpAndSettle();

    expect(find.text('Meal grouping gap: 180 minutes'), findsOneWidget);
    expect(settingsService.gapWindow, const Duration(minutes: 180));
  });

  testWidgets('tapping the Set goals tile navigates to GoalsScreen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
      ],
      child: wrapWithLocalizations(const SettingsScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Set goals'), findsOneWidget);

    await tester.tap(find.text('Set goals'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('manualKcalField')), findsOneWidget);

    await db.close();
  });
}
