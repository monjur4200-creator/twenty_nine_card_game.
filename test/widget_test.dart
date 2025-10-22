import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:twenty_nine_card_game/main.dart';
import 'package:twenty_nine_card_game/services/firebase_service.dart';
import 'package:twenty_nine_card_game/screens/game_screen.dart';
import 'package:twenty_nine_card_game/services/presence_service.dart';
import 'package:twenty_nine_card_game/services/room_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Fake PresenceService that never touches Firebase
class FakePresenceService implements PresenceService {
  @override
  Future<void> setPlayerPresence(String r, String p, String n) async {}

  @override
  Future<void> removePlayer(String r, String p, String n) async {}

  @override
  Stream<List<Map<String, dynamic>>> getRoomPlayersStream(String r) async* {
    yield [];
  }
}

/// Fake RoomService that never touches Firebase
class FakeRoomService implements RoomService {
  final FakeFirebaseFirestore _fakeFirestore = FakeFirebaseFirestore();

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
  FirebaseFirestore get firestore => _fakeFirestore;
}

void main() {
  late FirebaseService fakeService;
  late FakePresenceService fakePresence;
  late FakeRoomService fakeRoom;

  setUp(() {
    final fakeFirestore = FakeFirebaseFirestore();
    final mockAuth = MockFirebaseAuth(); // ✅ mock auth instead of real
    fakeService = FirebaseService(auth: mockAuth, firestore: fakeFirestore);
    fakePresence = FakePresenceService();
    fakeRoom = FakeRoomService();
  });

  group('UI Smoke Tests', () {
    testWidgets('App loads and shows Main Menu', (WidgetTester tester) async {
      await tester.pumpWidget(
        TwentyNineApp(
          firebaseService: fakeService,
          presenceService: fakePresence,
          roomService: fakeRoom,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Main Menu'), findsOneWidget);
    });

    testWidgets('Main Menu shows all expected buttons and fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        TwentyNineApp(
          firebaseService: fakeService,
          presenceService: fakePresence,
          roomService: fakeRoom,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('startGameButton')), findsOneWidget);
      expect(find.byKey(const Key('createRoomButton')), findsOneWidget);
      expect(find.byKey(const Key('roomIdField')), findsOneWidget);
      expect(find.byKey(const Key('joinRoomButton')), findsOneWidget);
      expect(find.byKey(const Key('rulesButton')), findsOneWidget);
      expect(find.byKey(const Key('settingsButton')), findsOneWidget);
    });

    testWidgets('Game screen shows correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(firebaseService: fakeService)),
      );
      expect(find.text('Twenty Nine - Game Table'), findsOneWidget);
    });

    testWidgets('Tapping Start Game navigates to GameScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        TwentyNineApp(
          firebaseService: fakeService,
          presenceService: fakePresence,
          roomService: fakeRoom,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('startGameButton')));
      await tester.pumpAndSettle();
      expect(find.text('Twenty Nine - Game Table'), findsOneWidget);
    });

    testWidgets('Tapping Create Room navigates to LobbyScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        TwentyNineApp(
          firebaseService: fakeService,
          presenceService: fakePresence,
          roomService: fakeRoom,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('createRoomButton')));
      await tester.pumpAndSettle();
      expect(find.text('Lobby'), findsOneWidget);
    });

    testWidgets('Tapping Join Room navigates to LobbyScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        TwentyNineApp(
          firebaseService: fakeService,
          presenceService: fakePresence,
          roomService: fakeRoom,
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('roomIdField')),
        'test-room-123',
      );
      await tester.tap(find.byKey(const Key('joinRoomButton')));
      await tester.pumpAndSettle();
      expect(find.text('Lobby'), findsOneWidget);
    });

    testWidgets('Tapping Leave Room navigates back to Main Menu', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        TwentyNineApp(
          firebaseService: fakeService,
          presenceService: fakePresence,
          roomService: fakeRoom,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('createRoomButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('leaveRoomButton')));
      await tester.pumpAndSettle();
      expect(find.text('Main Menu'), findsOneWidget);
    });
  });
}
