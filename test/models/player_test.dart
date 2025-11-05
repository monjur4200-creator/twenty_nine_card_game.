import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/card29.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';

void main() {
  group('Player Model', () {
    test('initialization sets defaults correctly', () {
      final player = Player(
        id: 1,
        name: 'Alice',
        teamId: 1,
        loginMethod: LoginMethod.guest,
        connectionType: ConnectionType.local,
      );
      expect(player.id, 1);
      expect(player.name, 'Alice');
      expect(player.teamId, 1);
      expect(player.score, 0);
      expect(player.tricksWon, 0);
      expect(player.hand, isEmpty);
    });

    test('addCard and addCards work correctly', () {
      final player = Player(
        id: 1,
        name: 'Alice',
        teamId: 1,
        loginMethod: LoginMethod.guest,
        connectionType: ConnectionType.local,
      );
      const card1 = Card29(Suit.hearts, Rank.ace);
      const card2 = Card29(Suit.spades, Rank.king);

      player.addCard(card1);
      expect(player.hand, contains(card1));

      player.addCards([card2]);
      expect(player.hand, containsAll([card1, card2]));
    });

    test('playCard removes card from hand', () {
      final player = Player(
        id: 1,
        name: 'Alice',
        teamId: 1,
        loginMethod: LoginMethod.guest,
        connectionType: ConnectionType.local,
      );
      const card = Card29(Suit.hearts, Rank.ace);
      player.addCard(card);

      player.playCard(card);
      expect(player.hand, isEmpty);
    });

    test('incrementScore and incrementTricksWon update values', () {
      final player = Player(
        id: 1,
        name: 'Alice',
        teamId: 1,
        loginMethod: LoginMethod.guest,
        connectionType: ConnectionType.local,
      );
      player.incrementScore(5);
      player.incrementTricksWon();

      expect(player.score, 5);
      expect(player.tricksWon, 1);
    });

    test('resetForNewRound clears hand and tricks but keeps score', () {
      final player = Player(
        id: 1,
        name: 'Alice',
        teamId: 1,
        loginMethod: LoginMethod.guest,
        connectionType: ConnectionType.local,
      );
      player.addCard(const Card29(Suit.hearts, Rank.ace));
      player.incrementTricksWon();
      player.incrementScore(10);

      player.resetForNewRound();

      expect(player.hand, isEmpty);
      expect(player.tricksWon, 0);
      expect(player.score, 10); // score persists
    });

    test('toMap and fromMap round-trip preserves data', () {
      final player = Player(
        id: 1,
        name: 'Alice',
        teamId: 1,
        loginMethod: LoginMethod.guest,
        connectionType: ConnectionType.local,
      );
      player.incrementScore(7);
      player.incrementTricksWon();
      player.addCard(const Card29(Suit.hearts, Rank.ace));

      final map = player.toMap();
      final restored = Player.fromMap(map);

      expect(restored.id, player.id);
      expect(restored.name, player.name);
      expect(restored.teamId, player.teamId);
      expect(restored.score, player.score);
      expect(restored.tricksWon, player.tricksWon);
      expect(restored.hand.length, player.hand.length);
    });

    test('equality is based on id only', () {
      final p1 = Player(
        id: 1,
        name: 'Alice',
        teamId: 1,
        loginMethod: LoginMethod.guest,
        connectionType: ConnectionType.local,
      );
      final p2 = Player(
        id: 1,
        name: 'Different',
        teamId: 2,
        loginMethod: LoginMethod.guest,
        connectionType: ConnectionType.local,
      );
      final p3 = Player(
        id: 2,
        name: 'Bob',
        teamId: 1,
        loginMethod: LoginMethod.guest,
        connectionType: ConnectionType.local,
      );

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
    });

    test('fromMap with missing fields defaults safely', () {
      final map = <String, dynamic>{}; // empty map
      final player = Player.fromMap(map);

      expect(player.id, -1); // default id
      expect(player.name, 'Unknown'); // default name
      expect(player.teamId, 0); // default team
      expect(player.score, 0);
      expect(player.tricksWon, 0);
      expect(player.hand, isEmpty);
    });
  });
}