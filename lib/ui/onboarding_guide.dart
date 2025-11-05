import 'package:flutter/material.dart';

class OnboardingGuide extends StatelessWidget {
  const OnboardingGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Play Twenty Nine'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            '🎴 Welcome to Twenty Nine!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'This guide walks you through the visual flow of the game, including animations and feedback cues.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),

          Text(
            '🃏 Dealing Animation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Cards are dealt in two phases: 4 cards → bidding → 4 more cards. Watch for the animated fan-out from the center.',
          ),
          SizedBox(height: 16),

          Text(
            '🗳️ Bidding Feedback',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'When you confirm a bid, your button pulses to acknowledge your action.',
          ),
          SizedBox(height: 16),

          Text(
            '🃏 Trick Collection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'After each trick, the played cards animate toward the winner’s avatar. This helps you track who won the round.',
          ),
          SizedBox(height: 16),

          Text(
            '🌟 Winner Highlight',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'The winning player’s avatar glows briefly to celebrate their victory.',
          ),
          SizedBox(height: 16),

          Text(
            '📊 Round Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'After all tricks are played, you’ll see a summary of scores and team performance.',
          ),
          SizedBox(height: 24),

          Text(
            '🎉 Enjoy the game and celebrate every trick!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
