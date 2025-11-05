import 'package:flutter/material.dart';

/// Model for a playing card in the game.
class GameCard {
  final String suit;   // "hearts", "diamonds", "clubs", "spades"
  final String rank;   // "A", "K", "Q", "J", "10", "9", etc.
  final String? owner; // NEW: which player played this card (optional)

  const GameCard({
    required this.suit,
    required this.rank,
    this.owner,
  });

  /// Allows cloning with modifications (needed for trick logic).
  GameCard copyWith({String? suit, String? rank, String? owner}) {
    return GameCard(
      suit: suit ?? this.suit,
      rank: rank ?? this.rank,
      owner: owner ?? this.owner,
    );
  }
}

class CardWidget extends StatelessWidget {
  final GameCard card;
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

    final assetPath = 'assets/cards/${card.suit}_${card.rank}.png';

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
            '${card.rank}\n${card.suit}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        );
      },
    );
  }
}