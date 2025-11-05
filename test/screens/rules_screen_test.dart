import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/screens/rules_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Rules screen loads and displays title', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RulesScreen()));

    expect(find.byKey(const Key('rulesScreenTitle')), findsOneWidget);
    expect(find.text('Twenty-Nine Rules'), findsOneWidget);
    expect(find.textContaining('Jack: 3 points'), findsOneWidget);
  });
}
