import 'package:flutter/material.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/ui/feedback_pulse.dart';

class PlayerAvatar extends StatelessWidget {
  final Player player;
  final bool isTrickWinner;

  const PlayerAvatar({
    super.key,
    required this.player,
    required this.isTrickWinner,
  });

  @override
  Widget build(BuildContext context) {
    return FeedbackPulse(
      trigger: isTrickWinner,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blueGrey,
            child: Text(
              player.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            player.name,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
