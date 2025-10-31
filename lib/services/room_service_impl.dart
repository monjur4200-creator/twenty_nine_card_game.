import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'room_service.dart';

class FirestoreRoomService implements RoomService {
  final FirebaseFirestore firestore;
  final String _roomsCollection = 'rooms';

  FirestoreRoomService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createRoom(String roomId, Map<String, dynamic> data) async {
    try {
      await firestore.collection(_roomsCollection).doc(roomId).set({
        ...data,
        'status': 'waiting',
        'players': [],
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      debugPrint('Error creating room: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> joinRoom(String roomId, Map<String, dynamic> playerData) async {
    try {
      final docRef = firestore.collection(_roomsCollection).doc(roomId);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        throw Exception("Room $roomId does not exist");
      }

      final data = snapshot.data() ?? {};
      final players = List<Map<String, dynamic>>.from(data['players'] ?? []);

      final alreadyJoined = players.any((p) => p['id'] == playerData['id']);
      if (!alreadyJoined) {
        await docRef.update({
          'players': FieldValue.arrayUnion([playerData]),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e, st) {
      debugPrint('Error joining room: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> leaveRoom(String roomId, Map<String, dynamic> playerData) async {
    try {
      await firestore.collection(_roomsCollection).doc(roomId).update({
        'players': FieldValue.arrayRemove([playerData]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      debugPrint('Error leaving room: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<Map<String, dynamic>> listenToRoom(String roomId) {
    return firestore
        .collection(_roomsCollection)
        .doc(roomId)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
  }

  @override
  Future<void> updateRoomStatus(String roomId, String status) async {
    try {
      await firestore.collection(_roomsCollection).doc(roomId).update({
        'status': status,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      debugPrint('Error updating room status: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    try {
      await firestore.collection(_roomsCollection).doc(roomId).delete();
    } catch (e, st) {
      debugPrint('Error deleting room: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<int> getPlayerCount(String roomId) async {
    try {
      final snapshot = await firestore.collection(_roomsCollection).doc(roomId).get();
      final data = snapshot.data();
      if (data == null || data['players'] == null) return 0;
      final players = List<Map<String, dynamic>>.from(data['players']);
      return players.length;
    } catch (e, st) {
      debugPrint('Error getting player count: $e');
      debugPrintStack(stackTrace: st);
      return 0;
    }
  }

  @override
  Future<Map<String, dynamic>> getRoom(String roomId) async {
    try {
      final snapshot = await firestore.collection(_roomsCollection).doc(roomId).get();
      return snapshot.data() ?? {};
    } catch (e, st) {
      debugPrint('Error fetching room: $e');
      debugPrintStack(stackTrace: st);
      return {};
    }
  }
}