import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callory/ui/widgets/number_field.dart';

void main() {
  testWidgets('autofocus:true grabs focus and selects all existing text on build', (tester) async {
    final controller = TextEditingController(text: '100');

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NumberField(controller: controller, labelText: 'Grams', autofocus: true),
      ),
    ));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, true);
    expect(
      controller.selection,
      const TextSelection(baseOffset: 0, extentOffset: 3),
    );
  });

  testWidgets('autofocus defaults to false', (tester) async {
    final controller = TextEditingController(text: '100');

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NumberField(controller: controller, labelText: 'Grams'),
      ),
    ));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, false);
  });
}
