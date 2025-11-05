import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/services/bot_ai.dart';
import 'package:twenty_nine_card_game/models/card29.dart' as model;
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/trick.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';

/// Generate a full 32‑card deck (7–Ace in each suit).
List<model.Card29> generateDeck() {
  final deck = <model.Card29>[];
  for (final suit in model.Suit.values) {
    for (final rank in model.Rank.values) {
      if (rank.index >= model.Rank.seven.index) {
        deck.add(model.Card29(suit, rank));
      }
    }
  }
  return deck;
}

/// Shuffle and deal evenly to [numPlayers].
List<List<model.Card29>> dealShuffledHands(
    int numPlayers, int cardsPerPlayer, Random rng) {
  final deck = generateDeck();
  deck.shuffle(rng);
  final hands = List.generate(numPlayers, (_) => <model.Card29>[]);
  for (int i = 0; i < numPlayers * cardsPerPlayer; i++) {
    hands[i % numPlayers].add(deck[i]);
  }
  return hands;
}

void main() {
  group('BotAI statistical simulation', () {
    test('Collect win statistics across 50 simulated games with shuffled deck', () {
      final winCounts = {
        'AggroBot': 0,
        'CarefulBot': 0,
        'LogicBot1': 0,
        'LogicBot2': 0,
      };

      final rng = Random(42); // fixed seed for reproducibility

      for (int game = 0; game < 50; game++) {
        // Players
        final aggro = Player(
          id: 1,
          name: 'AggroBot',
          teamId: 1,
          loginMethod: LoginMethod.guest,
          connectionType: ConnectionType.local,
        );
        final cautious = Player(
          id: 2,
          name: 'CarefulBot',
          teamId: 1,
          loginMethod: LoginMethod.guest,
          connectionType: ConnectionType.local,
        );
        final logic1 = Player(
          id: 3,
          name: 'LogicBot1',
          teamId: 2,
          loginMethod: LoginMethod.guest,
          connectionType: ConnectionType.local,
        );
        final logic2 = Player(
          id: 4,
          name: 'LogicBot2',
          teamId: 2,
          loginMethod: LoginMethod.guest,
          connectionType: ConnectionType.local,
        );
        final players = [aggro, cautious, logic1, logic2];

        // Deal shuffled hands (8 cards each for 32‑card deck)
        final hands = dealShuffledHands(players.length, 8, rng);
        for (int i = 0; i < players.length; i++) {
          players[i].setHandForTest(hands[i]);
        }

        // Randomize trump suit
        final trumpSuit = model.Suit.values[rng.nextInt(model.Suit.values.length)];
        final state = GameState(players, trump: trumpSuit);

        final bots = [
          BotAI(BotPersonality.aggressive),
          BotAI(BotPersonality.cautious),
          BotAI(BotPersonality.logical),
          BotAI(BotPersonality.logical),
        ];

        // Play 8 tricks
        for (int round = 0; round < 8; round++) {
          final trick = Trick(turnOrder: players);

          for (int i = 0; i < players.length; i++) {
            final player = players[i];
            if (player.hand.isNotEmpty) {
              final chosen = bots[i].playCard(state, player);
              trick.addPlay(player, chosen);
            }
          }

          final winner = trick.determineWinner(state.trump);
          if (winner != null) {
            winCounts[winner.name] = winCounts[winner.name]! + 1;
          }

          // Record trick in history
          state.tricksHistory.add(trick);
        }
      }

      // ✅ Totals should add up to 50 × 8 = 400 tricks
      final totalTricks = winCounts.values.reduce((a, b) => a + b);
      expect(totalTricks, equals(400));

      // ✅ Sanity: each bot should win at least once
      for (final entry in winCounts.entries) {
        expect(entry.value, greaterThan(0),
            reason: '${entry.key} should win at least one trick');
      }

      // Print stats for manual inspection
      debugPrint('Bot win distribution after 50 shuffled games: $winCounts');
    });
  });
}
