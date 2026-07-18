import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callory/db/database.dart';
import 'package:callory/data/settings_service.dart';
import 'package:callory/main.dart';
import 'package:callory/providers/providers.dart';

void main() {
  testWidgets('bottom nav has 3 destinations and no Goals tab', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
      ],
      child: const CalloryApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.today), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.flag), findsNothing);
    expect(find.text('Goals'), findsNothing);

    await db.close();
  });
}
