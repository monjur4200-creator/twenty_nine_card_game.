import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/card29.dart';
import 'package:twenty_nine_card_game/game_logic/card_points.dart';

void main() {
  group('Card Point Logic', () {
    test('Standard point values', () {
      expect(getCardPoint(const Card29(Suit.hearts, Rank.jack)), equals(3));
      expect(getCardPoint(const Card29(Suit.hearts, Rank.nine)), equals(2));
      expect(getCardPoint(const Card29(Suit.hearts, Rank.ace)), equals(1));
      expect(getCardPoint(const Card29(Suit.hearts, Rank.ten)), equals(1));
      expect(getCardPoint(const Card29(Suit.hearts, Rank.king)), equals(0));
      expect(getCardPoint(const Card29(Suit.hearts, Rank.queen)), equals(0));
      expect(getCardPoint(const Card29(Suit.hearts, Rank.eight)), equals(0));
      expect(getCardPoint(const Card29(Suit.hearts, Rank.seven)), equals(0));
    });

    test('Rank strength order', () {
      expect(getRankStrength(Rank.jack), lessThan(getRankStrength(Rank.nine)));
      expect(getRankStrength(Rank.nine), lessThan(getRankStrength(Rank.ace)));
      expect(getRankStrength(Rank.ace), lessThan(getRankStrength(Rank.ten)));
      expect(getRankStrength(Rank.ten), lessThan(getRankStrength(Rank.king)));
      expect(getRankStrength(Rank.king), lessThan(getRankStrength(Rank.queen)));
      expect(getRankStrength(Rank.queen), lessThan(getRankStrength(Rank.eight)));
      expect(getRankStrength(Rank.eight), lessThan(getRankStrength(Rank.seven)));
    });

    test('Trump bonus for bidding team after reveal', () {
      final pile = [
        const Card29(Suit.hearts, Rank.jack),
        const Card29(Suit.hearts, Rank.king),
        const Card29(Suit.hearts, Rank.queen),
        const Card29(Suit.spades, Rank.ace),
      ];

      final score = calculateTeamPoints(
        wonCards: pile,
        trumpSuit: Suit.hearts,
        isBiddingTeam: true,
        trumpRevealed: true,
        biddingTeamHeldTrumpK: true,
        biddingTeamHeldTrumpQ: true,
      );

      // 3 (J) + 0 (K) + 0 (Q) + 1 (A) + 4 + 4 = 12
      expect(score, equals(12));
    });

    test('No trump bonus if trump not revealed', () {
      final pile = [
        const Card29(Suit.hearts, Rank.king),
        const Card29(Suit.hearts, Rank.queen),
      ];

      final score = calculateTeamPoints(
        wonCards: pile,
        trumpSuit: Suit.hearts,
        isBiddingTeam: true,
        trumpRevealed: false,
        biddingTeamHeldTrumpK: true,
        biddingTeamHeldTrumpQ: true,
      );

      expect(score, equals(0));
    });

    test('Trump bonus penalizes bidding team if opponent holds K/Q', () {
      final pile = [
        const Card29(Suit.hearts, Rank.king),
        const Card29(Suit.hearts, Rank.queen),
      ];

      final score = calculateTeamPoints(
        wonCards: pile,
        trumpSuit: Suit.hearts,
        isBiddingTeam: false,
        trumpRevealed: true,
        biddingTeamHeldTrumpK: true,
        biddingTeamHeldTrumpQ: true,
      );

      expect(score, equals(-8));
    });
  });
}
