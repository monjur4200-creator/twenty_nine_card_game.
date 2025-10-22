import 'card.dart';
import 'player.dart';
import 'package:twenty_nine_card_game/game_logic/game_errors.dart';

/// Represents a single trick (one round of card plays).
class Trick {
  final Map<Player, Card29> plays = {};
  final List<Player>? turnOrder;
  int _currentTurnIndex = 0;

  Trick({this.turnOrder});

  void addPlay(Player player, Card29 card) {
    // ✅ Prevent same player playing twice
    if (plays.containsKey(player)) {
      throw GameError.invalidMove(
        'Player ${player.name} has already played this trick.',
        ctx: {'playerId': player.id},
      );
    }

    // ✅ Enforce turn order if provided
    if (turnOrder != null && player != turnOrder![_currentTurnIndex]) {
      throw GameError.outOfTurn(player.id.toString());
    }

    // ✅ Ensure the player actually has the card
    if (!player.hand.contains(card)) {
      throw GameError.cardNotInHand(
        playerId: player.id.toString(),
        card: card.toString(),
      );
    }

    // Record play
    plays[player] = card;

    // Delegate removal to Player
    player.playCard(card);

    // Advance turn index
    if (turnOrder != null) {
      _currentTurnIndex = (_currentTurnIndex + 1) % turnOrder!.length;
    }
  }

  /// Determines the winner of the trick based on trump and rank.
  Player? determineWinner(Suit? trumpSuit) {
    if (plays.isEmpty) return null;

    final firstEntry = plays.entries.first;
    final leadSuit = firstEntry.value.suit;

    Player winner = firstEntry.key;
    Card29 winningCard = firstEntry.value;

    for (var entry in plays.entries.skip(1)) {
      final card = entry.value;

      final isTrump = trumpSuit != null && card.suit == trumpSuit;
      final currentIsTrump =
          trumpSuit != null && winningCard.suit == trumpSuit;

      if (isTrump && !currentIsTrump) {
        winner = entry.key;
        winningCard = card;
      } else if (!isTrump && !currentIsTrump) {
        if (card.suit == leadSuit &&
            card.rank.value > winningCard.rank.value) {
          winner = entry.key;
          winningCard = card;
        }
      } else if (isTrump && currentIsTrump) {
        if (card.rank.value > winningCard.rank.value) {
          winner = entry.key;
          winningCard = card;
        }
      }
    }

    return winner;
  }

  int totalPoints() =>
      plays.values.fold<int>(0, (sum, card) => sum + card.points);

  void reset() {
    plays.clear();
    _currentTurnIndex = 0;
  }

  Map<String, dynamic> toMap() {
    return plays.map(
      (player, card) => MapEntry(player.id.toString(), card.toMap()),
    );
  }

  factory Trick.fromMap(Map<String, dynamic> map, List<Player> allPlayers) {
    final trick = Trick();
    map.forEach((pid, cardData) {
      final player = allPlayers.firstWhere(
        (p) => p.id == int.parse(pid),
        orElse: () {
          throw GameError.invalidMove(
            'Player with id $pid not found when reconstructing Trick',
          );
        },
      );
      trick.plays[player] =
          Card29.fromMap(Map<String, dynamic>.from(cardData));
    });
    return trick;
  }
}