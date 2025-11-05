enum Suit { hearts, diamonds, clubs, spades }

enum Rank { seven, eight, nine, ten, jack, queen, king, ace }

class Card29 {
  final Suit suit;
  final Rank rank;
  final bool isTrump;
  final bool isPlayed;

  /// Optional: used to track who played the card
  final String? owner;

  const Card29(
    this.suit,
    this.rank, {
    this.isTrump = false,
    this.isPlayed = false,
    this.owner,
  });

  /// Points based on Twenty-Nine rules
  int get points {
    switch (rank) {
      case Rank.jack:
        return 3;
      case Rank.nine:
        return 2;
      case Rank.ace:
      case Rank.ten:
        return 1;
      default:
        return 0; // 7, 8, Q, K
    }
  }

  /// ✅ FIXED: owner is a String, not an object with `.name`
  String get ownerName => owner ?? 'Unknown';

  String get displayName => '$rank of $suit';

  /// Backward compatibility for tests
  int get pointValue => points;

  /// Generate a full deck of 32 cards (7–Ace in each suit)
  static List<Card29> fullDeck() {
    return [
      for (final suit in Suit.values)
        for (final rank in Rank.values) Card29(suit, rank),
    ];
  }

  /// Create a copy with updated flags or owner
  Card29 copyWith({bool? isTrump, bool? isPlayed, String? owner}) {
    return Card29(
      suit,
      rank,
      isTrump: isTrump ?? this.isTrump,
      isPlayed: isPlayed ?? this.isPlayed,
      owner: owner ?? this.owner,
    );
  }

  /// Compare cards by suit index then rank value (for sorting only)
  int compareTo(Card29 other) {
    final suitDiff = suit.index - other.suit.index;
    return suitDiff != 0 ? suitDiff : rank.value - other.rank.value;
  }

  /// Converts this card into a Firestore-friendly map
  Map<String, dynamic> toMap() => {
        'suit': suit.name,
        'rank': rank.name,
        'isTrump': isTrump,
        'isPlayed': isPlayed,
        if (owner != null) 'owner': owner,
      };

  /// Creates a Card29 from a Firestore map
  factory Card29.fromMap(Map<String, dynamic> map) {
    return Card29(
      Suit.values.byName(map['suit'] as String),
      Rank.values.byName(map['rank'] as String),
      isTrump: map['isTrump'] as bool? ?? false,
      isPlayed: map['isPlayed'] as bool? ?? false,
      owner: map['owner'] as String?,
    );
  }

  @override
  String toString() {
    const suitSymbols = {
      Suit.hearts: '♥',
      Suit.diamonds: '♦',
      Suit.clubs: '♣',
      Suit.spades: '♠',
    };
    const rankLabels = {
      Rank.seven: '7',
      Rank.eight: '8',
      Rank.nine: '9',
      Rank.ten: '10',
      Rank.jack: 'J',
      Rank.queen: 'Q',
      Rank.king: 'K',
      Rank.ace: 'A',
    };
    return '${rankLabels[rank]}${suitSymbols[suit]}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Card29 && suit == other.suit && rank == other.rank);

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;
}

/// Extension to give Rank numeric values for comparison
extension RankValue on Rank {
  int get value {
    switch (this) {
      case Rank.seven:
        return 7;
      case Rank.eight:
        return 8;
      case Rank.nine:
        return 9;
      case Rank.ten:
        return 10;
      case Rank.jack:
        return 11;
      case Rank.queen:
        return 12;
      case Rank.king:
        return 13;
      case Rank.ace:
        return 14;
    }
  }
}