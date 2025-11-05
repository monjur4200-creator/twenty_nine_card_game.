import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twenty_nine_card_game/main.dart';
import 'package:twenty_nine_card_game/services/firebase_service.dart';
import 'package:twenty_nine_card_game/services/presence_service.dart';
import 'package:twenty_nine_card_game/services/room_service.dart';
import 'package:twenty_nine_card_game/services/auth_service.dart';
import 'package:twenty_nine_card_game/localization/strings.dart';

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

/// ✅ Fake AuthService to prevent FirebaseAuth.instance
class FakeAuthService implements AuthService {
  @override
  Future<void> logout() async {}

  @override
  Future<User?> loginAsGuest() async => null;

  @override
  User? get currentUser => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Accessibility - Contrast', () {
    testWidgets('Main Menu text is visible against background', (WidgetTester tester) async {
      final fakeFirestore = FakeFirebaseFirestore();
      final mockAuth = MockFirebaseAuth();
      final fakeService = FirebaseService(auth: mockAuth, firestore: fakeFirestore);

      await tester.pumpWidget(
        TwentyNineApp(
          firebaseService: fakeService,
          presenceService: FakePresenceService(),
          roomService: FakeRoomService(),
          strings: Strings('en'),
          authService: FakeAuthService(), // ✅ Injected
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      final finder = find.text('Main Menu');
      expect(finder, findsOneWidget);

      final effectiveStyle = DefaultTextStyle.of(tester.element(finder)).style;

      // ignore: avoid_print
      print('Resolved style color: ${effectiveStyle.color}');

      expect(effectiveStyle.color, isNotNull);
      final alpha = (effectiveStyle.color!.a * 255.0).round() & 0xff;
      expect(alpha, greaterThan(204));
    });
  });
}