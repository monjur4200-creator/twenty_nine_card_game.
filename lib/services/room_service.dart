import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RoomService {
  final FirebaseFirestore firestore;
  final String _roomsCollection = 'rooms';

  /// In production you can just call `RoomService()`.
  /// In tests you can pass a fake:
  ///   `RoomService(firestore: FakeFirebaseFirestore())`
  RoomService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Creates a new room with initial metadata
  Future<void> createRoom(String roomId, Map<String, dynamic> data) async {
    try {
      await firestore.collection(_roomsCollection).doc(roomId).set({
        ...data,
        'status': 'waiting', // default status
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      debugPrint('Error creating room: $e\n$st');
      rethrow; // let tests catch this if needed
    }
  }

  /// Joins an existing room by updating its players list
  Future<void> joinRoom(String roomId, Map<String, dynamic> playerData) async {
    try {
      await firestore.collection(_roomsCollection).doc(roomId).update({
        'players': FieldValue.arrayUnion([playerData]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      debugPrint('Error joining room: $e\n$st');
      rethrow;
    }
  }

  /// Listens to room changes in real-time
  Stream<Map<String, dynamic>> listenToRoom(String roomId) {
    return firestore
        .collection(_roomsCollection)
        .doc(roomId)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
  }

  /// Updates the room status (e.g., waiting → active → finished)
  Future<void> updateRoomStatus(String roomId, String status) async {
    try {
      await firestore.collection(_roomsCollection).doc(roomId).update({
        'status': status,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      debugPrint('Error updating room status: $e\n$st');
      rethrow;
    }
  }

  /// Deletes a room (e.g., after game ends)
  Future<void> deleteRoom(String roomId) async {
    try {
      await firestore.collection(_roomsCollection).doc(roomId).delete();
    } catch (e, st) {
      debugPrint('Error deleting room: $e\n$st');
      rethrow;
    }
  }

  /// Returns the number of players currently in a room
  Future<int> getPlayerCount(String roomId) async {
    try {
      final snapshot = await firestore
          .collection(_roomsCollection)
          .doc(roomId)
          .get();

      final data = snapshot.data();
      if (data == null || data['players'] == null) return 0;

      final players = List<Map<String, dynamic>>.from(data['players']);
      return players.length;
    } catch (e, st) {
      debugPrint('Error getting player count: $e\n$st');
      return 0;
    }
  }
}