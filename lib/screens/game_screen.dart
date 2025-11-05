import 'dart:async';
import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/card29.dart';
import '../models/game_state.dart';
import '../models/connection_type.dart';
import '../models/login_method.dart';

import '../services/sync_service_interface.dart';
import '../services/firebase_service.dart';
import '../localization/strings.dart';

import 'round_summary.dart';
import 'package:twenty_nine_card_game/ui/dealing_animation.dart';
import 'package:twenty_nine_card_game/ui/trick_reveal.dart';
import 'package:twenty_nine_card_game/ui/feedback_pulse.dart';

class GameScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  final Strings strings;
  final Player player;
  final SyncService syncService;

  const GameScreen({
    super.key,
    required this.firebaseService,
    required this.strings,
    required this.player,
    required this.syncService,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String resultText = '';
  int team1Score = 0;
  int team2Score = 0;
  int roundNumber = 1;

  String _connectionStatus = "Not connected";
  final GlobalKey<DealingAnimationState> _dealingKey = GlobalKey<DealingAnimationState>();

  List<Card29> _lastTrickCards = [];
  String _lastTrickWinnerId = '';
  bool _showBidPulse = false;

  @override
  void initState() {
    super.initState();

    resultText = widget.strings.simulationPrompt;

    widget.syncService.onConnected(() {
      if (!mounted) return;
      setState(() {
        _connectionStatus = "Connected";
      });
    });

    widget.syncService.onDisconnected(() {
      if (!mounted) return;
      setState(() {
        _connectionStatus = "Disconnected";
      });
      final ctx = context;
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(widget.strings.disconnected),
          backgroundColor: Colors.orange,
        ),
      );
    });

    widget.syncService.onLagDetected(() {
      final ctx = context;
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Connection lag detected"),
          backgroundColor: Colors.red,
        ),
      );
    });

    widget.syncService.onResync(() {
      final ctx = context;
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text("🔄 Resyncing game state..."),
          backgroundColor: Colors.blue,
        ),
      );
      widget.syncService.sendGameState({
        'player': widget.player.name,
        'score': widget.player.score,
        'round': roundNumber,
      });
    });

    widget.syncService.startHeartbeat();
  }

  @override
  void dispose() {
    widget.syncService.disconnect();
    super.dispose();
  }

  void runGameSimulation() {
    final players = [
      widget.player,
      Player(id: 2, name: 'Rafi', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.bluetooth),
      Player(id: 3, name: 'Tuli', teamId: 1, loginMethod: LoginMethod.guest, connectionType: ConnectionType.bluetooth),
      Player(id: 4, name: 'Nayeem', teamId: 2, loginMethod: LoginMethod.guest, connectionType: ConnectionType.bluetooth),
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

      _lastTrickCards = game.currentTrick?.cards ?? [];
      _lastTrickWinnerId = game.getTrickWinner()?.name ?? '';
      _showBidPulse = true;

      showDialog(
        context: context,
        builder: (_) => TrickReveal(
          trickCards: _lastTrickCards,
          winnerName: _lastTrickWinnerId,
          onComplete: () => Navigator.pop(context),
        ),
      );
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
      team1Score = teamScores[1] ?? 0;
      team2Score = teamScores[2] ?? 0;
      roundNumber = game.roundNumber;
      _showBidPulse = false;
    });
  }

  Future<void> _showDevicePicker() async {
    final ctx = context;
    final devices = await widget.syncService.getPairedDevices();
    if (!ctx.mounted) return;

    if (devices.isEmpty) {
      showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
          title: Text(widget.strings.noDevicesFound),
          content: Text(widget.strings.noPairedDevices),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(widget.strings.ok),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(widget.strings.selectDevice),
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
                  Navigator.pop(ctx);
                  try {
                    await widget.syncService.connectToDevice(device.address);
                    if (!ctx.mounted) return;
                    setState(() {
                      _connectionStatus = "Connected to ${device.name ?? device.address}";
                    });
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text("✅ Connected to ${device.name ?? device.address}"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (_) {
                    if (!ctx.mounted) return;
                    setState(() {
                      _connectionStatus = "Connection failed";
                    });
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(widget.strings.connectionFailed),
                        backgroundColor: Colors.red,
                      ),
                    );
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
    final ctx = context;
    widget.syncService.disconnect();
    setState(() {
      _connectionStatus = "Not connected";
    });
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(widget.strings.disconnected),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.strings.gameTableTitle, key: const Key('gameScreenTitle')),
        actions: [
          IconButton(
            key: const Key('refreshSimulationButton'),
            icon: const Icon(Icons.refresh),
            tooltip: widget.strings.restartSimulation,
            onPressed: () {
              setState(() {
                resultText = widget.strings.simulationPrompt;
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

              FeedbackPulse(
                trigger: _showBidPulse,
                child: ElevatedButton.icon(
                  key: const Key('playButton'),
                  onPressed: runGameSimulation,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(widget.strings.runSimulation),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                key: const Key('connectMultiplayerButton'),
                onPressed: _showDevicePicker,
                icon: const Icon(Icons.wifi_tethering),
                label: Text(widget.strings.connectMultiplayer),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                key: const Key('disconnectButton'),
                onPressed: _disconnect,
                icon: const Icon(Icons.link_off),
                label: Text(widget.strings.disconnect),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                key: const Key('roundSummaryButton'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoundSummary(
                        team1Score: team1Score,
                        team2Score: team2Score,
                        roundNumber: roundNumber,
                        firebaseService: widget.firebaseService,
                        strings: widget.strings,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.summarize),
                label: Text(widget.strings.goToRoundSummary),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.green[700],
                  child: DealingAnimation(
                    key: _dealingKey,
                    batchSize: 4,
                    onBatchComplete: () {
                      debugPrint("✅ First batch complete → show bidding UI");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(widget.strings.firstBatchComplete),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                flex: 3,
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
                      reverse: true,
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
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('dealNextBatchButton'),
        onPressed: () {
          _dealingKey.currentState?.startNextBatch();
        },
        icon: const Icon(Icons.play_arrow),
        label: Text(widget.strings.dealNextBatch),
      ),
    );
  }
}