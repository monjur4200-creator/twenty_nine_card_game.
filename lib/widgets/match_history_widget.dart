import 'package:flutter/material.dart';
import '../utils/game_manager.dart';

class MatchHistoryWidget extends StatelessWidget {
  final GameManager manager;

  const MatchHistoryWidget({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    if (manager.matchHistory.isEmpty) {
      return const Text(
        'No rounds played yet',
        style: TextStyle(color: Colors.grey),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: manager.matchHistory.length,
      itemBuilder: (context, roundIndex) {
        final roundLog = manager.matchHistory[roundIndex];

        // Snapshot of scores after this round
        final team1Score = manager.keeper.team1ScoreHistory[roundIndex];
        final team2Score = manager.keeper.team2ScoreHistory[roundIndex];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Round ${roundIndex + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score after round: Team 1 = $team1Score | Team 2 = $team2Score',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey,
                  ),
                ),
                const Divider(),
                ...roundLog.map((entry) => Text('• $entry')),
              ],
            ),
          ),
        );
      },
    );
  }
}