import '../fakes/fakes.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:twenty_nine_card_game/main.dart';
import 'package:twenty_nine_card_game/services/presence_service.dart';
import 'package:twenty_nine_card_game/services/room_service.dart';
import 'package:twenty_nine_card_game/localization/strings.dart';

/// Minimal fakes for this test
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
  group('Accessibility - Text Scaling', () {
    testWidgets('Main Menu handles large text scale without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.5)),
          child: MaterialApp(
            home: TwentyNineApp(
              firebaseService: FakeFirebaseService(),
              presenceService: FakePresenceService(),
              roomService: FakeRoomService(),
              strings: Strings('en'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Main Menu'), findsOneWidget);
      expect(find.byKey(const Key('startGameButton')), findsOneWidget);
      expect(find.byKey(const Key('createRoomButton')), findsOneWidget);
      expect(find.byKey(const Key('joinRoomButton')), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}