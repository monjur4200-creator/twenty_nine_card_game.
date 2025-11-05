import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/card29.dart';
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/game_logic/game_errors.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';

void main() {
  late List<Player> players;
  late GameState game;

  setUp(() {
    players = [
      Player(id: 1, name: 'Mongur', teamId: 1, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
      Player(id: 2, name: 'Rafi', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
      Player(id: 3, name: 'Tuli', teamId: 1, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
      Player(id: 4, name: 'Nayeem', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local),
    ];
    game = GameState(players);
    game.startNewRound();
  });

  group('Bidding Phase', () {
    test('sets highest bidder and target score', () {
      game.conductBidding({
        players[0]: 17,
        players[1]: 20,
        players[2]: 19,
        players[3]: 18,
      });

      expect(game.highestBidder, equals(players[1]));
      expect(game.targetScore, equals(20));
    });

    test('throws error if no bids are placed', () {
      expect(() => game.conductBidding({}), throwsA(isA<ArgumentError>()));
    });
  });

  group('Trump Phase', () {
    test('stores correct suit when revealed', () {
      game.revealTrump(Suit.hearts);
      expect(game.trump, equals(Suit.hearts));
    });

    test('throws error if trump is revealed twice', () {
      game.revealTrump(Suit.spades);
      expect(() => game.revealTrump(Suit.hearts), throwsA(isA<ArgumentError>()));
    });
  });

  group('Trick Play Phase', () {
    test('records a trick and determines a winner', () {
      players[0].setHandForTest([const Card29(Suit.hearts, Rank.jack)]); // 3 pts
      players[1].setHandForTest([const Card29(Suit.spades, Rank.nine)]); // 2 pts
      players[2].setHandForTest([const Card29(Suit.hearts, Rank.nine)]); // 2 pts
      players[3].setHandForTest([const Card29(Suit.clubs, Rank.king)]); // 0 pts

      game.revealTrump(Suit.hearts);

      for (var player in players) {
        game.playCard(player, player.hand.first);
      }

      final trick = game.lastTrick;
      expect(trick, isNotNull);

      final winner = trick!.determineWinner(game.trump);
      debugPrint('Trick Winner: ${winner?.name}');

      expect(winner, isNotNull);
      expect(trick.totalPoints(), greaterThan(0));
    });

    test('throws GameError if player tries to play a card not in hand', () {
      const fakeCard = Card29(Suit.hearts, Rank.king);
      expect(
        () => game.playCard(players[0], fakeCard),
        throwsA(isA<GameError>().having((e) => e.code, 'code', GameErrorCode.cardNotInHand)),
      );
    });

    test('throws GameError if same player plays twice in one trick', () {
      players[0].setHandForTest([
        const Card29(Suit.hearts, Rank.jack),
        const Card29(Suit.spades, Rank.nine),
      ]);
      game.revealTrump(Suit.hearts);

      game.playCard(players[0], players[0].hand.first);

      expect(
        () => game.playCard(players[0], players[0].hand.first),
        throwsA(isA<GameError>().having((e) => e.code, 'code', GameErrorCode.invalidMove)),
      );
    });
  });

  group('Round Summary', () {
    test('updates team scores after tricks', () {
      players[0].setHandForTest([const Card29(Suit.hearts, Rank.jack)]); // 3 pts
      players[1].setHandForTest([const Card29(Suit.spades, Rank.nine)]); // 2 pts
      players[2].setHandForTest([const Card29(Suit.hearts, Rank.nine)]); // 2 pts
      players[3].setHandForTest([const Card29(Suit.clubs, Rank.king)]); // 0 pts

      game.revealTrump(Suit.hearts);

      for (var player in players) {
        game.playCard(player, player.hand.first);
      }

      game.updateTeamScores();
      game.printRoundSummary();

      final team1Score = game.teamScores[1] ?? 0;
      final team2Score = game.teamScores[2] ?? 0;

      debugPrint('Team 1 Score: $team1Score');
      debugPrint('Team 2 Score: $team2Score');

      expect(team1Score + team2Score, greaterThan(0));
      expect(team1Score, isNonNegative);
      expect(team2Score, isNonNegative);
    });
  });
}