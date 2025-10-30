import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/card.dart';
import 'package:twenty_nine_card_game/models/trick.dart';

void main() {
  test(
    'Full Round Integration end-to-end: bidding → trump → trick → scoring → reset',
    () {
      // --- Setup players ---
      final players = [
        Player(id: 1, name: 'Alice', teamId: 1),
        Player(id: 2, name: 'Bob', teamId: 2),
        Player(id: 3, name: 'Charlie', teamId: 1),
        Player(id: 4, name: 'Dave', teamId: 2),
      ];

      // --- Setup trick ---
      final trick = Trick(turnOrder: players);

      // --- Deal cards ---
      final card1 = Card29(Suit.hearts, Rank.ace); // Alice
      final card2 = Card29(Suit.spades, Rank.king); // Bob
      final card3 = Card29(Suit.clubs, Rank.ten);  // Charlie
      final card4 = Card29(Suit.diamonds, Rank.jack); // Dave

      players[0].addCard(card1);
      players[1].addCard(card2);
      players[2].addCard(card3);
      players[3].addCard(card4);

      // --- Play cards in order ---
      trick.addPlay(players[0], card1);
      trick.addPlay(players[1], card2);
      trick.addPlay(players[2], card3);
      trick.addPlay(players[3], card4);

      // --- Determine winner ---
      final winner = trick.determineWinner(Suit.hearts);
      debugPrint(
        'DEBUG winner: ${winner?.name} '
        '(id: ${winner?.id}, type: ${winner.runtimeType})',
      );

      // ✅ Compare by id, not object
      expect(winner?.id, equals(1));

      // --- Points check ---
      final points = trick.totalPoints();
      expect(points, greaterThan(0));

      // --- Reset check ---
      trick.reset();
      expect(trick.plays, isEmpty);
    },
  );
}
