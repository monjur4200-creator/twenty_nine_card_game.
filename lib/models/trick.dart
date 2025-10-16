import 'card.dart';
import 'player.dart';

class Trick {
  final Map<Player, Card29> plays = {};

  /// Adds a card play to the trick
  void addPlay(Player player, Card29 card) {
    if (plays.containsKey(player)) {
      throw ArgumentError('Player ${player.name} has already played this trick.');
    }
    final updated = card.copyWith(isPlayed: true);
    plays[player] = updated;
  }

  /// Determines the winner of the trick based on trump and rank
  Player? determineWinner(Suit? trumpSuit) {
    if (plays.isEmpty) return null;

    final leadSuit = plays.values.first.suit;
    Player winner = plays.keys.first;
    Card29 winningCard = plays[winner]!;

    for (var entry in plays.entries) {
      final card = entry.value;

      final isTrump = trumpSuit != null && (card.isTrump || card.suit == trumpSuit);
      final currentIsTrump = trumpSuit != null && (winningCard.isTrump || winningCard.suit == trumpSuit);

      if (isTrump && !currentIsTrump) {
        winner = entry.key;
        winningCard = card;
      } else if (!isTrump && !currentIsTrump) {
        // Compare only if same suit as lead
        if (card.suit == leadSuit && card.rank.value > winningCard.rank.value) {
          winner = entry.key;
          winningCard = card;
        }
      } else if (isTrump && currentIsTrump) {
        // Both are trump — compare rank
        if (card.rank.value > winningCard.rank.value) {
          winner = entry.key;
          winningCard = card;
        }
      }
    }

    return winner;
  }

  /// Calculates total points in the trick
  int totalPoints() {
    return plays.values.fold(0, (sum, card) => sum + card.points);
  }

  /// Returns the plays in order
  List<MapEntry<Player, Card29>> orderedPlays() {
    return plays.entries.toList();
  }

  /// Resets the trick
  void reset() {
    plays.clear();
  }
}