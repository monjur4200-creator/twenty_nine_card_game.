/// Abstract contract for room management.
/// Widgets and business logic depend on this, not on Firestore directly.
abstract class RoomService {
  Future<void> createRoom(String roomId, Map<String, dynamic> data);
  Future<void> joinRoom(String roomId, Map<String, dynamic> playerData);
  Future<void> leaveRoom(String roomId, Map<String, dynamic> playerData);
  Stream<Map<String, dynamic>> listenToRoom(String roomId);
  Future<void> updateRoomStatus(String roomId, String status);
  Future<void> deleteRoom(String roomId);
  Future<int> getPlayerCount(String roomId);
  Future<Map<String, dynamic>> getRoom(String roomId);
}