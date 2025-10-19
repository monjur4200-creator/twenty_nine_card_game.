import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'game_screen.dart';
import '../services/firebase_service.dart';
import '../services/presence_service.dart';
import '../services/room_service.dart';
import 'lobby_screen.dart';

class MainMenu extends StatefulWidget {
  final FirebaseService firebaseService;
  final PresenceService? presenceService;
  final RoomService? roomService;

  const MainMenu({
    super.key,
    required this.firebaseService,
    this.presenceService,
    this.roomService,
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late final FirebaseService _firebaseService;
  late final PresenceService? _presenceService;
  late final RoomService? _roomService;

  final TextEditingController _roomIdController = TextEditingController();
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _firebaseService = widget.firebaseService;
    _presenceService = widget.presenceService;
    _roomService = widget.roomService;
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Menu"),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.green[200],
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Start Game ---
                ElevatedButton(
                  key: const Key('startGameButton'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            GameScreen(firebaseService: _firebaseService),
                      ),
                    );
                  },
                  child: const Text("Start Game"),
                ),
                const SizedBox(height: 20),

                // --- Create Room ---
                ElevatedButton(
                  key: const Key('createRoomButton'),
                  onPressed: () async {
                    final roomId =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    final playerId = _uuid.v4();
                    const displayName = "Player 1";

                    await _firebaseService.createRoom(roomId, {
                      "players": [],
                      "status": "waiting",
                      "createdAt": DateTime.now(),
                    });

                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LobbyScreen(
                          roomId: roomId,
                          playerId: playerId,
                          playerName: displayName,
                          firebaseService: _firebaseService,
                          presenceService: _presenceService,
                          roomService: _roomService,
                        ),
                      ),
                    );
                  },
                  child: const Text("Create Room"),
                ),
                const SizedBox(height: 20),

                // --- Join Room ---
                TextField(
                  key: const Key('roomIdField'),
                  controller: _roomIdController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter Room ID",
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  key: const Key('joinRoomButton'),
                  onPressed: () async {
                    final roomId = _roomIdController.text.trim();
                    if (roomId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a Room ID")),
                      );
                      return;
                    }

                    final playerId = _uuid.v4();
                    final count = await _firebaseService.getPlayerCount(roomId);
                    final displayName = "Player ${count + 1}";

                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LobbyScreen(
                          roomId: roomId,
                          playerId: playerId,
                          playerName: displayName,
                          firebaseService: _firebaseService,
                          presenceService: _presenceService,
                          roomService: _roomService,
                        ),
                      ),
                    );
                  },
                  child: const Text("Join Room"),
                ),
                const SizedBox(height: 20),

                // --- Rules ---
                ElevatedButton(
                  key: const Key('rulesButton'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Rules screen coming soon!"),
                      ),
                    );
                  },
                  child: const Text("Rules"),
                ),
                const SizedBox(height: 20),

                // --- Settings ---
                ElevatedButton(
                  key: const Key('settingsButton'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Settings screen coming soon!"),
                      ),
                    );
                  },
                  child: const Text("Settings"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}