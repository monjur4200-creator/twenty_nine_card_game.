import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/card29.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';

void main() {
  group('Multi-Round Game Flow Integration (with rotation)', () {
    late List<Player> players;
    late GameState gameState;

    setUp(() {
      players = [
        Player(id: 1, name: 'Alice', teamId: 1, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
        Player(id: 2, name: 'Bob', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
        Player(id: 3, name: 'Charlie', teamId: 1, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
        Player(id: 4, name: 'Dave', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
      ];
      gameState = GameState(players);
    });

    test('simulate two rounds back-to-back', () {
      // -------------------
      // Round 1
      // -------------------
      gameState.conductBidding({
        players[0]: 16,
        players[1]: 18,
        players[2]: 17,
        players[3]: 19, // Dave wins
      });
      gameState.revealTrump(Suit.spades);

      final round1Cards = [
        const Card29(Suit.hearts, Rank.nine),
        const Card29(Suit.hearts, Rank.jack),
        const Card29(Suit.hearts, Rank.ace),
        const Card29(Suit.spades, Rank.nine),
      ];
      final tricksBefore1 = players.fold<int>(0, (sum, p) => sum + p.tricksWon);
      for (int i = 0; i < players.length; i++) {
        players[i].addCard(round1Cards[i]);
        gameState.playCard(players[i], round1Cards[i]);
      }
      final tricksAfter1 = players.fold<int>(0, (sum, p) => sum + p.tricksWon);
      expect(
        tricksAfter1,
        equals(tricksBefore1 + 1),
        reason: 'One trick should be awarded in Round 1',
      );

      gameState.updateTeamScores();
      expect(gameState.teamScores, isNotEmpty);

      expect(gameState.highestBidder, isNotNull);
      final biddingTeam1 = gameState.highestBidder!.teamId;
      final biddingTarget1 = gameState.targetScore;
      final biddingScore1 = gameState.teamScores[biddingTeam1] ?? 0;
      expect(
        gameState.didBiddingTeamWin(),
        equals(biddingScore1 >= biddingTarget1),
      );

      final printLog1 = <String>[];
      final spec1 = ZoneSpecification(
        print: (self, parent, zone, msg) {
          printLog1.add(msg);
        },
      );
      Zone.current.fork(specification: spec1).run(() {
        gameState.printRoundSummary();
      });
      expect(
        printLog1.join('\n'),
        contains('Round 1'),
        reason: 'Round 1 summary should be printed',
      );

      // -------------------
      // Round 2
      // -------------------
      gameState.startNewRound();
      expect(gameState.roundNumber, equals(2));

      gameState.conductBidding({
        players[0]: 20, // Alice wins
        players[1]: 18,
        players[2]: 19,
        players[3]: 17,
      });
      gameState.revealTrump(Suit.clubs);

      final round2Cards = [
        const Card29(Suit.clubs, Rank.jack),
        const Card29(Suit.clubs, Rank.nine),
        const Card29(Suit.clubs, Rank.ace),
        const Card29(Suit.clubs, Rank.ten),
      ];
      final tricksBefore2 = players.fold<int>(0, (sum, p) => sum + p.tricksWon);
      for (int i = 0; i < players.length; i++) {
        players[i].addCard(round2Cards[i]);
        gameState.playCard(players[i], round2Cards[i]);
      }
      final tricksAfter2 = players.fold<int>(0, (sum, p) => sum + p.tricksWon);
      expect(
        tricksAfter2,
        equals(tricksBefore2 + 1),
        reason: 'One trick should be awarded in Round 2',
      );

      gameState.updateTeamScores();

      expect(gameState.highestBidder, isNotNull);
      final biddingTeam2 = gameState.highestBidder!.teamId;
      final biddingTarget2 = gameState.targetScore;
      final biddingScore2 = gameState.teamScores[biddingTeam2] ?? 0;
      expect(
        gameState.didBiddingTeamWin(),
        equals(biddingScore2 >= biddingTarget2),
      );

      final printLog2 = <String>[];
      final spec2 = ZoneSpecification(
        print: (self, parent, zone, msg) {
          printLog2.add(msg);
        },
      );
      Zone.current.fork(specification: spec2).run(() {
        gameState.printRoundSummary();
      });
      expect(
        printLog2.join('\n'),
        contains('Round 2'),
        reason: 'Round 2 summary should be printed',
      );

      // -------------------
      // Finalization
      // -------------------
      gameState.finalizeGame();
      expect(
        gameState.tricksHistory.isEmpty,
        isTrue,
        reason: 'Final check: tricksHistory length=${gameState.tricksHistory.length}',
      );
    });
  });
}