import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/card29.dart';
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';

void main() {
  test(
    'Full Round Integration end-to-end: bidding → trump → trick → scoring → reset',
    () {
      // --- Setup players ---
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
        Player(
          id: 3,
          name: 'Charlie',
          teamId: 1,
          loginMethod: LoginMethod.guest,
          connectionType: ConnectionType.local,
        ),
        Player(
          id: 4,
          name: 'Dave',
          teamId: 2,
          loginMethod: LoginMethod.guest,
          connectionType: ConnectionType.local,
        ),
      ];

      final game = GameState(players);
      game.startNewRound();

      // --- Bidding ---
      game.conductBidding({
        players[0]: 16,
        players[1]: 18,
        players[2]: 17,
        players[3]: 19,
      });

      expect(game.highestBidder?.name, equals('Dave'));
      expect(game.targetScore, equals(19));

      // --- Reveal trump ---
      game.revealTrump(Suit.hearts);
      expect(game.trump, equals(Suit.hearts));
      expect(game.trumpRevealed, isTrue);

      // --- Deal and play one trick ---
      const card1 = Card29(Suit.hearts, Rank.ace); // Alice
      const card2 = Card29(Suit.spades, Rank.king); // Bob
      const card3 = Card29(Suit.clubs, Rank.ten); // Charlie
      const card4 = Card29(Suit.diamonds, Rank.jack); // Dave

      players[0].addCard(card1);
      players[1].addCard(card2);
      players[2].addCard(card3);
      players[3].addCard(card4);

      game.playCard(players[0], card1);
      game.playCard(players[1], card2);
      game.playCard(players[2], card3);
      game.playCard(players[3], card4);

      // --- Trick winner ---
      final winner = game.getTrickWinner();
      debugPrint('DEBUG winner: ${winner?.name} (id: ${winner?.id})');
      expect(winner?.id, equals(1)); // Alice

      // --- Points check ---
      final trick = game.lastTrick;
      expect(trick?.totalPoints(), greaterThan(0));
      expect(players[0].tricksWon, equals(1));
      expect(players[0].score, equals(trick?.totalPoints()));

      // --- Team scoring ---
      final scores = game.calculateTeamScores();
      expect(scores[1], greaterThan(0));
      expect(scores[2], equals(0));

      // --- Reset ---
      game.finalizeGame();
      expect(game.tricksHistory, isEmpty);
    },
  );
}
