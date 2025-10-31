import 'dart:async';
import 'package:twenty_nine_card_game/services/room_service.dart';

class FakeRoomService implements RoomService {
  final Map<String, Map<String, dynamic>> _rooms = {};
  final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();

  @override
  Future<void> createRoom(String roomId, Map<String, dynamic> data) async {
    _rooms[roomId] = {
      ...data,
      'status': 'waiting',
      'players': <Map<String, dynamic>>[],
    };
    _controller.add(Map<String, dynamic>.from(_rooms[roomId]!));
  }

  @override
  Future<void> joinRoom(String roomId, Map<String, dynamic> playerData) async {
    final players =
        List<Map<String, dynamic>>.from(_rooms[roomId]?['players'] ?? []);
    // prevent duplicates
    if (!players.any((p) => p['id'] == playerData['id'])) {
      players.add(playerData);
      _rooms[roomId]?['players'] = players;
      _controller.add(Map<String, dynamic>.from(_rooms[roomId]!));
    }
  }

  @override
  Future<void> leaveRoom(String roomId, Map<String, dynamic> playerData) async {
    final players =
        List<Map<String, dynamic>>.from(_rooms[roomId]?['players'] ?? []);
    players.removeWhere((p) => p['id'] == playerData['id']);
    _rooms[roomId]?['players'] = players;
    _controller.add(Map<String, dynamic>.from(_rooms[roomId]!));
  }

  @override
  Stream<Map<String, dynamic>> listenToRoom(String roomId) {
    // Always emit the current state first
    if (_rooms.containsKey(roomId)) {
      Future.microtask(() =>
          _controller.add(Map<String, dynamic>.from(_rooms[roomId]!)));
    }
    return _controller.stream;
  }

  @override
  Future<void> updateRoomStatus(String roomId, String status) async {
    if (_rooms.containsKey(roomId)) {
      _rooms[roomId]!['status'] = status;
      _controller.add(Map<String, dynamic>.from(_rooms[roomId]!));
    }
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    _rooms.remove(roomId);
  }

  @override
  Future<int> getPlayerCount(String roomId) async {
    final players =
        List<Map<String, dynamic>>.from(_rooms[roomId]?['players'] ?? []);
    return players.length;
  }

  @override
  Future<Map<String, dynamic>> getRoom(String roomId) async {
    return Map<String, dynamic>.from(_rooms[roomId] ?? {});
  }
}
