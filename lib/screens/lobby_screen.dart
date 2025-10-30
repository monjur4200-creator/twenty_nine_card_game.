import 'package:flutter/material.dart';
import '../services/presence_service.dart';
import '../services/room_service.dart';
import '../services/firebase_service.dart';
import 'main_menu.dart';

class LobbyScreen extends StatefulWidget {
  final String roomId;
  final String playerId;
  final String playerName;
  final FirebaseService firebaseService;
  final PresenceService presenceService;
  final RoomService roomService;

  LobbyScreen({
    // 👈 removed "const"
    super.key,
    required this.roomId,
    required this.playerId,
    required this.playerName,
    required this.firebaseService,
    PresenceService? presenceService,
    RoomService? roomService,
  }) : presenceService = presenceService ?? PresenceService(),
       roomService = roomService ?? RoomService();

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  String? _hostId;

  @override
  void initState() {
    super.initState();

    // Mark this player as present in the room
    widget.presenceService.setPlayerPresence(
      widget.roomId,
      widget.playerId,
      widget.playerName,
    );

    // Listen to room metadata to know who the host is
    widget.roomService.listenToRoom(widget.roomId).listen((roomData) {
      if (roomData.isNotEmpty) {
        setState(() {
          _hostId = roomData['hostId'];
        });
      }
    });
  }

  Future<void> _leaveRoom(BuildContext context) async {
    await widget.presenceService.removePlayer(
      widget.roomId,
      widget.playerId,
      widget.playerName,
    );
    if (!context.mounted) return;
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
    // Later: navigate to GameScreen when status == active
  }

  Widget _buildPlayerList(List<Map<String, dynamic>> players) {
    if (players.isEmpty) {
      return Center(child: Text("Waiting for players..."));
    }

    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final isCurrentUser = player['id'] == widget.playerId;

        return ListTile(
          leading: Icon(Icons.person),
          title: Text(player['name']),
          trailing: isCurrentUser
              ? Text(
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
        if (didPop) return;
        await _leaveRoom(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Lobby"),
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
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return _buildPlayerList(snapshot.data!);
                },
              ),
            ),

            // --- Host-only Start Game Button ---
            if (isHost)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ElevatedButton.icon(
                  key: Key('startGameButton'),
                  onPressed: _startGame,
                  icon: Icon(Icons.play_arrow),
                  label: Text("Start Game"),
                ),
              ),

            // --- Leave Room Button ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                key: Key('leaveRoomButton'),
                onPressed: () => _leaveRoom(context),
                child: Text("Leave Room"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
