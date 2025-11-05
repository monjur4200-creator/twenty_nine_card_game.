import 'package:flutter/material.dart';
import '../utils/score_keeper.dart';

class Scoreboard extends StatelessWidget {
  final ScoreKeeper keeper;

  const Scoreboard({super.key, required this.keeper});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTeamColumn(
          context,
          'Team 1',
          keeper.team1Score,
          keeper.team1Marker.imagePath,
        ),
        _buildTeamColumn(
          context,
          'Team 2',
          keeper.team2Score,
          keeper.team2Marker.imagePath,
        ),
      ],
    );
  }

  Widget _buildTeamColumn(
      BuildContext context, String label, int score, String markerPath) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
        const SizedBox(height: 8),
        Image.asset(
          markerPath,
          width: 60,
          height: 90,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text(
          '$score',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
