import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/card29.dart';

void main() {
  group('GameState', () {
    late List<Player> players;
    late GameState game;

    setUp(() {
      players = [
        Player(id: 1, name: 'Alice', teamId: 1, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
        Player(id: 2, name: 'Bob', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
        Player(id: 3, name: 'Tuli', teamId: 1, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
        Player(id: 4, name: 'Nayeem', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
      ];
      game = GameState(players);
    });

    test('initializes round and resets players', () {
      game.startNewRound();
      expect(game.roundNumber, greaterThan(1));
      expect(game.tricksHistory, isEmpty);
      expect(game.highestBidder, isNull);
      expect(game.trumpRevealed, isFalse);
      expect(players.every((p) => p.tricksWon == 0 && p.score == 0), isTrue);
    });

    test('selects highest bidder correctly', () {
      game.conductBidding({
        players[0]: 17,
        players[1]: 20,
        players[2]: 19,
        players[3]: 18,
      });
      expect(game.highestBidder, players[1]);
      expect(game.targetScore, 20);
    });

    test('reveals trump suit and locks it', () {
      game.revealTrump(Suit.hearts);
      expect(game.trump, Suit.hearts);
      expect(game.trumpRevealed, isTrue);
    });

    test('plays a full trick and assigns winner', () {
      game.revealTrump(Suit.spades);
      for (final p in players) {
        p.setHandForTest([const Card29(Suit.spades, Rank.nine)]);
      }

      for (final p in players) {
        game.playCard(p, p.hand.first);
      }

      final winner = game.getTrickWinner();
      expect(winner, isNotNull);
      expect(winner!.tricksWon, 1);
      expect(winner.score, greaterThan(0));
    });

    test('calculates team scores with trump bonuses', () {
      game.highestBidder = players[0]; // team 1
      game.trump = Suit.hearts;
      game.trumpRevealed = true;

      players[0].setHandForTest([const Card29(Suit.hearts, Rank.king)]);
      players[1].setHandForTest([const Card29(Suit.hearts, Rank.queen)]);

      players[0].score = 10;
      players[1].score = 12;

      final scores = game.calculateTeamScores();
      expect(scores[1], 14); // +4 for king
      expect(scores[2], 8);  // -4 for queen
    });

    test('bidding team wins only if score meets target', () {
      game.highestBidder = players[0]; // team 1
      game.targetScore = 20;

      players[0].score = 10;
      players[2].score = 12; // team 1 total = 22

      players[1].score = 5;
      players[3].score = 6;

      expect(game.didBiddingTeamWin(), isTrue);
    });

    test('bidding team loses if score is below target', () {
      game.highestBidder = players[0]; // team 1
      game.targetScore = 25;

      players[0].score = 10;
      players[2].score = 12; // team 1 total = 22

      expect(game.didBiddingTeamWin(), isFalse);
    });
  });
}