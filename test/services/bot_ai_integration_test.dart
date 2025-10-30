import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/services/bot_ai.dart';
import 'package:twenty_nine_card_game/models/card.dart' as model;
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';

void main() {
  group('BotAI integration tests', () {
    test('Aggressive, Cautious, and Logical bots play into the same trick', () {
      // Create three players with different personalities
      final aggro = Player(id: 1, name: 'AggroBot', teamId: 1);
      final cautious = Player(id: 2, name: 'CarefulBot', teamId: 1);
      final logical = Player(id: 3, name: 'LogicBot', teamId: 2);

      // Give them hands
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

      // Instantiate bots
      final aggroBot = BotAI(BotPersonality.aggressive);
      final cautiousBot = BotAI(BotPersonality.cautious);
      final logicalBot = BotAI(BotPersonality.logical);

      // Each bot chooses a card
      final aggroChoice = aggroBot.playCard(state, aggro);
      final cautiousChoice = cautiousBot.playCard(state, cautious);
      final logicalChoice = logicalBot.playCard(state, logical);

      // ✅ Assertions
      // Aggressive should pick the Ace of Spades
      expect(aggroChoice.rank, equals(model.Rank.ace));
      expect(aggroChoice.suit, equals(model.Suit.spades));

      // Cautious should pick the Seven of Hearts
      expect(cautiousChoice.rank, equals(model.Rank.seven));
      expect(cautiousChoice.suit, equals(model.Suit.hearts));

      // Logical has no lead suit yet, no trump in hand, so should pick lowest card
      expect(logicalChoice.rank, equals(model.Rank.seven));
      expect(logicalChoice.suit, equals(model.Suit.clubs));
    });
  });
}
