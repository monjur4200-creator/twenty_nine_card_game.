import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/presence_service.dart';
import '../services/room_service.dart';
import '../services/sync_service_interface.dart';
import '../localization/strings.dart';
import '../models/player.dart';
import '../models/connection_type.dart';
import 'lobby_screen.dart';

class GameOverScreen extends StatelessWidget {
  final int team1Score;
  final int team2Score;
  final String roomId;
  final String playerId;
  final String playerName;
  final FirebaseService firebaseService;
  final PresenceService presenceService;
  final RoomService roomService;
  final Strings strings;
  final Player player;
  final SyncService syncService;
  final ConnectionType connectionType;

  const GameOverScreen({
    super.key,
    required this.team1Score,
    required this.team2Score,
    required this.roomId,
    required this.playerId,
    required this.playerName,
    required this.firebaseService,
    required this.presenceService,
    required this.roomService,
    required this.strings,
    required this.player,
    required this.syncService,
    required this.connectionType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${strings.mainMenuTitle} - Game Over"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            key: const Key('gameOverContent'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "📊 Final Match Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text("Team 1 Score: $team1Score", style: const TextStyle(fontSize: 18)),
              Text("Team 2 Score: $team2Score", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                key: const Key('returnToLobbyButton'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LobbyScreen(
                        roomId: roomId,
                        playerId: playerId,
                        playerName: playerName,
                        firebaseService: firebaseService,
                        presenceService: presenceService,
                        roomService: roomService,
                        strings: strings,
                        player: player,
                        syncService: syncService,
                        connectionType: connectionType,
                      ),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: Text(strings.leaveRoom),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}