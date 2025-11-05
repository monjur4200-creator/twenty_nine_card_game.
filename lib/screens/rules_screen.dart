import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Twenty-Nine Rules', key: Key('rulesScreenTitle')),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Twenty-Nine is a South Asian trick-taking card game played by four players in fixed partnerships. The goal is to win tricks and score points based on card values.',
              ),
              SizedBox(height: 16),
              Text(
                'Card Values',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Only 32 cards are used (7 through Ace in each suit). Points are awarded as follows:\n'
                '• Jack: 3 points\n'
                '• Nine: 2 points\n'
                '• Ace & Ten: 1 point each\n'
                '• Others: 0 points',
              ),
              SizedBox(height: 16),
              Text(
                'Gameplay Phases',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. Deal: Each player receives 8 cards in two batches.\n'
                '2. Bidding: Players bid for the right to choose trump.\n'
                '3. Trump Reveal: Winning bidder selects trump suit.\n'
                '4. Trick Play: Players play one card per trick.\n'
                '5. Scoring: Points are tallied and team scores updated.',
              ),
              SizedBox(height: 16),
              Text(
                'Winning the Game',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'The first team to reach 29 points wins. If the bidding team fails to meet their bid, they lose points.',
              ),
              SizedBox(height: 16),
              Text(
                'Cultural Notes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Twenty-Nine is traditionally played during festivals and family gatherings across Bangladesh and India. This version honors that legacy with authentic visuals and gameplay.',
              ),
              SizedBox(height: 32),
              Center(
                child: Text(
                  'Enjoy the game!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
