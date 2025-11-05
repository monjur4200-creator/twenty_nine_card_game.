import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/card29.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';

void main() {
  group('Game Flow Integration', () {
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

    test('Full round simulation: bidding → trump → tricks → scoring → summary', () {
      // Bidding phase
      gameState.conductBidding({
        players[0]: 16,
        players[1]: 18,
        players[2]: 17,
        players[3]: 19,
      });

      expect(gameState.highestBidder, equals(players[3]));
      expect(gameState.targetScore, equals(19));

      // Trump reveal
      gameState.revealTrump(Suit.spades);
      expect(gameState.trump, isNotNull);
      expect(gameState.trump, equals(Suit.spades));
      expect(gameState.trumpRevealed, isTrue);

      // Trick 1
      const card1 = Card29(Suit.hearts, Rank.nine);
      const card2 = Card29(Suit.hearts, Rank.jack);
      const card3 = Card29(Suit.hearts, Rank.ace);
      const card4 = Card29(Suit.spades, Rank.nine);

      players[0].addCard(card1);
      players[1].addCard(card2);
      players[2].addCard(card3);
      players[3].addCard(card4);

      gameState.playCard(players[0], card1);
      gameState.playCard(players[1], card2);
      gameState.playCard(players[2], card3);
      gameState.playCard(players[3], card4);

      expect(gameState.tricksHistory.length, equals(1));
      expect(players[3].tricksWon, equals(1));

      // Trick 2
      const card5 = Card29(Suit.clubs, Rank.jack);
      const card6 = Card29(Suit.clubs, Rank.nine);
      const card7 = Card29(Suit.clubs, Rank.ace);
      const card8 = Card29(Suit.clubs, Rank.ten);

      players[0].addCard(card5);
      players[1].addCard(card6);
      players[2].addCard(card7);
      players[3].addCard(card8);

      gameState.playCard(players[0], card5);
      gameState.playCard(players[1], card6);
      gameState.playCard(players[2], card7);
      gameState.playCard(players[3], card8);

      expect(gameState.tricksHistory.length, equals(2));
      expect(players[2].tricksWon, equals(1));

      // Scoring
      gameState.updateTeamScores();
      expect(gameState.teamScores[1], isNotNull);
      expect(gameState.teamScores[2], isNotNull);

      // Summary capture
      final printLog = <String>[];
      final fixedSpec = ZoneSpecification(
        print: (self, parent, zone, msg) {
          printLog.add(msg);
        },
      );

      Zone.current.fork(specification: fixedSpec).run(() {
        gameState.printRoundSummary();
      });

      expect(printLog.any((line) => line.contains('Alice')), isTrue);
      expect(printLog.any((line) => line.contains('Bob')), isTrue);
      expect(printLog.any((line) => line.contains('Charlie')), isTrue);
      expect(printLog.any((line) => line.contains('Dave')), isTrue);
      expect(printLog.any((line) => line.contains('Team Scores')), isTrue);
    });
  });
}