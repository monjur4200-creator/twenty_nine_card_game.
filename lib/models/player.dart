import 'card.dart';

class Player {
  final int id;
  final String name;
  final int teamId; // Team 1 or 2
  final bool isBot;
  bool isDealer;
  int? partnerId;

  final List<Card29> _hand = [];
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

  /// Expose hand safely (read-only)
  List<Card29> get hand => List.unmodifiable(_hand);

  /// Adds dealt cards to the player's hand
  void receiveCards(List<Card29> cards) {
    _hand.addAll(cards);
  }

  /// Plays a card and marks it as played
  void playCard(Card29 card) {
    if (!_hand.contains(card)) {
      throw ArgumentError('Card not in hand: $card');
    }
    final updated = card.copyWith(isPlayed: true);
    _hand.remove(card);
    _hand.add(updated); // keep record of played state if needed
  }

  /// Sorts the player's hand by suit and rank
  void sortHand() {
    _hand.sort((a, b) => a.compareTo(b));
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
    _hand.clear();
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