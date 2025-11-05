import 'package:flutter/material.dart';
import '../utils/score_keeper.dart';

class AnimatedScoreboard extends StatefulWidget {
  final ScoreKeeper keeper;

  const AnimatedScoreboard({super.key, required this.keeper});

  @override
  State<AnimatedScoreboard> createState() => _AnimatedScoreboardState();
}

class _AnimatedScoreboardState extends State<AnimatedScoreboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  int lastTeam1Score = 0;
  int lastTeam2Score = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.9,
      upperBound: 1.1,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedScoreboard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger animation if a score increased
    if (widget.keeper.team1Score > lastTeam1Score ||
        widget.keeper.team2Score > lastTeam2Score) {
      _controller.forward(from: 0.9);
    }

    lastTeam1Score = widget.keeper.team1Score;
    lastTeam2Score = widget.keeper.team2Score;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildTeamColumn(String label, int score, String markerPath) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        ScaleTransition(
          scale: _scaleAnimation,
          child: Image.asset(
            markerPath,
            width: 60,
            height: 90,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$score',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final keeper = widget.keeper;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTeamColumn('Team 1', keeper.team1Score, keeper.team1Marker.imagePath),
        _buildTeamColumn('Team 2', keeper.team2Score, keeper.team2Marker.imagePath),
      ],
    );
  }
}
