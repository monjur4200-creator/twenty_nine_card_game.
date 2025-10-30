import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/services/bot_ai.dart';
import 'package:twenty_nine_card_game/models/card.dart' as model;
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/trick.dart';

void main() {
  group('BotAI multi-round integration', () {
    test('Bots play multiple tricks, scores update, and round resets', () {
      // Players
      final aggro = Player(id: 1, name: 'AggroBot', teamId: 1);
      final cautious = Player(id: 2, name: 'CarefulBot', teamId: 1);
      final logical = Player(id: 3, name: 'LogicBot', teamId: 2);

      // Assign initial hands
      aggro.setHandForTest([
        model.Card29(model.Suit.spades, model.Rank.ace),
        model.Card29(model.Suit.hearts, model.Rank.king),
      ]);
      cautious.setHandForTest([
        model.Card29(model.Suit.spades, model.Rank.seven),
        model.Card29(model.Suit.hearts, model.Rank.seven),
      ]);
      logical.setHandForTest([
        model.Card29(model.Suit.clubs, model.Rank.ace),
        model.Card29(model.Suit.diamonds, model.Rank.king),
      ]);

      // Game state with trump = spades
      final state = GameState([aggro, cautious, logical], trump: model.Suit.spades);

      // Bots
      final aggroBot = BotAI(BotPersonality.aggressive);
      final cautiousBot = BotAI(BotPersonality.cautious);
      final logicalBot = BotAI(BotPersonality.logical);

      // --- Trick 1 ---
      final trick1 = Trick(turnOrder: [aggro, cautious, logical]);
      trick1.addPlay(aggro, aggroBot.playCard(state, aggro));
      trick1.addPlay(cautious, cautiousBot.playCard(state, cautious));
      trick1.addPlay(logical, logicalBot.playCard(state, logical));

      final winner1 = trick1.determineWinner(state.trump);
      expect(winner1, isNotNull);
      winner1!.incrementTricksWon();
      winner1.incrementScore(trick1.totalPoints());

      // --- Trick 2 ---
      final trick2 = Trick(turnOrder: [aggro, cautious, logical]);
      trick2.addPlay(aggro, aggroBot.playCard(state, aggro));
      trick2.addPlay(cautious, cautiousBot.playCard(state, cautious));
      trick2.addPlay(logical, logicalBot.playCard(state, logical));

      final winner2 = trick2.determineWinner(state.trump);
      expect(winner2, isNotNull);
      winner2!.incrementTricksWon();
      winner2.incrementScore(trick2.totalPoints());

      // ✅ Assertions after two tricks
      expect(aggro.tricksWon + cautious.tricksWon + logical.tricksWon, equals(2));
      expect(aggro.score + cautious.score + logical.score,
          equals(trick1.totalPoints() + trick2.totalPoints()));

      // --- Reset for new round ---
      aggro.resetForNewRound();
      cautious.resetForNewRound();
      logical.resetForNewRound();

      expect(aggro.hand, isEmpty);
      expect(cautious.hand, isEmpty);
      expect(logical.hand, isEmpty);
      expect(aggro.tricksWon, equals(0));
      expect(cautious.tricksWon, equals(0));
      expect(logical.tricksWon, equals(0));
      // Scores persist across rounds
      expect(aggro.score + cautious.score + logical.score,
          equals(trick1.totalPoints() + trick2.totalPoints()));
    });
  });
}
