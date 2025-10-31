/// Abstract contract for presence handling.
/// Widgets and business logic depend on this, not on Firebase directly.
abstract class PresenceService {
  Future<void> setPlayerPresence(String roomId, String playerId, String playerName);
  Future<void> removePlayer(String roomId, String playerId, String playerName);
  Stream<List<Map<String, dynamic>>> getRoomPlayersStream(String roomId);
}