import 'dart:async';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/card29.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';

void main() {
  group('Multi-Round Game Flow Integration (with dealer rotation)', () {
    late List<Player> players;
    late GameState gameState;
    final rng = Random(42);

    setUp(() {
      players = [
        Player(id: 1, name: 'Alice', teamId: 1, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
        Player(id: 2, name: 'Bob', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
        Player(id: 3, name: 'Charlie', teamId: 1, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
        Player(id: 4, name: 'Dave', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
      ];
      gameState = GameState(players);
    });

    Player rotateDealerRight(Player currentDealer) {
      final index = players.indexOf(currentDealer);
      return players[(index - 1 + players.length) % players.length];
    }

    test('simulate two rounds with dealer rotation', () {
      const totalRounds = 2;
      Player dealer = players[2]; // Start with Charlie

      for (int round = 1; round <= totalRounds; round++) {
        gameState.conductBidding({
          for (final p in players) p: 16 + rng.nextInt(6),
        });
        expect(gameState.highestBidder, isNotNull);

        gameState.revealTrump(Suit.values[rng.nextInt(Suit.values.length)]);

        final cards = [
          const Card29(Suit.hearts, Rank.nine),
          const Card29(Suit.spades, Rank.jack),
          const Card29(Suit.clubs, Rank.ace),
          const Card29(Suit.diamonds, Rank.ten),
        ];
        for (int i = 0; i < players.length; i++) {
          players[i].addCard(cards[i]);
        }

        for (final p in players) {
          final card = p.hand.first;
          gameState.playCard(p, card);
        }
        expect(gameState.tricksHistory.isNotEmpty, isTrue);

        gameState.updateTeamScores();
        expect(gameState.teamScores.length, equals(2));

        final printLog = <String>[];
        final spec = ZoneSpecification(
          print: (self, parent, zone, msg) {
            printLog.add(msg);
          },
        );
        Zone.current.fork(specification: spec).run(() {
          gameState.printRoundSummary();
        });
        expect(printLog, isNotEmpty);

        gameState.startNewRound();
        expect(gameState.roundNumber, equals(round + 1));

        dealer = rotateDealerRight(dealer);
      }

      gameState.finalizeGame();

      expect(
        gameState.roundNumber,
        equals(totalRounds + 1),
        reason: 'Expected roundNumber=${totalRounds + 1}, got ${gameState.roundNumber}',
      );

      expect(
        gameState.tricksHistory.isEmpty,
        isTrue,
        reason: 'Expected tricksHistory empty, got length=${gameState.tricksHistory.length}',
      );
    });
  });
}