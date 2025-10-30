import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/services/bot_ai.dart';
import 'package:twenty_nine_card_game/models/card.dart' as model;
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/trick.dart';

void main() {
  group('BotAI full trick integration', () {
    test('Aggressive, Cautious, and Logical bots play into a trick and a winner is determined', () {
      // Players
      final aggro = Player(id: 1, name: 'AggroBot', teamId: 1);
      final cautious = Player(id: 2, name: 'CarefulBot', teamId: 1);
      final logical = Player(id: 3, name: 'LogicBot', teamId: 2);

      // Hands
      aggro.setHandForTest([
        model.Card29(model.Suit.spades, model.Rank.seven),
        model.Card29(model.Suit.spades, model.Rank.ace),
      ]);
      cautious.setHandForTest([
        model.Card29(model.Suit.hearts, model.Rank.seven),
        model.Card29(model.Suit.hearts, model.Rank.king),
      ]);
      logical.setHandForTest([
        model.Card29(model.Suit.clubs, model.Rank.seven),
        model.Card29(model.Suit.clubs, model.Rank.king),
      ]);

      // Game state with trump = spades
      final state = GameState([aggro, cautious, logical], trump: model.Suit.spades);

      // Bots
      final aggroBot = BotAI(BotPersonality.aggressive);
      final cautiousBot = BotAI(BotPersonality.cautious);
      final logicalBot = BotAI(BotPersonality.logical);

      // Trick
      final trick = Trick(turnOrder: [aggro, cautious, logical]);

      // Each bot plays
      final aggroChoice = aggroBot.playCard(state, aggro);
      trick.addPlay(aggro, aggroChoice);

      final cautiousChoice = cautiousBot.playCard(state, cautious);
      trick.addPlay(cautious, cautiousChoice);

      final logicalChoice = logicalBot.playCard(state, logical);
      trick.addPlay(logical, logicalChoice);

      // ✅ Assertions
      expect(aggroChoice.rank, equals(model.Rank.ace)); // Aggressive plays Ace of Spades
      expect(cautiousChoice.rank, equals(model.Rank.seven)); // Cautious plays lowest
      expect(logicalChoice.rank, equals(model.Rank.seven)); // Logical falls back to lowest

      // Determine winner
      final winner = trick.determineWinner(state.trump);

      // With trump = spades, AggroBot’s Ace of Spades should win
      expect(winner, equals(aggro));
    });
  });
}
