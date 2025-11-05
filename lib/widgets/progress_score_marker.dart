import 'package:flutter/material.dart';

class ProgressScoreMarker extends StatelessWidget {
  final String imagePath;
  final int score;
  final int maxScore; // e.g. 29

  const ProgressScoreMarker({
    super.key,
    required this.imagePath,
    required this.score,
    this.maxScore = 29,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (score / maxScore).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Base card image
        Image.asset(
          imagePath,
          width: 80,
          height: 120,
          fit: BoxFit.contain,
        ),

        // Semi‑transparent overlay that fills upward
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: progress,
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),

        // Score number on top
        Text(
          '$score',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black,
                  )
                ],
              ),
        ),
      ],
    );
  }
}
