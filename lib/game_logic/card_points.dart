import '../models/card29.dart';

/// Returns the standard point value of a card.
int getCardPoint(Card29 card) {
  switch (card.rank) {
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

/// Returns the strength index of a rank for trick comparison.
int getRankStrength(Rank rank) {
  const rankOrder = [
    Rank.jack,
    Rank.nine,
    Rank.ace,
    Rank.ten,
    Rank.king,
    Rank.queen,
    Rank.eight,
    Rank.seven,
  ];
  return rankOrder.indexOf(rank);
}

/// Calculates total points for a team, including trump bonuses.
/// Trump bonus only applies if trump is revealed and K/Q were held until then.
int calculateTeamPoints({
  required List<Card29> wonCards,
  required Suit trumpSuit,
  required bool isBiddingTeam,
  required bool trumpRevealed,
  required bool biddingTeamHeldTrumpK,
  required bool biddingTeamHeldTrumpQ,
}) {
  int total = 0;
  int trumpBonus = 0;

  for (final card in wonCards) {
    total += getCardPoint(card);
  }

  if (trumpRevealed) {
    if (isBiddingTeam) {
      if (biddingTeamHeldTrumpK) trumpBonus += 4;
      if (biddingTeamHeldTrumpQ) trumpBonus += 4;
    } else {
      if (biddingTeamHeldTrumpK) trumpBonus -= 4;
      if (biddingTeamHeldTrumpQ) trumpBonus -= 4;
    }
  }

  return total + trumpBonus;
}
