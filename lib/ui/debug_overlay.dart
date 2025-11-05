import 'package:flutter/material.dart';
import 'package:twenty_nine_card_game/models/card29.dart';

/// Debug overlay to visualize trick state and animation flags.
class DebugOverlay extends StatelessWidget {
  final List<Card29> lastTrickCards;
  final String lastTrickWinnerId;
  final bool showTrickAnimation;
  final bool showBidPulse;

  const DebugOverlay({
    super.key,
    required this.lastTrickCards,
    required this.lastTrickWinnerId,
    required this.showTrickAnimation,
    required this.showBidPulse,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: 220,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(179),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontSize: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🛠️ Debug Overlay', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Trick Winner: $lastTrickWinnerId'),
              Text('Trick Animation: $showTrickAnimation'),
              Text('Bid Pulse: $showBidPulse'),
              const SizedBox(height: 4),
              const Text('Last Trick Cards:'),
              for (final card in lastTrickCards)
                Text('- ${card.rank.name} of ${card.suit.name}'),
            ],
          ),
        ),
      ),
    );
  }
}
