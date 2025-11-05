import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:twenty_nine_card_game/main.dart';
import 'package:twenty_nine_card_game/services/presence_service.dart';
import 'package:twenty_nine_card_game/services/room_service.dart';
import 'package:twenty_nine_card_game/services/firebase_service.dart';
import 'package:twenty_nine_card_game/localization/strings.dart';

import '../mocks/mocks.mocks.dart'; // ✅ generated mock classes

/// ✅ Firebase mock that satisfies the interface without triggering Firebase.initializeApp()
class FakeFirebaseService implements FirebaseService {
  @override
  final FirebaseAuth auth;

  @override
  final FirebaseFirestore firestore;

  FakeFirebaseService({
    required this.auth,
    required this.firestore,
  });

  @override
  Future<void> addPlayer(String roomId, Map<String, dynamic> playerData) async {}

  @override
  Future<void> createRoom(String roomId, Map<String, dynamic> data) async {}

  @override
  Future<int> getPlayerCount(String roomId) async => 0;

  @override
  Future<void> removePlayer(String roomId, Map<String, dynamic> playerData) async {}

  @override
  Future<UserCredential?> signInAnonymously() async => null;

  Future<void> signOut() async {}

  Future<void> initialize() async {}

  String getCurrentUserId() => 'fake-user-id';

  Stream<String> getUserIdStream() async* {
    yield 'fake-user-id';
  }

  bool isSignedIn() => true;
}

/// ✅ Minimal presence service mock
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

/// ✅ Minimal room service mock
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
    testWidgets('Buttons have semantic labels for screen readers', (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = MockFirebaseFirestore();

      await tester.pumpWidget(
        MaterialApp(
          home: TwentyNineApp(
            firebaseService: FakeFirebaseService(
              auth: mockAuth,
              firestore: mockFirestore,
            ),
            presenceService: FakePresenceService(),
            roomService: FakeRoomService(),
            strings: Strings('en'),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      final startGameSemantics = tester.getSemantics(find.byKey(const Key('startGameButton')));
      expect(startGameSemantics.label, isNotEmpty, reason: 'Start Game button should have a semantic label');

      final createRoomSemantics = tester.getSemantics(find.byKey(const Key('createRoomButton')));
      expect(createRoomSemantics.label, isNotEmpty, reason: 'Create Room button should have a semantic label');
    });
  });
}