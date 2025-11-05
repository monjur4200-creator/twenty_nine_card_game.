import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/trick.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/card29.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';
import '../test_utils.dart';

void main() {
  group('Trick', () {
    late Player alice;
    late Player bob;
    late Player charlie;
    late Player dave;

    setUp(() {
      alice = Player(id: 1, name: 'Alice', teamId: 1, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local);
      bob = Player(id: 2, name: 'Bob', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local);
      charlie = Player(id: 3, name: 'Charlie', teamId: 1, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local);
      dave = Player(id: 4, name: 'Dave', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.local);
    });

    test('addPlay records a card played by a player', () {
      final trick = Trick();
      const card = Card29(Suit.hearts, Rank.nine);

      alice.addCard(card);
      trick.addPlay(alice, card);

      expect(trick.plays, hasLength(1));
      final entry = trick.plays.entries.first;
      expect(entry.key, equals(alice));
      expect(entry.value.suit, equals(Suit.hearts));
      expect(entry.value.rank, equals(Rank.nine));
    });

    test('addPlay throws if player plays twice in same trick', () {
      final trick = Trick();
      const card1 = Card29(Suit.hearts, Rank.nine);
      const card2 = Card29(Suit.spades, Rank.king);

      alice.addCards([card1, card2]);

      trick.addPlay(alice, card1);
      expect(() => trick.addPlay(alice, card2), throwsAnyGameError());
    });

    test('determineWinner returns highest card of leading suit if no trump', () {
      final trick = Trick();
      const card1 = Card29(Suit.hearts, Rank.nine);
      const card2 = Card29(Suit.hearts, Rank.jack);

      alice.addCard(card1);
      bob.addCard(card2);

      trick.addPlay(alice, card1);
      trick.addPlay(bob, card2);

      final winner = trick.determineWinner(null);
      expect(winner, equals(bob));
    });

    test('determineWinner returns trump card over higher non-trump', () {
      final trick = Trick();
      const card1 = Card29(Suit.hearts, Rank.ace); // high non-trump
      const card2 = Card29(Suit.spades, Rank.nine); // trump

      alice.addCard(card1);
      bob.addCard(card2);

      trick.addPlay(alice, card1);
      trick.addPlay(bob, card2);

      final winner = trick.determineWinner(Suit.spades);
      expect(winner, equals(bob));
    });

    test('determineWinner returns highest trump if multiple trumps played', () {
      final trick = Trick();
      const card1 = Card29(Suit.spades, Rank.nine);
      const card2 = Card29(Suit.spades, Rank.jack);

      alice.addCard(card1);
      bob.addCard(card2);

      trick.addPlay(alice, card1);
      trick.addPlay(bob, card2);

      final winner = trick.determineWinner(Suit.spades);
      expect(winner, equals(bob));
    });

    test('determineWinner returns null if trick is empty', () {
      final trick = Trick();
      expect(trick.determineWinner(null), isNull);
    });

    test('totalPoints sums the values of all cards in the trick', () {
      final trick = Trick();
      const card1 = Card29(Suit.hearts, Rank.jack); // worth points
      const card2 = Card29(Suit.spades, Rank.nine); // worth points

      alice.addCard(card1);
      bob.addCard(card2);

      trick.addPlay(alice, card1);
      trick.addPlay(bob, card2);

      final points = trick.totalPoints();
      expect(points, greaterThan(0));
    });

    test('totalPoints returns 0 for empty trick', () {
      final trick = Trick();
      expect(trick.totalPoints(), equals(0));
    });

    test('toMap and fromMap round-trip preserves plays', () {
      final trick = Trick();
      const card1 = Card29(Suit.hearts, Rank.nine);
      const card2 = Card29(Suit.spades, Rank.jack);

      alice.addCard(card1);
      bob.addCard(card2);

      trick.addPlay(alice, card1);
      trick.addPlay(bob, card2);

      final map = trick.toMap();
      final restored = Trick.fromMap(map, [alice, bob, charlie, dave]);

      expect(restored.plays, hasLength(2));
      final restoredEntries = restored.plays.entries.toList();
      expect(restoredEntries[0].key.name, equals('Alice'));
      expect(restoredEntries[1].key.name, equals('Bob'));
    });
  });
}