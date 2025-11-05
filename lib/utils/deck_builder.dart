import '../models/card_model.dart';
import 'dart:math';

class DeckBuilder {
  /// Generate the 32 playable cards for 29 (7–10, J, Q, K, A of each suit).
  static List<CardModel> generateDeck() {
    final validRanks = [7, 8, 9, 10, 11, 12, 13, 1]; // 7–10, J, Q, K, A
    final deck = <CardModel>[];

    for (final suit in Suit.values) {
      for (final rank in validRanks) {
        deck.add(CardModel(rank: rank, suit: suit));
      }
    }
    return deck;
  }

  /// Generate all four 6s as score markers (not part of the playable deck).
  /// Each team can use one red (♥/♦) and one black (♠/♣) marker.
  static List<CardModel> generateMarkers() {
    return [
      const CardModel(rank: 6, suit: Suit.hearts),   // red marker
      const CardModel(rank: 6, suit: Suit.diamonds), // red marker
      const CardModel(rank: 6, suit: Suit.spades),   // black marker
      const CardModel(rank: 6, suit: Suit.clubs),    // black marker
    ];
  }

  /// Fisher–Yates shuffle with optional seed for reproducibility.
  static List<CardModel> shuffleDeck(List<CardModel> deck, {int? seed}) {
    final rng = seed != null ? Random(seed) : Random();
    final shuffled = List<CardModel>.from(deck);

    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    return shuffled;
  }
}
