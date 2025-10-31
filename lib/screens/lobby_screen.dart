import 'dart:async';
import 'package:flutter/material.dart';
import '../services/room_service.dart';
import '../services/firebase_service.dart';
import 'main_menu.dart';
import 'game_screen.dart';
import 'package:twenty_nine_card_game/services/presence_service.dart';

class LobbyScreen extends StatefulWidget {
  final String roomId;
  final String playerId;
  final String playerName;
  final FirebaseService firebaseService;
  final PresenceService presenceService;
  final RoomService roomService;

  const LobbyScreen({
    super.key,
    required this.roomId,
    required this.playerId,
    required this.playerName,
    required this.firebaseService,
    required this.presenceService,
    required this.roomService,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  String? _hostId;
  StreamSubscription<Map<String, dynamic>>? _roomSub;

  @override
  void initState() {
    super.initState();

    widget.presenceService.setPlayerPresence(
      widget.roomId,
      widget.playerId,
      widget.playerName,
    );

    _roomSub = widget.roomService.listenToRoom(widget.roomId).listen((roomData) {
      if (roomData.isNotEmpty && mounted) {
        setState(() {
          _hostId = roomData['hostId'] as String?;
        });

        // 🚀 Navigate to GameScreen when status == active
        if (roomData['status'] == 'active') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => GameScreen(
                firebaseService: widget.firebaseService,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _roomSub?.cancel();
    super.dispose();
  }

  Future<void> _leaveRoom() async {
    await widget.presenceService.removePlayer(
      widget.roomId,
      widget.playerId,
      widget.playerName,
    );
    if (!mounted) return;
    _navigateToMainMenu();
  }

  void _navigateToMainMenu() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainMenu(
          firebaseService: widget.firebaseService,
          presenceService: widget.presenceService,
          roomService: widget.roomService,
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _startGame() async {
    await widget.roomService.updateRoomStatus(widget.roomId, "active");
  }

  Widget _buildPlayerList(List<Map<String, dynamic>> players) {
    if (players.isEmpty) {
      return const Center(child: Text("Waiting for players..."));
    }

    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final isCurrentUser = player['id'] == widget.playerId;

        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(player['name'] ?? 'Unknown'),
          trailing: isCurrentUser
              ? const Text(
                  "(You)",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.blue,
                  ),
                )
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHost = widget.playerId == _hostId;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        await _leaveRoom();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Lobby",
            key: Key('lobbyTitle'), // 👈 smoke test expects this
          ),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            // --- Player List ---
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: widget.presenceService.getRoomPlayersStream(
                  widget.roomId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Waiting for players..."));
                  }
                  return _buildPlayerList(snapshot.data!);
                },
              ),
            ),

            // --- Host-only Start Game Button ---
            if (isHost)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  key: const Key('startGameButton'),
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start Game"),
                ),
              ),

            // --- Leave Room Button ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                key: const Key('leaveRoomButton'),
                onPressed: _leaveRoom,
                child: const Text("Leave Room"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}