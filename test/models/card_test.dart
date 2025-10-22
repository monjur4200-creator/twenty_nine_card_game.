import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/card.dart';

void main() {
  group('Card29', () {
    test('equality works correctly', () {
      final card1 = Card29(Suit.hearts, Rank.nine);
      final card2 = Card29(Suit.hearts, Rank.nine);
      final card3 = Card29(Suit.spades, Rank.nine);

      expect(card1, equals(card2));
      expect(card1, isNot(equals(card3)));
    });

    test('hashCode is consistent with equality', () {
      final card1 = Card29(Suit.clubs, Rank.jack);
      final card2 = Card29(Suit.clubs, Rank.jack);

      expect(card1.hashCode, equals(card2.hashCode));
    });

    test('toString returns human-readable format', () {
      final card = Card29(Suit.hearts, Rank.ace);
      expect(card.toString(), equals('A♥'));
    });

    test('pointValue returns correct values for all ranks', () {
      expect(Card29(Suit.spades, Rank.jack).pointValue, equals(3));
      expect(Card29(Suit.diamonds, Rank.nine).pointValue, equals(2));
      expect(Card29(Suit.clubs, Rank.ace).pointValue, equals(1));
      expect(Card29(Suit.hearts, Rank.ten).pointValue, equals(1));
      expect(Card29(Suit.hearts, Rank.king).pointValue, equals(0));
      expect(Card29(Suit.hearts, Rank.queen).pointValue, equals(0));
      expect(Card29(Suit.hearts, Rank.seven).pointValue, equals(0));
    });

    test('rank comparison uses Rank.value ordering', () {
      final jack = Card29(Suit.hearts, Rank.jack);
      final nine = Card29(Suit.hearts, Rank.nine);
      final ace = Card29(Suit.hearts, Rank.ace);

      expect(jack.compareTo(nine) > 0, isTrue);
      expect(ace.compareTo(nine) > 0, isTrue);
    });

    test('cards of different suits are not equal', () {
      final card1 = Card29(Suit.hearts, Rank.jack);
      final card2 = Card29(Suit.spades, Rank.jack);

      expect(card1 == card2, isFalse);
    });

    test('toMap and fromMap round-trip preserves card', () {
      final card = Card29(
        Suit.hearts,
        Rank.nine,
        isTrump: true,
        isPlayed: true,
      );
      final map = card.toMap();
      final restored = Card29.fromMap(map);

      expect(restored, equals(card));
      expect(restored.isTrump, isTrue);
      expect(restored.isPlayed, isTrue);
    });

    test('fromMap with missing fields defaults safely', () {
      final map = {'suit': 'hearts', 'rank': 'nine'};
      final restored = Card29.fromMap(map);

      expect(restored.suit, equals(Suit.hearts));
      expect(restored.rank, equals(Rank.nine));
      expect(restored.isTrump, isFalse);
      expect(restored.isPlayed, isFalse);
    });

    test('fullDeck generates 32 unique cards', () {
      final deck = Card29.fullDeck();
      expect(deck, hasLength(32));
      expect(deck.toSet(), hasLength(32));
    });

    test('copyWith updates flags immutably', () {
      final card = Card29(Suit.spades, Rank.nine);
      final updated = card.copyWith(isTrump: true, isPlayed: true);

      expect(updated.isTrump, isTrue);
      expect(updated.isPlayed, isTrue);
      expect(card.isTrump, isFalse); // original unchanged
      expect(card.isPlayed, isFalse);
    });
  });
}
