import 'package:flutter/material.dart';
import '../utils/game_manager.dart';

class RoundHistoryWidget extends StatelessWidget {
  final GameManager manager;

  const RoundHistoryWidget({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    if (manager.history.isEmpty) {
      return const Text(
        'No history yet',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Round History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(6),
          ),
          child: ListView.builder(
            itemCount: manager.history.length,
            itemBuilder: (context, index) {
              return Text(
                '• ${manager.history[index]}',
                style: const TextStyle(fontSize: 14),
              );
            },
          ),
        ),
      ],
    );
  }
}