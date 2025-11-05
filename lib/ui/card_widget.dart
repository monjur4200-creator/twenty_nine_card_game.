import 'package:flutter/material.dart';
import '../models/card29.dart';

/// Renders a [Card29] as an image or fallback box.
class CardWidget extends StatelessWidget {
  final Card29 card;
  final double width;
  final bool faceUp;

  const CardWidget({
    super.key,
    required this.card,
    this.width = 60,
    this.faceUp = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!faceUp) {
      return Image.asset(
        'assets/cards/back.png',
        width: width,
        fit: BoxFit.contain,
      );
    }

    final assetPath = 'assets/cards/${card.suit.name}_${card.rank.name}.png';

    return Image.asset(
      assetPath,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if asset missing
        return Container(
          width: width,
          height: width * 1.4,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black26),
          ),
          child: Text(
            '${_rankLabel(card.rank)}\n${_suitSymbol(card.suit)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        );
      },
    );
  }

  String _rankLabel(Rank rank) {
    switch (rank) {
      case Rank.seven:
        return '7';
      case Rank.eight:
        return '8';
      case Rank.nine:
        return '9';
      case Rank.ten:
        return '10';
      case Rank.jack:
        return 'J';
      case Rank.queen:
        return 'Q';
      case Rank.king:
        return 'K';
      case Rank.ace:
        return 'A';
    }
  }

  String _suitSymbol(Suit suit) {
    switch (suit) {
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
      case Suit.spades:
        return '♠';
    }
  }
}
