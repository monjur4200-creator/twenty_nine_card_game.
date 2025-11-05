import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/card29.dart';
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';

void main() {
  test(
    'Multiplayer sync: trick winner and animation state match across devices',
    () {
      final playersDeviceA = [
        Player(id: 1, name: 'Mongur', teamId: 1, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
        Player(id: 2, name: 'Rafi', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
        Player(id: 3, name: 'Tuli', teamId: 1, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
        Player(id: 4, name: 'Nayeem', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
      ];

      final playersDeviceB = [
        Player(id: 1, name: 'Mongur', teamId: 1, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
        Player(id: 2, name: 'Rafi', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
        Player(id: 3, name: 'Tuli', teamId: 1, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
        Player(id: 4, name: 'Nayeem', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
      ];

      final gameA = GameState(playersDeviceA)..startNewRound();
      final gameB = GameState(playersDeviceB)..startNewRound();

      gameA.conductBidding({playersDeviceA[0]: 17, playersDeviceA[1]: 20});
      gameB.conductBidding({playersDeviceB[0]: 17, playersDeviceB[1]: 20});

      gameA.revealTrump(Suit.spades);
      gameB.revealTrump(Suit.spades);

      final cards = [
        const Card29(Suit.spades, Rank.king),
        const Card29(Suit.spades, Rank.queen),
        const Card29(Suit.spades, Rank.jack),
        const Card29(Suit.spades, Rank.ten),
      ];

      for (int i = 0; i < 4; i++) {
        playersDeviceA[i].addCard(cards[i]);
        playersDeviceB[i].addCard(cards[i]);
        gameA.playCard(playersDeviceA[i], cards[i]);
        gameB.playCard(playersDeviceB[i], cards[i]);
      }

      final winnerA = gameA.getTrickWinner();
      final winnerB = gameB.getTrickWinner();

      expect(winnerA?.id, equals(winnerB?.id));
      expect(winnerA?.name, equals(winnerB?.name));

      final trickA = gameA.lastTrick;
      final trickB = gameB.lastTrick;

      if (trickA != null && trickB != null) {
        final cardsA = trickA.plays.values.toList();
        final cardsB = trickB.plays.values.toList();

        expect(cardsA.length, equals(cardsB.length));

        for (int i = 0; i < cardsA.length; i++) {
          expect(cardsA[i].toString(), equals(cardsB[i].toString()));
        }
      } else {
        fail('Trick data missing on one or both devices');
      }
    },
  );
}