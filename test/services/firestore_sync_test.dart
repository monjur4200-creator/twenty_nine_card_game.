import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';

void main() {
  group('Integration', () {
    test('GameState.fromMap restores teamScores field', () {
      final players = [
        Player(
          id: 1,
          name: 'Alice',
          teamId: 1,
          loginMethod: LoginMethod.guest,
          connectionType: ConnectionType.local,
        ),
        Player(
          id: 2,
          name: 'Bob',
          teamId: 2,
          loginMethod: LoginMethod.guest,
          connectionType: ConnectionType.local,
        ),
      ];

      final firestoreMap = {
        'roundNumber': 2,
        'highestBidder': 1,
        'trump': 'hearts',
        'trumpRevealed': true,
        'currentTurn': 1,
        'targetScore': 29,
        'tricksHistory': [],
        'teamScores': {'1': 42, '2': 28},
      };

      final gameState = GameState.fromMap(firestoreMap, players);

      expect(gameState.roundNumber, 2);
      expect(gameState.trumpRevealed, true);
      expect(gameState.teamScores[1], 42);
      expect(gameState.teamScores[2], 28);
    });

    test('GameState.toMap writes teamScores with string keys', () {
      final players = [
        Player(
          id: 1,
          name: 'Alice',
          teamId: 1,
          loginMethod: LoginMethod.guest,
          connectionType: ConnectionType.local,
        )..score = 10,
        Player(
          id: 2,
          name: 'Bob',
          teamId: 2,
          loginMethod: LoginMethod.guest,
          connectionType: ConnectionType.local,
        )..score = 5,
      ];

      final gameState = GameState(players, roundNumber: 1);
      final map = gameState.toMap();

      final teamScores = map['teamScores'] as Map<String, dynamic>;
      expect(teamScores['1'], 10);
      expect(teamScores['2'], 5);
    });

    test('GameState.fromMap handles empty teamScores safely', () {
      final players = [
        Player(
          id: 1,
          name: 'Alice',
          teamId: 1,
          loginMethod: LoginMethod.guest,
          connectionType: ConnectionType.local,
        ),
        Player(
          id: 2,
          name: 'Bob',
          teamId: 2,
          loginMethod: LoginMethod.guest,
          connectionType: ConnectionType.local,
        ),
      ];

      final firestoreMap = {
        'roundNumber': 3,
        'trump': null,
        'trumpRevealed': false,
        'currentTurn': 0,
        'teamScores': {},
      };

      final gameState = GameState.fromMap(firestoreMap, players);

      expect(gameState.roundNumber, 3);
      expect(gameState.trump, null);
      expect(gameState.trumpRevealed, false);
      expect(gameState.currentTurn, 0);
      expect(gameState.teamScores.isEmpty, true);
    });
  });
}