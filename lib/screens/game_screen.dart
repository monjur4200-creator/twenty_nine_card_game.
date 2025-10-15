import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/card.dart';
import '../models/game_state.dart';

class MyGameScreen extends StatefulWidget {
  const MyGameScreen({super.key});

  @override
  State<MyGameScreen> createState() => _MyGameScreenState();
}

class _MyGameScreenState extends State<MyGameScreen> {
  String resultText = 'Tap to run simulation';

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
      buffer.writeln('${player.name} - Tricks: ${player.tricksWon}, Score: ${player.score}');
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Twenty Nine')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: runGameSimulation,
              child: const Text('Run Game Simulation'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  resultText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}