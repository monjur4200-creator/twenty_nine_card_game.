import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:twenty_nine_card_game/main.dart';
import 'package:twenty_nine_card_game/screens/game_screen.dart';

void main() {
  testWidgets('App loads and shows Main Menu', (WidgetTester tester) async {
    // Pump the whole app
    await tester.pumpWidget(const TwentyNineApp());

    // Verify something unique on the Main Menu screen
    expect(find.text('Main Menu'), findsOneWidget);
  });

  testWidgets('Game screen shows correct title', (WidgetTester tester) async {
    // Pump just the GameScreen inside a MaterialApp
    await tester.pumpWidget(
      const MaterialApp(
        home: GameScreen(),
      ),
    );

    // Verify the GameScreen AppBar title
    expect(find.text('Twenty Nine - Game Table'), findsOneWidget);
  });
}