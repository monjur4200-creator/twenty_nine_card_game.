import 'card.dart';
import 'player.dart';

/// Represents a single trick (one round of card plays).
class Trick {
  /// Stores the plays in this trick: Player → Card29
  final Map<Player, Card29> plays = {};

  Trick();

  // --- Core Gameplay ---

  /// Adds a card play to the trick.
  /// Throws if the player already played or if the card is not in their hand.
  void addPlay(Player player, Card29 card) {
    if (plays.containsKey(player)) {
      throw ArgumentError('Player ${player.name} has already played this trick.');
    }
    if (!player.hand.contains(card)) {
      throw ArgumentError('Player ${player.name} does not have $card in hand.');
    }

    final updated = card.copyWith(isPlayed: true);
    plays[player] = updated;
  }

  /// Determines the winner of the trick based on trump and rank.
  Player? determineWinner(Suit? trumpSuit) {
    if (plays.isEmpty) return null;

    final leadSuit = plays.values.first.suit;
    Player winner = plays.keys.first;
    Card29 winningCard = plays[winner]!;

    for (var entry in plays.entries) {
      final card = entry.value;

      final isTrump = trumpSuit != null && (card.isTrump || card.suit == trumpSuit);
      final currentIsTrump =
          trumpSuit != null && (winningCard.isTrump || winningCard.suit == trumpSuit);

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

  /// Calculates total points in the trick.
  int totalPoints() {
    return plays.values.fold<int>(0, (sum, card) => sum + card.points);
  }

  /// Returns the plays in insertion order.
  List<MapEntry<Player, Card29>> orderedPlays() {
    return plays.entries.toList();
  }

  /// Clears all plays from this trick.
  void reset() {
    plays.clear();
  }

  // --- Serialization ---

  /// Converts this trick into a Firestore-friendly map.
  Map<String, dynamic> toMap() {
    return plays.map((player, card) => MapEntry(
          player.id.toString(),
          card.toMap(),
        ));
  }

  /// Creates a Trick from a Firestore map.
  factory Trick.fromMap(
    Map<String, dynamic> map,
    List<Player> allPlayers,
  ) {
    final trick = Trick();
    map.forEach((pid, cardData) {
      final player = allPlayers.firstWhere((p) => p.id == int.parse(pid));
      trick.plays[player] = Card29.fromMap(Map<String, dynamic>.from(cardData));
    });
    return trick;
  }
}