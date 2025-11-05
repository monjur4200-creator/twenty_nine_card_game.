import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:twenty_nine_card_game/screens/game_screen.dart';
import 'package:twenty_nine_card_game/services/firebase_service.dart';
import 'package:twenty_nine_card_game/services/presence_service.dart';
import 'package:twenty_nine_card_game/services/room_service.dart';
import 'package:twenty_nine_card_game/services/sync_service_interface.dart';
import 'package:twenty_nine_card_game/localization/strings.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';
import 'package:twenty_nine_card_game/screens/main_menu.dart';

class FakeServices {
  final FirebaseService firebase;
  final PresenceService presence;
  final RoomService room;
  final SyncService sync;

  FakeServices()
      : firebase = FirebaseService(
          auth: MockFirebaseAuth(),
          firestore: FakeFirebaseFirestore(),
        ),
        presence = _FakePresenceService(),
        room = _FakeRoomService(),
        sync = _DummySyncService();
}

class _FakePresenceService implements PresenceService {
  @override
  Future<void> setPlayerPresence(String r, String p, String n) async {}

  @override
  Future<void> removePlayer(String r, String p, String n) async {}

  @override
  Stream<List<Map<String, dynamic>>> getRoomPlayersStream(String r) async* {
    yield [];
  }
}

class _FakeRoomService implements RoomService {
  @override
  Stream<Map<String, dynamic>> listenToRoom(String r) async* {
    yield {};
  }

  @override
  Future<void> updateRoomStatus(String r, String s) async {}

  @override
  Future<void> createRoom(String roomId, Map<String, dynamic> data) async {}

  @override
  Future<int> getPlayerCount(String roomId) async => 0;

  @override
  Future<void> joinRoom(String roomId, Map<String, dynamic> playerData) async {}

  @override
  Future<void> deleteRoom(String roomId) async {}

  @override
  Future<Map<String, dynamic>> getRoom(String roomId) async => {};

  @override
  Future<void> leaveRoom(String roomId, Map<String, dynamic> playerData) async {}
}

class _DummySyncService implements SyncService {
  @override
  Future<List<BluetoothDevice>> getPairedDevices() async => <BluetoothDevice>[];

  @override
  Future<void> connectToDevice(String address) async {}

  @override
  void disconnect() {}

  @override
  void sendMessage(String message) {}

  @override
  void sendGameState(Map<String, dynamic> state) {}

  @override
  void sendPing() {}

  @override
  void startHeartbeat() {}

  @override
  void triggerResync() {}

  @override
  void onMessageReceived(void Function(String message) callback) {}

  @override
  void onConnected(void Function() callback) {}

  @override
  void onDisconnected(void Function() callback) {}

  @override
  void onLagDetected(void Function() callback) {}

  @override
  void onResync(void Function() callback) {}

  @override
  bool get isConnected => true;
}

Widget setupTestApp(FakeServices services, {MockUser? user, ConnectionType? connectionType}) {
  return MaterialApp(
    home: MainMenu(
      firebaseService: services.firebase,
      presenceService: services.presence,
      roomService: services.room,
      strings: Strings('en'),
      initialUser: user,
      initialConnectionType: connectionType,
    ),
  );
}

void main() {
  late FakeServices services;

  setUp(() => services = FakeServices());

  group('UI Smoke Tests', () {
    testWidgets('App loads and shows Main Menu', (tester) async {
      await tester.pumpWidget(setupTestApp(services));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('mainMenuTitle')), findsOneWidget);
    });

    testWidgets('Main Menu shows all expected buttons and fields', (tester) async {
      await tester.pumpWidget(setupTestApp(services));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('startGameButton')), findsOneWidget);
      expect(find.byKey(const Key('createRoomButton')), findsOneWidget);
      expect(find.byKey(const Key('roomIdField')), findsOneWidget);
      expect(find.byKey(const Key('joinRoomButton')), findsOneWidget);
      expect(find.byKey(const Key('rulesButton')), findsOneWidget);
      expect(find.byKey(const Key('settingsButton')), findsOneWidget);
    });

    testWidgets('Game screen shows correct title', (tester) async {
      final testPlayer = Player(
        id: 1,
        name: 'TestPlayer',
        teamId: 1,
        loginMethod: LoginMethod.guest,
        connectionType: ConnectionType.local,
      );

      await tester.pumpWidget(MaterialApp(
        home: GameScreen(
          firebaseService: services.firebase,
          strings: Strings('en'),
          player: testPlayer,
          syncService: services.sync,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('gameScreenTitle')), findsOneWidget);
    });

    testWidgets('Tapping Start Game navigates to GameScreen', (tester) async {
      final mockUser = MockUser(uid: 'test123', displayName: 'TestPlayer');

      await tester.pumpWidget(setupTestApp(
        services,
        user: mockUser,
        connectionType: ConnectionType.local,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('login_Guest')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('connection_local'))); // ✅ Fixed key
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('startGameButton')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('gameScreenTitle')), findsOneWidget);
    });

    testWidgets('Tapping Create Room navigates to LobbyScreen', (tester) async {
      await tester.pumpWidget(setupTestApp(services));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('createRoomButton')));
      await tester.tap(find.byKey(const Key('createRoomButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lobbyTitle')), findsOneWidget);
    });

    testWidgets('Tapping Join Room navigates to LobbyScreen', (tester) async {
      await tester.pumpWidget(setupTestApp(services));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('roomIdField')), 'test-room-123');
      await tester.ensureVisible(find.byKey(const Key('joinRoomButton')));
      await tester.tap(find.byKey(const Key('joinRoomButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lobbyTitle')), findsOneWidget);
    });

    testWidgets('Tapping Leave Room navigates back to Main Menu', (tester) async {
      await tester.pumpWidget(setupTestApp(services));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('createRoomButton')));
      await tester.tap(find.byKey(const Key('createRoomButton')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('leaveRoomButton')));
      await tester.tap(find.byKey(const Key('leaveRoomButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('mainMenuTitle')), findsOneWidget);
    });
  });
}