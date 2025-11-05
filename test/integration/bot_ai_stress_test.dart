import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/services/bot_ai.dart';
import 'package:twenty_nine_card_game/models/card29.dart' as model;
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';

void main() {
  group('BotAI stress tests', () {
    test('100 simulated games run without crashes', () {
      for (int game = 0; game < 100; game++) {
        // Create four players with different personalities
        final players = [
          Player(
            id: 1,
            name: 'AggroBot',
            teamId: 1,
            loginMethod: LoginMethod.guest,
            connectionType: ConnectionType.local,
          ),
          Player(
            id: 2,
            name: 'CarefulBot',
            teamId: 1,
            loginMethod: LoginMethod.guest,
            connectionType: ConnectionType.local,
          ),
          Player(
            id: 3,
            name: 'LogicBot',
            teamId: 2,
            loginMethod: LoginMethod.guest,
            connectionType: ConnectionType.local,
          ),
          Player(
            id: 4,
            name: 'FallbackBot',
            teamId: 2,
            loginMethod: LoginMethod.guest,
            connectionType: ConnectionType.local,
          ),
        ];

        // Assign simple hands (3 cards each for stress test)
        players[0].setHandForTest([
          const model.Card29(model.Suit.spades, model.Rank.ace),
          const model.Card29(model.Suit.hearts, model.Rank.king),
          const model.Card29(model.Suit.clubs, model.Rank.seven),
        ]);
        players[1].setHandForTest([
          const model.Card29(model.Suit.spades, model.Rank.seven),
          const model.Card29(model.Suit.hearts, model.Rank.seven),
          const model.Card29(model.Suit.clubs, model.Rank.king),
        ]);
        players[2].setHandForTest([
          const model.Card29(model.Suit.diamonds, model.Rank.ace),
          const model.Card29(model.Suit.spades, model.Rank.king),
          const model.Card29(model.Suit.hearts, model.Rank.nine),
        ]);
        players[3].setHandForTest([
          const model.Card29(model.Suit.clubs, model.Rank.ace),
          const model.Card29(model.Suit.diamonds, model.Rank.king),
          const model.Card29(model.Suit.spades, model.Rank.nine),
        ]);

        final state = GameState(players, trump: model.Suit.spades);

        final bots = [
          BotAI(BotPersonality.aggressive),
          BotAI(BotPersonality.cautious),
          BotAI(BotPersonality.logical),
          BotAI(BotPersonality.logical),
        ];

        // Each player plays all their cards
        for (int round = 0; round < 3; round++) {
          for (int i = 0; i < players.length; i++) {
            final player = players[i];
            if (player.hand.isNotEmpty) {
              final chosen = bots[i].playCard(state, player);

              // ✅ Assertions: chosen card must be legal and in hand
              expect(state.isLegalMove(chosen), isTrue);
              expect(player.hand.contains(chosen), isTrue);

              // Simulate playing the card
              player.playCard(chosen);
            }
          }
        }

        // ✅ After 3 rounds, all hands should be empty
        for (final p in players) {
          expect(p.hand, isEmpty);
        }
      }
    });
  });
}
