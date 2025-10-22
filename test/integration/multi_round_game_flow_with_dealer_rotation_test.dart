import 'dart:async';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/card.dart';

void main() {
  group('Multi-Round Game Flow Integration (with dealer rotation)', () {
    late List<Player> players;
    late GameState gameState;
    final rng = Random(42);

    setUp(() {
      players = [
        Player(id: 1, name: 'Alice', teamId: 1),
        Player(id: 2, name: 'Bob', teamId: 2),
        Player(id: 3, name: 'Charlie', teamId: 1),
        Player(id: 4, name: 'Dave', teamId: 2),
      ];
      gameState = GameState(players);
    });

    // Helper: rotate dealer to the right
    Player rotateDealerRight(Player currentDealer) {
      final index = players.indexOf(currentDealer);
      return players[(index - 1 + players.length) % players.length];
    }

    test('simulate two rounds with dealer rotation', () {
      const totalRounds = 2;
      Player dealer = players[2]; // Start with Charlie

      for (int round = 1; round <= totalRounds; round++) {
        // --- Bidding ---
        gameState.conductBidding({
          for (final p in players) p: 16 + rng.nextInt(6),
        });
        expect(gameState.highestBidder, isNotNull);

        // --- Trump ---
        gameState.revealTrump(Suit.values[rng.nextInt(Suit.values.length)]);

        // --- Deal one card each ---
        final cards = [
          Card29(Suit.hearts, Rank.nine),
          Card29(Suit.spades, Rank.jack),
          Card29(Suit.clubs, Rank.ace),
          Card29(Suit.diamonds, Rank.ten),
        ];
        for (int i = 0; i < players.length; i++) {
          players[i].addCard(cards[i]);
        }

        // --- Play one trick ---
        for (final p in players) {
          final card = p.hand.first;
          gameState.playCard(p, card);
        }
        expect(gameState.tricksHistory.isNotEmpty, isTrue);

        // --- Update scores ---
        gameState.updateTeamScores();
        expect(gameState.teamScores.length, equals(2));

        // --- Print round summary ---
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

        // --- Prepare for next round ---
        gameState.startNewRound();
        expect(gameState.roundNumber, equals(round + 1));

        // Rotate dealer
        dealer = rotateDealerRight(dealer);
      }

      // --- Finalize game ---
      gameState.finalizeGame();

      // --- Final assertions ---
      expect(
        gameState.roundNumber,
        equals(totalRounds + 1),
        reason:
            'Expected roundNumber=${totalRounds + 1}, got ${gameState.roundNumber}',
      );

      expect(
        gameState.tricksHistory.isEmpty,
        isTrue,
        reason:
            'Expected tricksHistory empty, got length=${gameState.tricksHistory.length}',
      );
    });
  });
}
