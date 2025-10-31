import 'dart:async';
import 'package:twenty_nine_card_game/services/presence_service.dart';

/// Fake PresenceService that never touches Firebase.
class FakePresenceService implements PresenceService {
  final StreamController<List<Map<String, dynamic>>> _controller =
      StreamController.broadcast();
  final List<Map<String, dynamic>> _players = [];

  FakePresenceService() {
    // Emit an initial empty list so StreamBuilder has data immediately.
    _controller.add(List<Map<String, dynamic>>.from(_players));
  }

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

  void dispose() {
    _controller.close();
  }
}