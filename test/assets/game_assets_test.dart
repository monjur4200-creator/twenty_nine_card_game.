import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:twenty_nine_card_game/utils/deck_builder.dart';

Future<bool> assetExists(String path) async {
  try {
    await rootBundle.load(path);
    return true;
  } catch (_) {
    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Card asset validation', () {
    final deck = DeckBuilder.generateDeck();       // 32 playable cards
    final markers = DeckBuilder.generateMarkers(); // 4 sixes for scoring
    final allCards = [...deck, ...markers];        // total 36 assets

    test('Deck has 32 playable cards + 4 markers', () {
      expect(deck.length, equals(32));
      expect(markers.length, equals(4));
      expect(allCards.length, equals(36));
    });

    test('All cards generate valid image paths', () {
      for (final card in allCards) {
        expect(card.imagePath, contains('assets/cards/'));
        expect(card.imagePath, endsWith('.png'));
      }
    });

    test('All card assets exist in bundle', () async {
      for (final card in allCards) {
        final exists = await assetExists(card.imagePath);
        expect(exists, isTrue, reason: 'Missing asset: ${card.imagePath}');
      }
    });

    test('No duplicate image paths', () {
      final paths = allCards.map((c) => c.imagePath).toList();
      final unique = paths.toSet();
      expect(paths.length, equals(unique.length));
    });
  });
}
