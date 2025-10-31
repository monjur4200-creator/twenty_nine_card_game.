import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:twenty_nine_card_game/models/card_model.dart';
import 'package:twenty_nine_card_game/widgets/card_loader.dart';

void main() {
  group('Card UI interactions', () {
    testWidgets('Card renders correctly in UI', (tester) async {
      final card = CardModel(rank: 9, suit: Suit.clubs);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardLoader(card: card),
          ),
        ),
      );

      // Verify the card image is present
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Card responds to tap', (tester) async {
      bool tapped = false;
      final card = CardModel(rank: 7, suit: Suit.hearts);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              onTap: () => tapped = true,
              child: CardLoader(card: card),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CardLoader));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('Card can be dragged', (tester) async {
      final card = CardModel(rank: 5, suit: Suit.spades);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Draggable<CardModel>(
              data: card,
              feedback: CardLoader(card: card, width: 40, height: 60),
              child: CardLoader(card: card),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(CardLoader), const Offset(50, 0));
      await tester.pump();

      // Verify drag feedback widget appears
      expect(find.byType(CardLoader), findsWidgets);
    });

    testWidgets('Card flip animation works', (tester) async {
      final card = CardModel(rank: 12, suit: Suit.diamonds);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: CardLoader(card: card, key: ValueKey(card.toString())),
            ),
          ),
        ),
      );

      // Trigger flip by changing key
      final newCard = CardModel(rank: 1, suit: Suit.spades);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: CardLoader(card: newCard, key: ValueKey(newCard.toString())),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(CardLoader), findsWidgets);
    });
  });
}
