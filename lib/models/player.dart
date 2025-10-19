import 'card.dart';

/// Represents a single player in the game.
class Player {
  final int id;          // Unique player ID
  final String name;     // Player's display name
  final int teamId;      // Team assignment (1 or 2)
  final bool isBot;      // Whether this player is AI-controlled
  bool isDealer;         // Dealer flag
  int? partnerId;        // Partner player ID (optional)

  // Keep the actual hand private and mutable
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

  // --- Hand Management ---

  /// Expose hand safely (read-only)
  List<Card29> get hand => List.unmodifiable(_hand);

  /// Adds dealt cards to the player's hand
  void receiveCards(List<Card29> cards) {
    _hand.addAll(cards);
  }

  /// Marks trump cards in the hand
  void markTrumpCards(Suit suit) {
    for (var i = 0; i < _hand.length; i++) {
      final card = _hand[i];
      if (card.suit == suit) {
        _hand[i] = card.copyWith(isTrump: true);
      }
    }
  }

  /// Plays a card and marks it as played
  void playCard(Card29 card) {
    final index = _hand.indexOf(card);
    if (index == -1) {
      throw ArgumentError('Card not in hand: $card');
    }
    _hand[index] = card.copyWith(isPlayed: true);
  }

  /// Sorts the player's hand by suit and rank
  void sortHand() {
    _hand.sort((a, b) => a.compareTo(b));
  }

  // --- Bidding ---

  /// Places a bid between 16 and 28
  void placeBid(int value) {
    if (value < 16 || value > 28) {
      throw ArgumentError('Bid must be between 16 and 28');
    }
    bid = value;
  }

  // --- Round Management ---

  /// Resets player state for a new round
  void resetForNewRound() {
    _hand.clear();
    bid = 0;
    tricksWon = 0;
    isDealer = false;
  }

  // --- Test Utilities ---

  /// For testing only: replace the player's hand with a custom set of cards
  void setHandForTest(List<Card29> cards) {
    _hand
      ..clear()
      ..addAll(cards);
  }

  // --- Serialization ---

  /// Converts this Player into a Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teamId': teamId,
      'isBot': isBot,
      'isDealer': isDealer,
      'partnerId': partnerId,
      'score': score,
      'bid': bid,
      'tricksWon': tricksWon,
      'hand': _hand.map((c) => c.toMap()).toList(),
    };
  }

  /// Creates a Player from a Firestore map
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as int,
      name: map['name'] as String,
      teamId: map['teamId'] as int,
      isBot: map['isBot'] ?? false,
      isDealer: map['isDealer'] ?? false,
      partnerId: map['partnerId'],
    )
      ..score = map['score'] ?? 0
      ..bid = map['bid'] ?? 0
      ..tricksWon = map['tricksWon'] ?? 0
      .._hand.addAll(
        (map['hand'] as List<dynamic>? ?? [])
            .map((c) => Card29.fromMap(Map<String, dynamic>.from(c))),
      );
  }

  // --- Overrides ---

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Player && id == other.id);

  @override
  int get hashCode => id.hashCode;
}