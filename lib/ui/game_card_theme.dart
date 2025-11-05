import 'package:flutter/material.dart';

class Card29Theme {
  final bool highContrast;
  final bool colorBlindFriendly;

  const Card29Theme({
    this.highContrast = false,
    this.colorBlindFriendly = false,
  });

  /// Returns the asset path for a given suit and rank
  String assetPath(String suit, String rank) {
    return 'assets/cards/${suit}_$rank.png';
  }

  /// Returns the text color for card labels
  Color get textColor => highContrast ? Colors.black : Colors.white;

  /// Returns an accessibility symbol for color-blind mode
  String accessibilitySymbol(String suit) {
    if (!colorBlindFriendly) return '';
    switch (suit) {
      case 'spade': return '▲';
      case 'heart': return '❤';
      case 'diamond': return '◆';
      case 'club': return '♣';
      default: return '';
    }
  }
}
