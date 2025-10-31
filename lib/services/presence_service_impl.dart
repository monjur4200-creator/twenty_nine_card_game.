import 'package:firebase_database/firebase_database.dart';
import 'presence_service.dart';

class FirebasePresenceService implements PresenceService {
  final FirebaseDatabase _db;

  FirebasePresenceService({FirebaseDatabase? database})
      : _db = database ?? FirebaseDatabase.instance;

  @override
  Future<void> setPlayerPresence(
    String roomId,
    String playerId,
    String playerName,
  ) async {
    await _db.ref('rooms/$roomId/players/$playerId').set({
      'id': playerId,
      'name': playerName,
      'joinedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> removePlayer(
    String roomId,
    String playerId,
    String playerName,
  ) async {
    await _db.ref('rooms/$roomId/players/$playerId').remove();
  }

  @override
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