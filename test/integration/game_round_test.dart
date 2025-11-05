import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/card_model.dart';
import 'package:twenty_nine_card_game/utils/deck_builder.dart';

void main() {
  group('Mini round integration test', () {
    test('Deal, draw, discard flow works end-to-end', () {
      // 1. Generate and shuffle deck (32 cards in Twenty-Nine: 7–Ace of each suit)
      final deck = DeckBuilder.shuffleDeck(
        DeckBuilder.generateDeck(),
        seed: 99,
      );
      expect(deck.length, equals(32));

      // 2. Deal 5 cards to player
      final playerHand = deck.take(5).toList();
      final remainingDeck = deck.skip(5).toList();

      expect(playerHand.length, equals(5));
      expect(remainingDeck.length, equals(27));

      // 3. Player draws top card
      final drawnCard = remainingDeck.first;
      playerHand.add(drawnCard);
      final afterDrawDeck = remainingDeck.skip(1).toList();

      expect(playerHand.length, equals(6));
      expect(afterDrawDeck.length, equals(26)); // ✅ corrected for 32-card deck

      // 4. Player discards one card
      final discardPile = <CardModel>[];
      final discarded = playerHand.removeLast();
      discardPile.add(discarded);

      expect(playerHand.length, equals(5));
      expect(discardPile.length, equals(1));
      expect(discardPile.first, equals(discarded));

      // 5. Validate no duplicates across zones
      final allCards = {...playerHand, ...afterDrawDeck, ...discardPile};
      expect(allCards.length, equals(32));
    });
  });
}
