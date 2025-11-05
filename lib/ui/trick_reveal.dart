import 'package:flutter/material.dart';
import '../models/card29.dart';

class TrickReveal extends StatelessWidget {
  final List<Card29> trickCards;
  final String winnerName;
  final void Function()? onComplete;

  const TrickReveal({
    super.key,
    required this.trickCards,
    required this.winnerName,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(128),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🃏 Trick Reveal',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: trickCards.map((card) {
                  final isWinningCard = card.ownerName == winnerName;
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isWinningCard ? Colors.yellow[300] : Colors.grey[200],
                      border: Border.all(color: isWinningCard ? Colors.orange : Colors.black26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(card.displayName, style: const TextStyle(fontSize: 16)),
                        Text(card.ownerName, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Winner: $winnerName', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onComplete,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
