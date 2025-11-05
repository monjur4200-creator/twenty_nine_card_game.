import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/services/bot_ai.dart';
import 'package:twenty_nine_card_game/models/card29.dart' as model;
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';

void main() {
  group('BotAI integration tests', () {
    test('Aggressive, Cautious, and Logical bots play into the same trick', () {
      // Create three players with different personalities
      final aggro = Player(
        id: 1,
        name: 'AggroBot',
        teamId: 1,
        loginMethod: LoginMethod.guest,
        connectionType: ConnectionType.local,
      );
      final cautious = Player(
        id: 2,
        name: 'CarefulBot',
        teamId: 1,
        loginMethod: LoginMethod.guest,
        connectionType: ConnectionType.local,
      );
      final logical = Player(
        id: 3,
        name: 'LogicBot',
        teamId: 2,
        loginMethod: LoginMethod.guest,
        connectionType: ConnectionType.local,
      );

      // Give them hands
      aggro.setHandForTest([
        const model.Card29(model.Suit.spades, model.Rank.seven),
        const model.Card29(model.Suit.spades, model.Rank.ace),
      ]);
      cautious.setHandForTest([
        const model.Card29(model.Suit.hearts, model.Rank.seven),
        const model.Card29(model.Suit.hearts, model.Rank.king),
      ]);
      logical.setHandForTest([
        const model.Card29(model.Suit.clubs, model.Rank.seven),
        const model.Card29(model.Suit.clubs, model.Rank.king),
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
      expect(aggroChoice.rank, equals(model.Rank.ace));
      expect(aggroChoice.suit, equals(model.Suit.spades));

      expect(cautiousChoice.rank, equals(model.Rank.seven));
      expect(cautiousChoice.suit, equals(model.Suit.hearts));

      expect(logicalChoice.rank, equals(model.Rank.seven));
      expect(logicalChoice.suit, equals(model.Suit.clubs));
    });
  });
}