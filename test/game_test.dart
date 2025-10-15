import 'package:test/test.dart';
import 'package:twenty_nine_card_game/models/card.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/trick.dart';
import 'package:twenty_nine_card_game/models/game_state.dart';

void main() {
  test('Simulate bidding and three tricks', () {
    final players = [
      Player(id: 1, name: 'Mongur'),
      Player(id: 2, name: 'Rafi'),
      Player(id: 3, name: 'Tuli'),
      Player(id: 4, name: 'Nayeem'),
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

    print('🗣️ Highest Bidder: ${game.highestBidder?.name} with ${game.targetScore} points');

    // Highest bidder reveals trump
    game.revealTrump(Suit.hearts);

    // 🃏 Simulate 3 tricks
    for (int trickNumber = 1; trickNumber <= 3; trickNumber++) {
      print('\n🃏 Trick $trickNumber');
      for (var player in game.players) {
        final cardToPlay = player.hand.isNotEmpty ? player.hand.first : null;
        if (cardToPlay != null) {
          print('${player.name} plays $cardToPlay');
          game.playCard(player, cardToPlay);
        }
      }

      final lastTrick = game.tricks.last;
      final winner = lastTrick.determineWinner(game.trump?.toString().split('.').last ?? '');
      print('Trick Winner: ${winner?.name}');
      print('Points in Trick: ${lastTrick.totalPoints()}');
    }

    // 📊 Final summary
    print('\n📊 Final Round Summary:');
    game.printRoundSummary();

    // ✅ Assertions
    expect(game.tricks.length, equals(3));
    expect(game.highestBidder, isNotNull);
    expect(game.targetScore, greaterThanOrEqualTo(16));
  });
}