import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerBanner extends StatelessWidget {
  final Player player;
  final bool isConnected;

  const PlayerBanner({
    super.key,
    required this.player,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    final initials = player.name.isNotEmpty
        ? player.name.trim().split(' ').map((e) => e[0]).take(2).join()
        : '👤';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green[100] : Colors.red[100],
        border: Border.all(color: isConnected ? Colors.green : Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.name,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Icon(
            isConnected ? Icons.check_circle : Icons.cancel,
            color: isConnected ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}
