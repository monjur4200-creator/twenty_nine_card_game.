enum Suit { hearts, diamonds, clubs, spades }
enum Rank { seven, eight, nine, ten, jack, queen, king, ace }

class Card29 {
  final Suit suit;
  final Rank rank;

  Card29(this.suit, this.rank);

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

  static List<Card29> fullDeck() {
    return Suit.values
        .expand((suit) => Rank.values.map((rank) => Card29(suit, rank)))
        .toList();
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