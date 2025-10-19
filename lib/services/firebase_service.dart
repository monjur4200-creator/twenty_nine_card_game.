import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  /// In production, just call `FirebaseService()`.
  /// In tests, pass fakes or mocks:
  ///   `FirebaseService(auth: fakeAuth, firestore: fakeFirestore)`
  FirebaseService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance;

  /// Sign in anonymously (useful for quick start or tests)
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await auth.signInAnonymously();
    } catch (e, st) {
      debugPrint('Error signing in anonymously: $e\n$st');
      return null;
    }
  }

  /// Create a new room document in Firestore
  Future<void> createRoom(String roomId, Map<String, dynamic> data) async {
    try {
      await firestore.collection('rooms').doc(roomId).set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      debugPrint('Error creating room: $e\n$st');
      rethrow;
    }
  }

  /// Get the number of players in a room
  Future<int> getPlayerCount(String roomId) async {
    try {
      final snapshot =
          await firestore.collection('rooms').doc(roomId).get();

      final data = snapshot.data();
      if (data == null || data['players'] == null) return 0;

      final players = List<Map<String, dynamic>>.from(data['players']);
      return players.length;
    } catch (e, st) {
      debugPrint('Error getting player count: $e\n$st');
      return 0;
    }
  }

  /// Add a player to a room
  Future<void> addPlayer(String roomId, Map<String, dynamic> playerData) async {
    try {
      await firestore.collection('rooms').doc(roomId).update({
        'players': FieldValue.arrayUnion([playerData]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      debugPrint('Error adding player: $e\n$st');
      rethrow;
    }
  }

  /// Remove a player from a room
  Future<void> removePlayer(String roomId, Map<String, dynamic> playerData) async {
    try {
      await firestore.collection('rooms').doc(roomId).update({
        'players': FieldValue.arrayRemove([playerData]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      debugPrint('Error removing player: $e\n$st');
      rethrow;
    }
  }
}