import 'card.dart';

class Player {
  final int id;
  final String name;
  final int teamId; // 🆕 Team 1 or 2
  final bool isBot;
  bool isDealer;
  int? partnerId;

  List<Card29> hand = [];
  int score = 0;
  int bid = 0;
  int tricksWon = 0;

  Player({
    required this.id,
    required this.name,
    required this.teamId,
    this.isBot = false,
    this.isDealer = false,
    this.partnerId,
  });

  /// Adds dealt cards to the player's hand
  void receiveCards(List<Card29> cards) {
    hand.addAll(cards);
  }

  /// Plays a card and marks it as played
  void playCard(Card29 card) {
    card.isPlayed = true;
    hand.remove(card);
  }

  /// Sorts the player's hand by suit and rank
  void sortHand() {
    hand.sort((a, b) => a.compareTo(b));
  }

  /// Places a bid between 16 and 28
  void placeBid(int value) {
    if (value < 16 || value > 28) {
      throw ArgumentError('Bid must be between 16 and 28');
    }
    bid = value;
  }

  /// Resets player state for a new round
  void resetForNewRound() {
    hand.clear();
    bid = 0;
    tricksWon = 0;
    isDealer = false;
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Player && id == other.id);

  @override
  int get hashCode => id.hashCode;
}