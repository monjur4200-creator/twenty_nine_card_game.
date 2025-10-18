import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:test/test.dart';

import 'package:twenty_nine_card_game/models/card.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/game_state.dart';

void main() {
  test('Simulate bidding and three tricks', () {
    final List<Player> players = [
      Player(id: 1, name: 'Mongur', teamId: 1),
      Player(id: 2, name: 'Rafi', teamId: 2),
      Player(id: 3, name: 'Tuli', teamId: 1),
      Player(id: 4, name: 'Nayeem', teamId: 2),
    ];

    final game = GameState(players);
    game.startNewRound();

    // 🗣️ Bidding phase
    game.conductBidding({
      players[0]: 17,
      players[1]: 20,
      players[2]: 19,
      players[3]: 18,
    });

    debugPrint(
        '🗣️ Highest Bidder: ${game.highestBidder?.name} with ${game.targetScore} points');

    // Highest bidder reveals trump
    game.revealTrump(Suit.hearts);

    // 🃏 Simulate 3 tricks
    for (int trickNumber = 1; trickNumber <= 3; trickNumber++) {
      debugPrint('\n🃏 Trick $trickNumber');
      for (var player in game.players) {
        final cardToPlay = player.hand.isNotEmpty ? player.hand.first : null;
        if (cardToPlay != null) {
          debugPrint('${player.name} plays $cardToPlay');
          game.playCard(player, cardToPlay);
        }
      }

      final lastTrick = game.tricks.last;
      final winner = lastTrick.determineWinner(game.trump);
      debugPrint('Trick Winner: ${winner?.name}');
      debugPrint('Points in Trick: ${lastTrick.totalPoints()}');
    }

    // 📊 Final summary
    debugPrint('\n📊 Final Round Summary:');
    game.printRoundSummary();

    // ✅ Assertions
    expect(game.tricks.length, equals(3));
    expect(game.highestBidder != null, true); // safe null check
    expect(game.targetScore, greaterThanOrEqualTo(16));
  });
}