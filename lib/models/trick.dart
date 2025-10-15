import 'card.dart';
import 'player.dart';

class Trick {
  final Map<Player, Card29> plays = {};

  /// Adds a card play to the trick
  void addPlay(Player player, Card29 card) {
    card.isPlayed = true;
    plays[player] = card;
  }

  /// Determines the winner of the trick based on trump and rank
  Player? determineWinner(String trumpSuitName) {
    if (plays.isEmpty) return null;

    final leadSuit = plays.values.first.suit;
    Player winner = plays.keys.first;
    Card29 winningCard = plays[winner]!;

    for (var entry in plays.entries) {
      final card = entry.value;

      final isTrump = trumpSuitName.isNotEmpty &&
          (card.isTrump || card.suit.toString().split('.').last == trumpSuitName);
      final currentIsTrump = trumpSuitName.isNotEmpty &&
          (winningCard.isTrump || winningCard.suit.toString().split('.').last == trumpSuitName);

      if (isTrump && !currentIsTrump) {
        winner = entry.key;
        winningCard = card;
      } else if (!isTrump && !currentIsTrump) {
        // Compare by lead suit and rank
        if (card.suit == winningCard.suit &&
            card.rank.value > winningCard.rank.value) {
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