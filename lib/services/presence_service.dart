/// Abstract contract for presence handling.
/// Widgets and business logic depend on this, not on Firebase directly.
abstract class PresenceService {
  /// Set the player's presence in a room
  Future<void> setPlayerPresence(String roomId, String playerId, String playerName);

  /// Remove the player's presence from a room
  Future<void> removePlayer(String roomId, String playerId, String playerName);

  /// Stream of current players in the room
  Stream<List<Map<String, dynamic>>> getRoomPlayersStream(String roomId);
}