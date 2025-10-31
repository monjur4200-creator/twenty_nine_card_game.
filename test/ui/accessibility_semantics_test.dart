import '../fakes/fakes.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:twenty_nine_card_game/main.dart';
import 'package:twenty_nine_card_game/services/presence_service.dart';
import 'package:twenty_nine_card_game/services/room_service.dart';

/// Minimal fakes
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

class FakeRoomService implements RoomService {
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
  group('Accessibility - Semantics', () {
    testWidgets('Buttons have semantic labels for screen readers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TwentyNineApp(
            firebaseService: FakeFirebaseService(),
            presenceService: FakePresenceService(),
            roomService: FakeRoomService(),
          ),
        ),
      );

      // Give the widget tree time to rebuild after the fake service emits
      await tester.pump(const Duration(milliseconds: 100));

      // Check that Start Game button has a semantic label
      final semantics = tester.getSemantics(find.byKey(const Key('startGameButton')));
      expect(semantics.label, isNotEmpty,
          reason: 'Start Game button should have a semantic label');

      // Check that Create Room button has a semantic label
      final semantics2 = tester.getSemantics(find.byKey(const Key('createRoomButton')));
      expect(semantics2.label, isNotEmpty,
          reason: 'Create Room button should have a semantic label');
    });
  });
}
