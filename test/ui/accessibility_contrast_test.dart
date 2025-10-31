import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:twenty_nine_card_game/main.dart';
import 'package:twenty_nine_card_game/services/firebase_service.dart';
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
  group('Accessibility - Contrast', () {
    testWidgets('Main Menu text is visible against background',
        (WidgetTester tester) async {
      final fakeFirestore = FakeFirebaseFirestore();
      final mockAuth = MockFirebaseAuth();
      final fakeService =
          FirebaseService(auth: mockAuth, firestore: fakeFirestore);

      await tester.pumpWidget(
        MaterialApp(
          home: TwentyNineApp(
            firebaseService: fakeService,
            presenceService: FakePresenceService(),
            roomService: FakeRoomService(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Find the text widget
      final finder = find.text('Main Menu');
      expect(finder, findsOneWidget);

      final textWidget = tester.widget<Text>(finder);

      // If style is null, fall back to DefaultTextStyle
      final effectiveStyle = textWidget.style ??
          DefaultTextStyle.of(tester.element(finder)).style;

      expect(effectiveStyle.color, isNotNull);
      // Use .a (alpha channel, 0–255) instead of .opacity
      expect(effectiveStyle.color!.opacity, greaterThan(0.8),
        reason: 'Main Menu text color is too transparent for good contrast');
    });
  });
}