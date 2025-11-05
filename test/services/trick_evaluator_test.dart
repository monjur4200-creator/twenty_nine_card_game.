import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/card29.dart';
import 'package:twenty_nine_card_game/services/trick_evaluator.dart';

void main() {
  group('TrickEvaluator', () {
    final evaluator = TrickEvaluator(trumpSuit: Suit.hearts);

    test('highest trump wins', () {
      final pile = [
        const Card29(Suit.hearts, Rank.nine),
        const Card29(Suit.hearts, Rank.jack),
        const Card29(Suit.spades, Rank.ace),
      ];
      final winner = evaluator.determineWinner(pile);
      expect(winner, equals("Unknown")); // J > 9 in trump
    });

    test('highest of leading suit wins if no trump', () {
      final pile = [
        const Card29(Suit.clubs, Rank.ten),
        const Card29(Suit.clubs, Rank.ace),
        const Card29(Suit.spades, Rank.king),
      ];
      final winner = evaluator.determineWinner(pile);
      expect(winner, equals("Unknown")); // A > 10 in leading suit
    });

    test('returns "No one" if pile empty', () {
      final winner = evaluator.determineWinner([]);
      expect(winner, equals("No one"));
    });

    test('trump beats higher leading suit card', () {
      final pile = [
        const Card29(Suit.clubs, Rank.ace),
        const Card29(Suit.hearts, Rank.nine),
        const Card29(Suit.clubs, Rank.king),
      ];
      final winner = evaluator.determineWinner(pile);
      expect(winner, equals("Unknown")); // trump 9 beats leading A
    });

    test('highest of trump suit wins among trump cards', () {
      final pile = [
        const Card29(Suit.hearts, Rank.nine),
        const Card29(Suit.hearts, Rank.king),
        const Card29(Suit.hearts, Rank.jack),
      ];
      final winner = evaluator.determineWinner(pile);
      expect(winner, equals("Unknown")); // J > K > 9
    });

    test('non-trump, non-leading suit cards are ignored', () {
      final pile = [
        const Card29(Suit.clubs, Rank.nine),
        const Card29(Suit.spades, Rank.ace),
        const Card29(Suit.diamonds, Rank.king),
      ];
      final winner = evaluator.determineWinner(pile);
      expect(winner, equals("Unknown")); // only clubs considered
    });
  });
}
