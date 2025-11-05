import 'card29.dart';
import 'player.dart';
import 'package:twenty_nine_card_game/game_logic/game_errors.dart';

/// Represents a single trick (one round of card plays).
class Trick {
  final Map<Player, Card29> plays = {};
  final List<Player>? turnOrder;
  int _currentTurnIndex = 0;

  Trick({this.turnOrder});

  /// The suit of the first card played in this trick (lead suit).
  Suit? get leadSuit =>
      plays.isNotEmpty ? plays.entries.first.value.suit : null;

  /// ✅ Public getter to expose played cards
  List<Card29> get cards => plays.values.toList();

  /// Adds a card play to the trick, enforcing turn order and ownership.
  void addPlay(Player player, Card29 card) {
    if (plays.containsKey(player)) {
      throw GameError.invalidMove(
        'Player ${player.name} has already played this trick.',
        ctx: {'playerId': player.id},
      );
    }

    if (turnOrder != null && player != turnOrder![_currentTurnIndex]) {
      throw GameError.outOfTurn(player.id.toString());
    }

    if (!player.hand.contains(card)) {
      throw GameError.cardNotInHand(
        playerId: player.id.toString(),
        card: card.toString(),
      );
    }

    plays[player] = card;
    player.playCard(card);

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
      final currentIsTrump = trumpSuit != null && winningCard.suit == trumpSuit;

      if (isTrump && !currentIsTrump) {
        winner = entry.key;
        winningCard = card;
      } else if (!isTrump && !currentIsTrump) {
        if (card.suit == leadSuit && card.rank.value > winningCard.rank.value) {
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

  /// Returns the total points in this trick.
  int totalPoints() =>
      plays.values.fold<int>(0, (sum, card) => sum + card.points);

  /// Resets the trick for reuse.
  void reset() {
    plays.clear();
    _currentTurnIndex = 0;
  }

  /// Serializes the trick to a map.
  Map<String, dynamic> toMap() {
    return plays.map(
      (player, card) => MapEntry(player.id.toString(), card.toMap()),
    );
  }

  /// Reconstructs a trick from a map and player list.
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