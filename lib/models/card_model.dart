enum Suit { clubs, diamonds, hearts, spades }

class CardModel {
  final int rank; // 1–13 (Ace = 1, Jack = 11, Queen = 12, King = 13)
  final Suit suit;

  const CardModel({required this.rank, required this.suit});

  String get rankLabel {
    switch (rank) {
      case 1: return 'A';
      case 11: return 'J';
      case 12: return 'Q';
      case 13: return 'K';
      default: return rank.toString();
    }
  }

  String get suitLabel {
    switch (suit) {
      case Suit.clubs: return 'clubs';
      case Suit.diamonds: return 'diamonds';
      case Suit.hearts: return 'hearts';
      case Suit.spades: return 'spades';
    }
  }

  String get imagePath => 'assets/cards/${rankLabel.toLowerCase()}_$suitLabel.png';

  bool get isFaceCard => rank >= 11 && rank <= 13;
  bool get isRedSuit => suit == Suit.hearts || suit == Suit.diamonds;

  @override
  String toString() => '$rankLabel of $suitLabel';
}