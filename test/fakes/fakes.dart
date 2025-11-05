import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:twenty_nine_card_game/services/presence_service.dart';
import 'package:twenty_nine_card_game/services/room_service.dart';
import 'package:twenty_nine_card_game/services/firebase_service.dart';

/// Fake PresenceService that never touches Firebase.
class FakePresenceService implements PresenceService {
  final StreamController<List<Map<String, dynamic>>> _controller =
      StreamController.broadcast();
  final List<Map<String, dynamic>> _players = [];

  @override
  Future<void> setPlayerPresence(
    String roomId,
    String playerId,
    String playerName,
  ) async {
    _players.add({'id': playerId, 'name': playerName});
    _controller.add(List<Map<String, dynamic>>.from(_players));
  }

  @override
  Future<void> removePlayer(
    String roomId,
    String playerId,
    String playerName,
  ) async {
    _players.removeWhere((p) => p['id'] == playerId);
    _controller.add(List<Map<String, dynamic>>.from(_players));
  }

  @override
  Stream<List<Map<String, dynamic>>> getRoomPlayersStream(String roomId) {
    return _controller.stream;
  }
}

/// Fake RoomService that never touches real Firestore.
class FakeRoomService implements RoomService {
  final FakeFirebaseFirestore _fakeFirestore = FakeFirebaseFirestore();

  @override
  Stream<Map<String, dynamic>> listenToRoom(String roomId) async* {
    yield {};
  }

  @override
  Future<void> updateRoomStatus(String roomId, String status) async {}

  @override
  Future<void> createRoom(String roomId, Map<String, dynamic> data) async {}

  @override
  Future<void> joinRoom(String roomId, Map<String, dynamic> playerData) async {}

  @override
  Future<void> deleteRoom(String roomId) async {}

  @override
  Future<int> getPlayerCount(String roomId) async => 0;

  FirebaseFirestore get firestore => _fakeFirestore;

  @override
  Future<Map<String, dynamic>> getRoom(String roomId) async => {};

  @override
  Future<void> leaveRoom(String roomId, Map<String, dynamic> playerData) async {}
}

/// Fake FirebaseService that never touches real Firebase.
class FakeFirebaseService implements FirebaseService {
  final MockFirebaseAuth _mockAuth = MockFirebaseAuth();
  final FakeFirebaseFirestore _fakeFirestore = FakeFirebaseFirestore();

  @override
  FirebaseAuth get auth => _mockAuth;

  @override
  FirebaseFirestore get firestore => _fakeFirestore;

  @override
  Future<UserCredential?> signInAnonymously() async {
    return _mockAuth.signInAnonymously();
  }

  @override
  Future<void> createRoom(String roomId, Map<String, dynamic> data) async {}

  @override
  Future<int> getPlayerCount(String roomId) async => 0;

  @override
  Future<void> addPlayer(
    String roomId,
    Map<String, dynamic> playerData,
  ) async {}

  @override
  Future<void> removePlayer(
    String roomId,
    Map<String, dynamic> playerData,
  ) async {}
}
