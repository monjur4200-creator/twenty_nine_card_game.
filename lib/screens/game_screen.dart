import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/card.dart';
import '../models/game_state.dart';
import 'bidding_screen.dart';
import 'round_summary.dart';

// Multiplayer sync service (Bluetooth/local)
import '../services/sync_service.dart';
import '../services/firebase_service.dart';

class GameScreen extends StatefulWidget {
  final FirebaseService firebaseService; // ✅ required service

  const GameScreen({
    super.key,
    required this.firebaseService,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String resultText = 'Tap "Run Game Simulation" to see results';
  int team1Score = 0;
  int team2Score = 0;
  int roundNumber = 1;

  final SyncService _syncService = SyncService();
  String _connectionStatus = "Not connected";

  // --- Game Simulation ---
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

    // Play a few tricks
    for (int trickNumber = 1; trickNumber <= 3; trickNumber++) {
      for (var player in game.players) {
        final cardToPlay = player.hand.isNotEmpty ? player.hand.first : null;
        if (cardToPlay != null) {
          game.playCard(player, cardToPlay);
        }
      }
    }

    // Build round summary
    final buffer = StringBuffer();
    buffer.writeln('📊 Round ${game.roundNumber} Summary:\n');
    for (var player in players) {
      buffer.writeln(
        '${player.name} - Tricks: ${player.tricksWon}, Score: ${player.score}',
      );
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

  // --- Connection Helpers ---
  void _showConnectedSnack(BuildContext ctx, String deviceName) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text("✅ Connected to $deviceName"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showConnectionFailedSnack(BuildContext ctx) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text("❌ Connection failed"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showDevicePicker() async {
    final devices = await _syncService.getPairedDevices();
    if (!mounted) return;

    if (devices.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("No Devices Found"),
          content: const Text("No paired Bluetooth devices were found."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select a Device"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return ListTile(
                leading: const Icon(Icons.devices),
                title: Text(device.name ?? "Unknown"),
                subtitle: Text(device.address),
                onTap: () async {
                  final ctx = context; // capture context
                  Navigator.pop(ctx);

                  try {
                    await _syncService.connectToDevice(device.address);
                    if (!context.mounted) return;
                    setState(() {
                      _connectionStatus =
                          "Connected to ${device.name ?? device.address}";
                    });
                    _showConnectedSnack(ctx, device.name ?? device.address);
                  } catch (_) {
                    if (!context.mounted) return;
                    setState(() {
                      _connectionStatus = "Connection failed";
                    });
                    _showConnectionFailedSnack(ctx);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _disconnect() {
    _syncService.disconnect();
    setState(() {
      _connectionStatus = "Not connected";
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🔌 Disconnected"),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Twenty Nine - Game Table',
          key: Key('gameScreenTitle'), // 👈 Added for test
        ),
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
      body: SafeArea(
        child: Container(
          color: Colors.green[100],
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- Connection Status Bar ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _connectionStatus.startsWith("Connected")
                      ? Colors.green[400]
                      : Colors.red[400],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _connectionStatus,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),

              // --- Action Buttons ---
              ElevatedButton.icon(
                onPressed: runGameSimulation,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Run Game Simulation'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _showDevicePicker,
                icon: const Icon(Icons.wifi_tethering),
                label: const Text('Connect (Multiplayer)'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _disconnect,
                icon: const Icon(Icons.link_off),
                label: const Text('Disconnect'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BiddingScreen()),
                  );
                },
                icon: const Icon(Icons.gavel),
                label: const Text('Go to Bidding Screen'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

                            ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoundSummary(
                        team1Score: team1Score,
                        team2Score: team2Score,
                        roundNumber: roundNumber,
                        firebaseService: widget.firebaseService,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.summarize),
                label: const Text('Go to Round Summary'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // --- Results Log ---
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      reverse: true, // auto-scroll to bottom
                      child: SelectableText(
                        resultText,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}