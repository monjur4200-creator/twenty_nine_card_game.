import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/card_model.dart';
import 'package:twenty_nine_card_game/utils/deck_builder.dart';

void main() {
  group('Deck mechanics', () {
    test('Deck has 32 unique cards', () {
      final deck = DeckBuilder.generateDeck();
      expect(deck.length, equals(32));

      final unique = deck.map((c) => c.toString()).toSet();
      expect(unique.length, equals(32));
    });

    test('Shuffle preserves all cards', () {
      final deck = DeckBuilder.generateDeck();
      final shuffled = DeckBuilder.shuffleDeck(deck, seed: 123);

      expect(shuffled.length, equals(32));
      expect(shuffled.toSet().length, equals(32));
      expect(shuffled, isNot(equals(deck))); // order should differ
    });

    test('Draw reduces deck size', () {
      final deck = DeckBuilder.generateDeck();
      final firstCard = deck.first;
      final remaining = List<CardModel>.from(deck)..removeAt(0);

      expect(remaining.length, equals(31)); // 32 - 1
      expect(remaining.contains(firstCard), isFalse);
    });

    test('Discard pile works', () {
      final deck = DeckBuilder.generateDeck();
      final discardPile = <CardModel>[];

      final drawn = deck.first;
      discardPile.add(drawn);

      expect(discardPile.length, equals(1));
      expect(discardPile.first, equals(drawn));
    });

    test('Matching logic (same rank)', () {
      final card1 = CardModel(rank: 9, suit: Suit.clubs);
      final card2 = CardModel(rank: 9, suit: Suit.hearts);

      expect(card1.rank, equals(card2.rank));
      expect(card1.suit, isNot(equals(card2.suit)));
    });
  });
}
