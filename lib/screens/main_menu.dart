import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'game_screen.dart';
import 'lobby_screen.dart';
import 'rules_screen.dart';

import '../services/firebase_service.dart';
import '../services/presence_service.dart';
import '../services/presence_service_impl.dart';
import '../services/room_service.dart';
import '../services/room_service_impl.dart';
import '../services/sync_service_interface.dart';
import '../services/sync_service.dart';
import '../localization/strings.dart';

import '../widgets/login_selector.dart';
import '../widgets/connection_selector.dart';
import '../models/connection_type.dart';
import '../models/player.dart';
import '../models/login_method.dart';
import '../services/auth_service.dart';

class MainMenu extends StatefulWidget {
  final FirebaseService firebaseService;
  final PresenceService? presenceService;
  final RoomService? roomService;
  final Strings strings;
  final AuthService? authService;

  // ✅ Test injection support
  final User? initialUser;
  final ConnectionType? initialConnectionType;

  const MainMenu({
    super.key,
    required this.firebaseService,
    required this.strings,
    this.presenceService,
    this.roomService,
    this.authService,
    this.initialUser,
    this.initialConnectionType,
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late final FirebaseService _firebaseService;
  late final PresenceService _presenceService;
  late final RoomService _roomService;
  late final AuthService _authService;

  final SyncService _syncService = BluetoothSyncService();
  final TextEditingController _roomIdController = TextEditingController();
  final Uuid _uuid = const Uuid();

  User? _user;
  ConnectionType? _connectionType;

  @override
  void initState() {
    super.initState();
    _firebaseService = widget.firebaseService;
    _presenceService = widget.presenceService ?? FirebasePresenceService();
    _roomService = widget.roomService ?? FirestoreRoomService();
    _authService = widget.authService ?? AuthService(auth: _firebaseService.auth);

    // ✅ Inject test state
    _user = widget.initialUser;
    _connectionType = widget.initialConnectionType;
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          strings.mainMenuTitle,
          key: const Key('mainMenuTitle'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.green[200],
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoginSelector(
                    authService: _authService,
                    onLogin: (user) {
                      setState(() {
                        _user = user;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ConnectionSelector(
                    onSelected: (type) {
                      setState(() {
                        _connectionType = type;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    key: const Key('startGameButton'),
                    onPressed: () {
                      if (_user == null || _connectionType == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(strings.loginAndConnectWarning)),
                        );
                        return;
                      }

                      final name = _user!.displayName ?? "Guest";
                      final player = Player(
                        id: 0,
                        name: name,
                        teamId: 0,
                        loginMethod: LoginMethod.guest,
                        connectionType: _connectionType!,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            firebaseService: _firebaseService,
                            strings: strings,
                            player: player,
                            syncService: _syncService,
                          ),
                        ),
                      );
                    },
                    child: Text(strings.startGame),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    key: const Key('createRoomButton'),
                    onPressed: () async {
                      final roomId = DateTime.now().millisecondsSinceEpoch.toString();
                      final playerId = _uuid.v4();
                      const displayName = "Player 1";

                      final player = Player(
                        id: 0,
                        name: displayName,
                        teamId: 0,
                        loginMethod: LoginMethod.guest,
                        connectionType: _connectionType ?? ConnectionType.local,
                      );

                      await _roomService.createRoom(roomId, {
                        "hostId": playerId,
                        "players": [],
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
                            strings: strings,
                            player: player,
                            syncService: _syncService,
                            connectionType: _connectionType ?? ConnectionType.local,
                          ),
                        ),
                      );
                    },
                    child: Text(strings.createRoom),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    key: const Key('roomIdField'),
                    controller: _roomIdController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: strings.enterRoomId,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    key: const Key('joinRoomButton'),
                    onPressed: () async {
                      final roomId = _roomIdController.text.trim();
                      if (roomId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(strings.pleaseEnterRoomId)),
                        );
                        return;
                      }

                      final playerId = _uuid.v4();
                      final count = await _roomService.getPlayerCount(roomId);
                      final displayName = "Player ${count + 1}";

                      final player = Player(
                        id: count + 1,
                        name: displayName,
                        teamId: 0,
                        loginMethod: LoginMethod.guest,
                        connectionType: _connectionType ?? ConnectionType.local,
                      );

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
                            strings: strings,
                            player: player,
                            syncService: _syncService,
                            connectionType: _connectionType ?? ConnectionType.local,
                          ),
                        ),
                      );
                    },
                    child: Text(strings.joinRoom),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    key: const Key('rulesButton'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RulesScreen(),
                        ),
                      );
                    },
                    child: Text(strings.viewRules),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    key: const Key('settingsButton'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.enjoyGame)),
                      );
                    },
                    child: Text(strings.settings),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}