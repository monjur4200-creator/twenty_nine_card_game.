import 'dart:async'; // Needed for ZoneSpecification and Zone
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/card.dart';
import '../test_utils.dart';

void main() {
  group('GameState', () {
    late List<Player> players;
    late GameState gameState;

    // 🔹 Helper to make tests cleaner
    void giveCard(Player player, Card29 card) {
      player.addCard(card);
    }

    setUp(() {
      players = [
        Player(id: 1, name: 'Alice', teamId: 1),
        Player(id: 2, name: 'Bob', teamId: 2),
      ];
      gameState = GameState(players);
    });

    group('Round Management', () {
      test(
        'startNewRound resets per-round state but preserves cumulative score',
        () {
          players[0].score = 10;
          players[0].tricksWon = 2;
          gameState.trump = Suit.hearts;
          gameState.trumpRevealed = true;

          gameState.startNewRound();

          // ✅ Score persists across rounds
          expect(players[0].score, equals(10));
          // ✅ Per-round state resets
          expect(players[0].tricksWon, equals(0));
          expect(gameState.trump, isNull);
          expect(gameState.trumpRevealed, isFalse);
          expect(gameState.roundNumber, equals(2));
          expect(gameState.tricksHistory, isEmpty);
        },
      );
    });

    group('Bidding', () {
      test('conductBidding sets highestBidder and targetScore', () {
        gameState.conductBidding({players[0]: 16, players[1]: 18});

        expect(gameState.highestBidder, equals(players[1]));
        expect(gameState.targetScore, equals(18));
      });

      test('conductBidding throws if no bids placed', () {
        // ✅ Match actual implementation (throws ArgumentError)
        expect(() => gameState.conductBidding({}), throwsArgumentError);
      });
    });

    group('Trump', () {
      test('revealTrump sets trump and marks revealed', () {
        gameState.revealTrump(Suit.spades);

        expect(gameState.trump, equals(Suit.spades));
        expect(gameState.trumpRevealed, isTrue);
      });

      test('revealTrump throws if called twice', () {
        gameState.revealTrump(Suit.clubs);
        // ✅ Match actual implementation (throws ArgumentError)
        expect(() => gameState.revealTrump(Suit.spades), throwsArgumentError);
      });
    });

    group('Scoring', () {
      test('updateTeamScores aggregates player scores', () {
        players[0].score = 10;
        players[1].score = 5;

        gameState.updateTeamScores();

        expect(gameState.teamScores[1], equals(10));
        expect(gameState.teamScores[2], equals(5));
      });

      test('didBiddingTeamWin matches rule-based outcome', () {
        gameState.conductBidding({players[0]: 20, players[1]: 18});

        players[0].score = 20;
        players[1].score = 10;

        gameState.updateTeamScores();

        final biddingTeam = gameState.highestBidder!.teamId;
        final biddingTarget = gameState.targetScore;
        final biddingScore = gameState.teamScores[biddingTeam] ?? 0;

        expect(
          gameState.didBiddingTeamWin(),
          equals(biddingScore >= biddingTarget),
        );
      });
    });

    group('Serialization', () {
      test('toMap and fromMap round-trip preserves state', () {
        players[0].score = 12;
        players[1].score = 8;
        gameState.updateTeamScores();

        final map = gameState.toMap();
        final restored = GameState.fromMap(map, players);

        expect(restored.roundNumber, equals(gameState.roundNumber));
        expect(restored.teamScores[1], equals(12));
        expect(restored.teamScores[2], equals(8));
      });
    });

    group('Gameplay', () {
      test('playCard completes a trick and awards winner', () {
        final alice = players[0];
        final bob = players[1];

        final card1 = Card29(Suit.hearts, Rank.nine);
        final card2 = Card29(Suit.hearts, Rank.jack);

        giveCard(alice, card1);
        giveCard(bob, card2);

        final tricksBefore = players.fold<int>(
          0,
          (sum, p) => sum + p.tricksWon,
        );

        gameState.playCard(alice, card1);
        gameState.playCard(bob, card2);

        final tricksAfter = players.fold<int>(0, (sum, p) => sum + p.tricksWon);
        expect(tricksAfter, equals(tricksBefore + 1));

        final trick = gameState.tricksHistory.first;
        expect(trick.plays.length, equals(2));
      });

      test('multiple tricks accumulate in history and scores', () {
        final alice = players[0];
        final bob = players[1];

        final card1 = Card29(Suit.hearts, Rank.nine);
        final card2 = Card29(Suit.hearts, Rank.jack);
        final card3 = Card29(Suit.spades, Rank.ace);
        final card4 = Card29(Suit.spades, Rank.ten);

        alice.addCards([card1, card3]);
        bob.addCards([card2, card4]);

        gameState.playCard(alice, card1);
        gameState.playCard(bob, card2);

        gameState.playCard(alice, card3);
        gameState.playCard(bob, card4);

        expect(gameState.tricksHistory.length, equals(2));

        expect(bob.tricksWon, equals(1));
        expect(alice.tricksWon, equals(1));

        expect(bob.score > 0, isTrue);
        expect(alice.score > 0, isTrue);
      });

      test('playCard throws if player does not have the card', () {
        final alice = players[0];
        final invalidCard = Card29(Suit.diamonds, Rank.king);

        // ✅ Match actual implementation (throws ArgumentError)
        expect(
          () => gameState.playCard(alice, invalidCard),
          throwsCardNotInHand(),
        );
      });
    });

    group('Output', () {
      test('printRoundSummary outputs correct information', () {
        players[0].score = 15;
        players[0].tricksWon = 2;
        players[1].score = 10;
        players[1].tricksWon = 1;
        gameState.updateTeamScores();

        final printLog = <String>[];
        final spec = ZoneSpecification(
          print: (_, _, _, msg) {
            printLog.add(msg);
          },
        );

        Zone.current.fork(specification: spec).run(() {
          gameState.printRoundSummary();
        });

        final log = printLog.join('\n');
        expect(log, contains('Alice: Tricks 2, Score 15'));
        expect(log, contains('Bob: Tricks 1, Score 10'));
        expect(log, contains('Team Scores: {1: 15, 2: 10}'));
      });
    });
  });
}
