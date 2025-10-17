import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/card.dart';
import '../models/game_state.dart';
import 'bidding_screen.dart';
import 'round_summary.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String resultText = 'Tap "Run Game Simulation" to see results';
  int team1Score = 0;
  int team2Score = 0;
  int roundNumber = 1;

  void runGameSimulation() {
    final players = [
      Player(id: 1, name: 'Mongur', teamId: 1),
      Player(id: 2, name: 'Rafi', teamId: 2),
      Player(id: 3, name: 'Tuli', teamId: 1),
      Player(id: 4, name: 'Nayeem', teamId: 2),
    ];

    final game = GameState(players);
    game.startNewRound();

    game.conductBidding({
      players[0]: 17,
      players[1]: 20,
      players[2]: 19,
      players[3]: 18,
    });

    game.revealTrump(Suit.hearts);

    for (int trickNumber = 1; trickNumber <= 3; trickNumber++) {
      for (var player in game.players) {
        final cardToPlay = player.hand.isNotEmpty ? player.hand.first : null;
        if (cardToPlay != null) {
          game.playCard(player, cardToPlay);
        }
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('📊 Round ${game.roundNumber} Summary:\n');
    for (var player in players) {
      buffer.writeln(
          '${player.name} - Tricks: ${player.tricksWon}, Score: ${player.score}');
    }

    final teamScores = game.calculateTeamScores();
    buffer.writeln('\nTeam 1 Score: ${teamScores[1]}');
    buffer.writeln('Team 2 Score: ${teamScores[2]}');

    if (game.highestBidder != null) {
      final biddingTeam = game.highestBidder!.teamId;
      final result = game.didBiddingTeamWin() ? "WON" : "LOST";
      buffer.writeln('Bidding Team ($biddingTeam) $result the round!');
    }

    setState(() {
      resultText = buffer.toString();
      team1Score = teamScores[1] ?? 0;
      team2Score = teamScores[2] ?? 0;
      roundNumber = game.roundNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Twenty Nine - Game Table'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart Simulation',
            onPressed: () {
              setState(() {
                resultText = 'Tap "Run Game Simulation" to see results';
                team1Score = 0;
                team2Score = 0;
                roundNumber = 1;
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.green[100], // subtle table background
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Run Simulation Button
            ElevatedButton.icon(
              onPressed: runGameSimulation,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run Game Simulation'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 12),

            // Navigate to Bidding Screen
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BiddingScreen()),
                );
              },
              icon: const Icon(Icons.gavel),
              label: const Text('Go to Bidding Screen'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),

            // Navigate to Round Summary
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoundSummary(
                      team1Score: team1Score,
                      team2Score: team2Score,
                      roundNumber: roundNumber,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.summarize),
              label: const Text('Go to Round Summary'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.purple,
              ),
            ),
            const SizedBox(height: 20),

            // Results Log
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    resultText,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      fontFamily: 'monospace', // gives it a "log" feel
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}