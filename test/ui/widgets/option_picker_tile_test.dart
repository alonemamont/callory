import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callory/ui/widgets/option_picker_tile.dart';

void main() {
  testWidgets('shows field label and current value, and preserves the given key', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OptionPickerTile<String>(
          fieldKey: const Key('testField'),
          fieldLabel: 'Sex',
          currentValueLabel: 'Male',
          options: const ['Male', 'Female'],
          optionLabel: (o) => o,
          optionDescription: (o) => 'Description for $o',
          onChanged: (_) {},
        ),
      ),
    ));

    expect(find.text('Sex: Male'), findsOneWidget);
    expect(find.byKey(const Key('testField')), findsOneWidget);
  });

  testWidgets('tapping the tile opens a modal listing every option with its description', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OptionPickerTile<String>(
          fieldLabel: 'Sex',
          currentValueLabel: 'Male',
          options: const ['Male', 'Female'],
          optionLabel: (o) => o,
          optionDescription: (o) => 'Description for $o',
          onChanged: (_) {},
        ),
      ),
    ));

    await tester.tap(find.text('Sex: Male'));
    await tester.pumpAndSettle();

    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);
    expect(find.text('Description for Male'), findsOneWidget);
    expect(find.text('Description for Female'), findsOneWidget);
  });

  testWidgets('selecting an option calls onChanged and closes the modal', (tester) async {
    String? selected;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OptionPickerTile<String>(
          fieldLabel: 'Sex',
          currentValueLabel: 'Male',
          options: const ['Male', 'Female'],
          optionLabel: (o) => o,
          optionDescription: (o) => 'Description for $o',
          onChanged: (o) => selected = o,
        ),
      ),
    ));

    await tester.tap(find.text('Sex: Male'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Female'));
    await tester.pumpAndSettle();

    expect(selected, 'Female');
    expect(find.text('Description for Male'), findsNothing);
  });
}
