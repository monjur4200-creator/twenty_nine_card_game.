import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

import 'package:twenty_nine_card_game/services/presence_service.dart';

/// Minimal fake for testing PresenceService behavior
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

void main() {
  group('PresenceService Tests', () {
    late TestableFakePresenceService presenceService;

    setUp(() {
      presenceService = TestableFakePresenceService();
    });

    test('setPlayerPresence adds a player to the stream', () async {
      final stream = presenceService.getRoomPlayersStream('room1');
      final events = <List<Map<String, dynamic>>>[];

      final sub = stream.listen(events.add);

      await presenceService.setPlayerPresence('room1', 'p1', 'Mongur');
      await Future.delayed(const Duration(milliseconds: 10));

      expect(events.isNotEmpty, true);
      expect(events.last.any((p) => p['name'] == 'Mongur'), true);

      await sub.cancel();
    });

    test('removePlayer removes a player from the stream', () async {
      final stream = presenceService.getRoomPlayersStream('room1');
      final events = <List<Map<String, dynamic>>>[];

      final sub = stream.listen(events.add);

      await presenceService.setPlayerPresence('room1', 'p1', 'Mongur');
      await presenceService.setPlayerPresence('room1', 'p2', 'Ada');
      await Future.delayed(const Duration(milliseconds: 10));

      await presenceService.removePlayer('room1', 'p1', 'Mongur');
      await Future.delayed(const Duration(milliseconds: 10));

      final lastEvent = events.last;
      expect(lastEvent.any((p) => p['name'] == 'Mongur'), false);
      expect(lastEvent.any((p) => p['name'] == 'Ada'), true);

      await sub.cancel();
    });
  });
}
