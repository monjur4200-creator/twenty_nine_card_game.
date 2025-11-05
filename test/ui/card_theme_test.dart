import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/ui/game_card_theme.dart';

void main() {
  group('Card29Theme', () {
    const theme = Card29Theme();

    test('assetPath generates correct path', () {
      expect(theme.assetPath('spade', 'A'),
          equals('assets/cards/spade_A.png'));
      expect(theme.assetPath('heart', '10'),
          equals('assets/cards/heart_10.png'));
    });

    test('textColor defaults to white and is fully opaque', () {
      final color = theme.textColor;
      expect(color, equals(Colors.white));
      final alpha = (color.a * 255.0).round() & 0xff;
      expect(alpha, greaterThan(204),
          reason: 'Text color should be sufficiently opaque');
    });

    test('highContrast mode uses black text', () {
      const highContrastTheme = Card29Theme(highContrast: true);
      expect(highContrastTheme.textColor, equals(Colors.black));
    });

    test('colorBlindFriendly adds symbols', () {
      const cbTheme = Card29Theme(colorBlindFriendly: true);
      expect(cbTheme.accessibilitySymbol('spade'), equals('▲'));
      expect(cbTheme.accessibilitySymbol('heart'), equals('❤'));
      expect(cbTheme.accessibilitySymbol('diamond'), equals('◆'));
      expect(cbTheme.accessibilitySymbol('club'), equals('♣'));
    });

    test('colorBlindFriendly off returns empty string', () {
      expect(theme.accessibilitySymbol('spade'), isEmpty);
    });
  });
}
