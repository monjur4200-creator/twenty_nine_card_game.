import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:twenty_nine_card_game/screens/main_menu.dart';
import 'package:twenty_nine_card_game/localization/strings.dart';
import 'package:twenty_nine_card_game/services/firebase_service.dart';
import 'package:twenty_nine_card_game/services/presence_service.dart';
import 'package:twenty_nine_card_game/services/room_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class DummyPresenceService implements PresenceService {
  @override
  Future<void> setPlayerPresence(String r, String p, String n) async {}
  @override
  Future<void> removePlayer(String r, String p, String n) async {}
  @override
  Stream<List<Map<String, dynamic>>> getRoomPlayersStream(String r) async* {
    yield [];
  }
}

class DummyRoomService implements RoomService {
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

void main() {
  testWidgets('MainMenu golden test', (tester) async {
    final firebase = FirebaseService(
      auth: MockFirebaseAuth(),
      firestore: FakeFirebaseFirestore(),
    );

    await tester.pumpWidget(MaterialApp(
      home: MainMenu(
        firebaseService: firebase,
        presenceService: DummyPresenceService(),
        roomService: DummyRoomService(),
        strings: Strings('en'),
      ),
    ));

    await expectLater(
      find.byType(MainMenu),
      matchesGoldenFile('goldens/main_menu.png'),
    );
  });
}