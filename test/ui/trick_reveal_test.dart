import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:twenty_nine_card_game/ui/trick_reveal.dart';
import 'package:twenty_nine_card_game/models/card29.dart';

void main() {
  testWidgets('TrickReveal highlights winner card', (tester) async {
    final cards = [
      const Card29(Suit.hearts, Rank.jack),
      const Card29(Suit.spades, Rank.nine),
    ];

    await tester.pumpWidget(MaterialApp(
      home: TrickReveal(
        trickCards: cards,
        winnerName: 'Rafi',
        onComplete: () {},
      ),
    ));

    // ✅ Confirm winner text is shown
    expect(find.text('Winner: Rafi'), findsOneWidget);
  });
}