import 'dart:async';
import 'package:flutter/material.dart';

import '../services/room_service.dart';
import '../services/firebase_service.dart';
import '../services/presence_service.dart';
import '../services/sync_service_interface.dart';
import '../localization/strings.dart';

import '../widgets/player_banner.dart';
import 'main_menu.dart';
import 'game_screen.dart';

import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';

class LobbyScreen extends StatefulWidget {
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

  const LobbyScreen({
    super.key,
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

        if (roomData['status'] == 'active') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => GameScreen(
                firebaseService: widget.firebaseService,
                strings: widget.strings,
                player: widget.player,
                syncService: widget.syncService,
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
          strings: widget.strings,
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
      return Center(child: Text(widget.strings.waitingForPlayers));
    }

    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final data = players[index];
        final name = data['name'] ?? widget.strings.unknownPlayer;
        final id = data['id'] ?? 'unknown';
        final isCurrentUser = id == widget.playerId;

        final player = Player(
          id: index,
          name: name,
          teamId: 0,
          loginMethod: LoginMethod.guest,
          connectionType: widget.connectionType,
        );

        return PlayerBanner(
          player: player,
          isConnected: isCurrentUser,
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
          title: Text(
            widget.strings.lobbyTitle,
            key: const Key('lobbyTitle'), // ✅ Required for UI smoke test
          ),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: widget.presenceService.getRoomPlayersStream(widget.roomId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(widget.strings.waitingForPlayers));
                  }
                  return _buildPlayerList(snapshot.data!);
                },
              ),
            ),
            if (isHost)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  key: const Key('startGameButton'), // ✅ Required for UI smoke test
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(widget.strings.startGame),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                key: const Key('leaveRoomButton'), // ✅ Required for UI smoke test
                onPressed: _leaveRoom,
                child: Text(widget.strings.leaveRoom),
              ),
            ),
          ],
        ),
      ),
    );
  }
}