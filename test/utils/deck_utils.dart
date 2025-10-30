import 'dart:math';
import 'package:twenty_nine_card_game/models/card.dart' as model;

/// Generate a full 32‑card deck for 29 (7–Ace in each suit).
List<model.Card29> generateDeck() {
  final deck = <model.Card29>[];
  for (final suit in model.Suit.values) {
    for (final rank in model.Rank.values) {
      // Only include ranks 7–Ace
      if (rank.index >= model.Rank.seven.index) {
        deck.add(model.Card29(suit, rank));
      }
    }
  }
  return deck;
}

/// Shuffle and deal evenly to [numPlayers].
List<List<model.Card29>> dealShuffledHands(int numPlayers, int cardsPerPlayer) {
  final deck = generateDeck();
  deck.shuffle(Random());
  final hands = List.generate(numPlayers, (_) => <model.Card29>[]);
  for (int i = 0; i < numPlayers * cardsPerPlayer; i++) {
    hands[i % numPlayers].add(deck[i]);
  }
  return hands;
}
