import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

import 'package:twenty_nine_card_game/services/presence_service.dart';
import 'package:twenty_nine_card_game/services/room_service.dart';

/// Fake PresenceService that emits immediately when players are added/removed
class FakePresenceService implements PresenceService {
  final _controller = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _players = <Map<String, dynamic>>[];

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
  Stream<List<Map<String, dynamic>>> getRoomPlayersStream(String roomId) =>
      _controller.stream;
}

/// Minimal Fake RoomService
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
  test('Fake services work', () async {
    final presence = FakePresenceService();
    final room = FakeRoomService();

    // Attach listener BEFORE emitting
    final future = expectLater(
      presence.getRoomPlayersStream('room1'),
      emits(predicate<List<Map<String, dynamic>>>(
        (players) =>
            players.any((p) => p['id'] == 'p1' && p['name'] == 'Alice'),
      )),
    );

    // Now trigger the emission
    await presence.setPlayerPresence('room1', 'p1', 'Alice');

    // Room service is independent of presence
    expect(await room.getPlayerCount('room1'), 0);

    // Await the expectation
    await future;
  });
}
