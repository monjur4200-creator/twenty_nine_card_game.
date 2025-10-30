import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/services/bot_ai.dart';
import 'package:twenty_nine_card_game/models/card.dart' as model;
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/trick.dart';

void main() {
  group('BotAI personality tests', () {
    test('Aggressive bot prefers trump over highest non-trump', () {
      final player = Player(id: 1, name: 'AggroBot', teamId: 1);
      player.setHandForTest([
        model.Card29(model.Suit.hearts, model.Rank.ace), // high non-trump
        model.Card29(model.Suit.spades, model.Rank.seven), // trump
      ]);

      final state = GameState([player], trump: model.Suit.spades);
      final bot = BotAI(BotPersonality.aggressive);

      final chosen = bot.playCard(state, player);

      expect(chosen.suit, equals(model.Suit.spades));
    });

    test('Cautious bot throws away lowest card when partner is winning', () {
      final cautious = Player(id: 2, name: 'CarefulBot', teamId: 1);
      final partner = Player(id: 3, name: 'Partner', teamId: 1);
      cautious.setHandForTest([
        model.Card29(model.Suit.hearts, model.Rank.seven),
        model.Card29(model.Suit.spades, model.Rank.ace),
      ]);

      final state = GameState([cautious, partner], trump: model.Suit.spades);
      final trick = Trick();
      trick.plays[partner] = model.Card29(model.Suit.spades, model.Rank.king); // partner winning
      state.tricksHistory.add(trick);

      final bot = BotAI(BotPersonality.cautious);
      final chosen = bot.playCard(state, cautious);

      expect(chosen.rank, equals(model.Rank.seven));
    });

    test('Logical bot follows suit if possible', () {
      final player = Player(id: 4, name: 'LogicBot', teamId: 2);
      player.setHandForTest([
        model.Card29(model.Suit.hearts, model.Rank.seven),
        model.Card29(model.Suit.spades, model.Rank.ace),
      ]);

      final state = GameState([player], trump: model.Suit.spades);
      final trick = Trick();
      trick.plays[player] = model.Card29(model.Suit.hearts, model.Rank.king); // lead suit hearts
      state.tricksHistory.add(trick);

      final bot = BotAI(BotPersonality.logical);
      final chosen = bot.playCard(state, player);

      expect(chosen.suit, equals(model.Suit.hearts));
    });

    test('Logical bot plays trump if cannot follow suit', () {
      final player = Player(id: 5, name: 'TrumpLogic', teamId: 2);
      player.setHandForTest([
        model.Card29(model.Suit.spades, model.Rank.seven),
        model.Card29(model.Suit.clubs, model.Rank.king),
      ]);

      final state = GameState([player], trump: model.Suit.spades);
      final trick = Trick();
      trick.plays[player] = model.Card29(model.Suit.hearts, model.Rank.nine); // lead suit hearts
      state.tricksHistory.add(trick);

      final bot = BotAI(BotPersonality.logical);
      final chosen = bot.playCard(state, player);

      expect(chosen.suit, equals(model.Suit.spades));
    });

    test('Logical bot discards lowest card if no lead suit or trump', () {
      final player = Player(id: 6, name: 'FallbackLogic', teamId: 2);
      player.setHandForTest([
        model.Card29(model.Suit.clubs, model.Rank.seven),
        model.Card29(model.Suit.hearts, model.Rank.king),
      ]);

      final state = GameState([player]); // no trump, no lead suit
      final bot = BotAI(BotPersonality.logical);

      final chosen = bot.playCard(state, player);

      expect(chosen.rank, equals(model.Rank.seven));
    });

    test('Bot remembers played cards', () {
      final bot = BotAI(BotPersonality.logical);
      final card = model.Card29(model.Suit.clubs, model.Rank.king);

      bot.remember(card);

      expect(bot.memory.contains(card), isTrue);
    });
  });
}
