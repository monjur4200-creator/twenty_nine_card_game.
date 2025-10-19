import 'package:firebase_database/firebase_database.dart';

class PresenceService {
  final FirebaseDatabase _db;

  /// In production, just call `PresenceService()`
  /// In tests, pass a fake or mock database:
  ///   `PresenceService(database: fakeDb)`
  PresenceService({FirebaseDatabase? database})
      : _db = database ?? FirebaseDatabase.instance;

  /// Mark a player as present in a room
  Future<void> setPlayerPresence(
      String roomId, String playerId, String playerName) async {
    await _db.ref('rooms/$roomId/players/$playerId').set({
      'id': playerId,
      'name': playerName,
      'joinedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Remove a player from a room
  Future<void> removePlayer(
      String roomId, String playerId, String playerName) async {
    await _db.ref('rooms/$roomId/players/$playerId').remove();
  }

  /// Stream of players in a room
  Stream<List<Map<String, dynamic>>> getRoomPlayersStream(String roomId) {
    return _db.ref('rooms/$roomId/players').onValue.map((event) {
      final players = <Map<String, dynamic>>[];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          players.add(Map<String, dynamic>.from(value));
        });
      }
      return players;
    });
  }
}