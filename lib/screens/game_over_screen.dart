import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/presence_service.dart';
import '../services/room_service.dart';
import 'lobby_screen.dart';

class GameOverScreen extends StatelessWidget {
  final int team1Score;
  final int team2Score;
  final String roomId;
  final String playerId;
  final String playerName;
  final FirebaseService firebaseService;
  final PresenceService presenceService;   // ✅ added
  final RoomService roomService;           // ✅ added

  const GameOverScreen({
    super.key,
    required this.team1Score,
    required this.team2Score,
    required this.roomId,
    required this.playerId,
    required this.playerName,
    required this.firebaseService,
    required this.presenceService,   // ✅ added
    required this.roomService,       // ✅ added
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Twenty Nine - Game Over")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "📊 Final Match Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("Team 1 Score: $team1Score",
                style: const TextStyle(fontSize: 18)),
            Text("Team 2 Score: $team2Score",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LobbyScreen(
                      roomId: roomId,
                      playerId: playerId,
                      playerName: playerName,
                      firebaseService: firebaseService,
                      presenceService: presenceService,   // ✅ forward
                      roomService: roomService,           // ✅ forward
                    ),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.home),
              label: const Text("Back to Lobby"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}