import 'dart:async';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/card.dart';

void main() {
  group('Stress test with rotating leader', () {
    late List<Player> players;
    late GameState gameState;

    final rng = Random(42); // fixed seed for reproducibility

    // Build a reduced deck (J, 9, A, 10, K, Q of each suit)
    List<Card29> buildDeck() {
      const suits = [Suit.hearts, Suit.spades, Suit.clubs, Suit.diamonds];
      const ranks = [
        Rank.jack,
        Rank.nine,
        Rank.ace,
        Rank.ten,
        Rank.king,
        Rank.queen,
      ];
      return [
        for (final s in suits)
          for (final r in ranks) Card29(s, r),
      ];
    }

    void shuffle<T>(List<T> list) {
      for (int i = list.length - 1; i > 0; i--) {
        final j = rng.nextInt(i + 1);
        final tmp = list[i];
        list[i] = list[j];
        list[j] = tmp;
      }
    }

    void dealHands(List<Card29> deck, int perPlayer) {
      for (final p in players) {
        p.clearHand();
      }
      int index = 0;
      for (int i = 0; i < perPlayer; i++) {
        for (final p in players) {
          p.addCard(deck[index++]);
        }
      }
    }

    Suit randomSuit() {
      const suits = [Suit.hearts, Suit.spades, Suit.clubs, Suit.diamonds];
      return suits[rng.nextInt(suits.length)];
    }

    Map<Player, int> randomBids() {
      final bids = <Player, int>{};
      for (final p in players) {
        if (rng.nextBool()) {
          bids[p] = 16 + rng.nextInt(6); // 16–21
        }
      }
      if (bids.isEmpty) {
        final p = players[rng.nextInt(players.length)];
        bids[p] = 16 + rng.nextInt(6);
      }
      return bids;
    }

    setUp(() {
      players = [
        Player(id: 1, name: 'Alice', teamId: 1),
        Player(id: 2, name: 'Bob', teamId: 2),
        Player(id: 3, name: 'Charlie', teamId: 1),
        Player(id: 4, name: 'Dave', teamId: 2),
      ];
      gameState = GameState(players);
    });

    test('simulate 20 rounds with rotating leader', () {
      const rounds = 20;
      const cardsPerPlayer = 6;

      for (int round = 1; round <= rounds; round++) {
        // --- Bidding ---
        final bids = randomBids();
        gameState.conductBidding(bids);
        expect(gameState.highestBidder, isNotNull);

        // --- Trump ---
        final trump = randomSuit();
        gameState.revealTrump(trump);

        // --- Deal ---
        final deck = buildDeck();
        shuffle(deck);
        dealHands(deck, cardsPerPlayer);

        // Start with Alice as leader
        Player leader = players[0];

        // --- Play all tricks ---
        for (int t = 0; t < cardsPerPlayer; t++) {
          final tricksBefore = players.fold<int>(
            0,
            (sum, p) => sum + p.tricksWon,
          );

          final startIndex = players.indexOf(leader);
          final order = [
            ...players.sublist(startIndex),
            ...players.sublist(0, startIndex),
          ];

          for (final p in order) {
            final idx = rng.nextInt(p.hand.length);
            final card = p.hand[idx];
            gameState.playCard(p, card);
          }

          final tricksAfter = players.fold<int>(
            0,
            (sum, p) => sum + p.tricksWon,
          );
          expect(
            tricksAfter,
            equals(tricksBefore + 1),
            reason: 'Each completed trick should increment total tricks by 1',
          );

          final trick = gameState.tricksHistory.last;
          final winner = trick.determineWinner(gameState.trump);
          expect(winner, isNotNull);

          leader = winner!;
        }

        // --- Update scores ---
        gameState.updateTeamScores();
        expect(gameState.teamScores.length, equals(2));

        // ✅ Rule-based bidding outcome
        expect(gameState.highestBidder, isNotNull);
        final biddingTeam = gameState.highestBidder!.teamId;
        final biddingTarget = gameState.targetScore;
        final biddingScore = gameState.teamScores[biddingTeam] ?? 0;
        expect(
          gameState.didBiddingTeamWin(),
          equals(biddingScore >= biddingTarget),
        );

        // --- Print round summary ---
        final printLog = <String>[];
        final spec = ZoneSpecification(
          print: (_, _, _, msg) {
            printLog.add(msg);
          },
        );
        Zone.current.fork(specification: spec).run(() {
          gameState.printRoundSummary();
        });
        expect(
          printLog.join('\n'),
          contains('Round $round'),
          reason: 'Round $round summary should be printed',
        );

        // --- Reset for next round ---
        gameState.startNewRound();
        expect(gameState.roundNumber, equals(round + 1));
        for (final p in players) {
          expect(p.tricksWon, equals(0));
          expect(p.hand, isEmpty);
        }
        expect(gameState.trump, isNull);
        expect(gameState.trumpRevealed, isFalse);
        expect(
          gameState.teamScores.length,
          equals(2),
          reason: 'Team scores should persist across rounds',
        );
        expect(gameState.tricksHistory, isEmpty);
      }

      // --- Final invariant after all rounds ---
      expect(gameState.roundNumber, equals(rounds + 1));
      expect(gameState.tricksHistory, isEmpty);
    });
  });
}
