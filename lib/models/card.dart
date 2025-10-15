enum Suit { hearts, diamonds, clubs, spades }

enum Rank { seven, eight, nine, ten, jack, queen, king, ace }

class Card29 {
  final Suit suit;
  final Rank rank;

  bool isTrump = false;
  bool isPlayed = false;

  Card29(this.suit, this.rank);

  /// Points based on Twenty Nine rules
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
        return 0;
    }
  }

  /// Generate a full deck of 32 cards
  static List<Card29> fullDeck() {
    return Suit.values
        .expand((suit) => Rank.values.map((rank) => Card29(suit, rank)))
        .toList();
  }

  /// Create a copy with updated flags
  Card29 copyWith({bool? isTrump, bool? isPlayed}) {
    final copy = Card29(suit, rank);
    copy.isTrump = isTrump ?? this.isTrump;
    copy.isPlayed = isPlayed ?? this.isPlayed;
    return copy;
  }

  /// Compare cards by suit then rank
  int compareTo(Card29 other) {
    if (suit != other.suit) return suit.index - other.suit.index;
    return rank.value - other.rank.value; // 🆕 uses RankValue extension
  }

  @override
  String toString() {
    const suitSymbols = {
      Suit.hearts: "♥",
      Suit.diamonds: "♦",
      Suit.clubs: "♣",
      Suit.spades: "♠",
    };
    const rankLabels = {
      Rank.seven: "7",
      Rank.eight: "8",
      Rank.nine: "9",
      Rank.ten: "10",
      Rank.jack: "J",
      Rank.queen: "Q",
      Rank.king: "K",
      Rank.ace: "A",
    };
    return "${rankLabels[rank]}${suitSymbols[suit]}";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Card29 && suit == other.suit && rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;
}

/// 🆕 Extension to give Rank numeric values for comparison
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