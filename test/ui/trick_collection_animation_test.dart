import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/card29.dart';
import 'package:twenty_nine_card_game/ui/trick_collection_animation.dart';
import 'package:twenty_nine_card_game/ui/card_widget.dart';

void main() {
  testWidgets(
    'TrickCollectionAnimation animates cards to winner and triggers callback',
    (tester) async {
      bool callbackTriggered = false;

      final cards = [
        const Card29(Suit.hearts, Rank.jack),
        const Card29(Suit.hearts, Rank.nine),
        const Card29(Suit.hearts, Rank.king),
        const Card29(Suit.hearts, Rank.queen),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrickCollectionAnimation(
              trickCards: cards,
              winnerId: 'Player 3', // Simulated winner
              onComplete: () {
                callbackTriggered = true;
              },
            ),
          ),
        ),
      );

      // Let animation run
      await tester.pumpAndSettle();

      // ✅ Expect 4 cards
      expect(find.byType(CardWidget), findsNWidgets(4));

      // ✅ Callback triggered
      expect(callbackTriggered, isTrue);
    },
  );
}
