import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:twenty_nine_card_game/main.dart';
import 'package:twenty_nine_card_game/services/firebase_service.dart';
import 'package:twenty_nine_card_game/services/presence_service.dart';
import 'package:twenty_nine_card_game/services/room_service.dart';
import 'package:twenty_nine_card_game/localization/strings.dart';

/// Fake PresenceService that lets us simulate players joining/leaving
class TestableFakePresenceService implements PresenceService {
  final StreamController<List<Map<String, dynamic>>> _controller =
      StreamController.broadcast();
  final List<Map<String, dynamic>> _players = [];

  @override
  Future<void> setPlayerPresence(
      String roomId, String playerId, String playerName) async {
    _players.add({'id': playerId, 'name': playerName});
    _controller.add(List<Map<String, dynamic>>.from(_players));
  }

  @override
  Future<void> removePlayer(
      String roomId, String playerId, String playerName) async {
    _players.removeWhere((p) => p['id'] == playerId);
    _controller.add(List<Map<String, dynamic>>.from(_players));
  }

  @override
  Stream<List<Map<String, dynamic>>> getRoomPlayersStream(String roomId) {
    return _controller.stream;
  }
}

/// Minimal Fake RoomService
class TestableFakeRoomService implements RoomService {
  @override
  Future<void> createRoom(String roomId, Map<String, dynamic> data) async {}

  @override
  Future<void> deleteRoom(String roomId) async {}

  @override
  Future<Map<String, dynamic>> getRoom(String roomId) async => {};

  @override
  Future<int> getPlayerCount(String roomId) async => 0;

  @override
  Future<void> joinRoom(String roomId, Map<String, dynamic> playerData) async {}

  @override
  Future<void> leaveRoom(String roomId, Map<String, dynamic> playerData) async {}

  @override
  Stream<Map<String, dynamic>> listenToRoom(String roomId) async* {
    yield {};
  }

  @override
  Future<void> updateRoomStatus(String roomId, String status) async {}
}

void main() {
  late FirebaseService fakeService;
  late TestableFakePresenceService fakePresence;
  late TestableFakeRoomService fakeRoom;

  setUp(() {
    final fakeFirestore = FakeFirebaseFirestore();
    final mockAuth = MockFirebaseAuth();
    fakeService = FirebaseService(auth: mockAuth, firestore: fakeFirestore);
    fakePresence = TestableFakePresenceService();
    fakeRoom = TestableFakeRoomService();
  });

  group('Lobby Leave Player Test', () {
    testWidgets('Lobby updates when a player leaves', (WidgetTester tester) async {
      await tester.pumpWidget(
        TwentyNineApp(
          firebaseService: fakeService,
          presenceService: fakePresence,
          roomService: fakeRoom,
          strings: Strings('en'),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byKey(const Key('createRoomButton')));
      await tester.pump(const Duration(milliseconds: 100));

      await fakePresence.setPlayerPresence('room1', 'p1', 'Mongur');
      await fakePresence.setPlayerPresence('room1', 'p2', 'Ada');
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Mongur'), findsOneWidget);
      expect(find.text('Ada'), findsOneWidget);

      await fakePresence.removePlayer('room1', 'p1', 'Mongur');
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Mongur'), findsNothing);
      expect(find.text('Ada'), findsOneWidget);
    });
  });
}