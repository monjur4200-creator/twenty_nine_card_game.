import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/card.dart';

void main() {
  group('Game Flow Integration', () {
    late List<Player> players;
    late GameState gameState;

    setUp(() {
      players = [
        Player(id: 1, name: 'Alice', teamId: 1),
        Player(id: 2, name: 'Bob', teamId: 2),
        Player(id: 3, name: 'Charlie', teamId: 1),
        Player(id: 4, name: 'Dave', teamId: 2),
      ];
      gameState = GameState(players);
    });

    test('full round simulation with bidding, trump, tricks, and scoring', () {
      // --- Bidding phase ---
      gameState.conductBidding({
        players[0]: 16, // Alice
        players[1]: 18, // Bob
        players[2]: 17, // Charlie
        players[3]: 19, // Dave wins
      });

      expect(gameState.highestBidder, equals(players[3]));
      expect(gameState.targetScore, equals(19));

      // --- Trump reveal ---
      gameState.revealTrump(Suit.spades);
      expect(gameState.trump, equals(Suit.spades));
      expect(gameState.trumpRevealed, isTrue);

      // --- Trick 1 ---
      final card1 = Card29(Suit.hearts, Rank.nine);
      final card2 = Card29(Suit.hearts, Rank.jack);
      final card3 = Card29(Suit.hearts, Rank.ace);
      final card4 = Card29(Suit.spades, Rank.nine); // trump

      players[0].addCard(card1);
      players[1].addCard(card2);
      players[2].addCard(card3);
      players[3].addCard(card4);

      gameState.playCard(players[0], card1);
      gameState.playCard(players[1], card2);
      gameState.playCard(players[2], card3);
      gameState.playCard(players[3], card4);

      expect(gameState.tricksHistory.length, equals(1));
      expect(players[3].tricksWon, equals(1)); // Dave wins with trump

      // --- Trick 2 ---
      final card5 = Card29(Suit.clubs, Rank.jack);
      final card6 = Card29(Suit.clubs, Rank.nine);
      final card7 = Card29(Suit.clubs, Rank.ace);
      final card8 = Card29(Suit.clubs, Rank.ten);

      players[0].addCard(card5);
      players[1].addCard(card6);
      players[2].addCard(card7);
      players[3].addCard(card8);

      gameState.playCard(players[0], card5);
      gameState.playCard(players[1], card6);
      gameState.playCard(players[2], card7);
      gameState.playCard(players[3], card8);

      expect(gameState.tricksHistory.length, equals(2));
      expect(players[2].tricksWon, equals(1)); // Charlie wins with Ace of clubs

      // --- Update team scores ---
      gameState.updateTeamScores();
      expect(gameState.teamScores.containsKey(1), isTrue);
      expect(gameState.teamScores.containsKey(2), isTrue);

      // --- Print round summary ---
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
