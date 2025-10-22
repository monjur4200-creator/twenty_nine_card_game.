import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Handles syncing GameState with Firestore in real-time.
class FirestoreSync {
  final FirebaseFirestore _firestore;
  final String _roomsCollection = 'rooms';

  /// Default constructor uses the real Firestore instance.
  FirestoreSync() : _firestore = FirebaseFirestore.instance;

  /// Test constructor allows injecting a fake Firestore (for unit tests).
  FirestoreSync.test(this._firestore);

  /// Helper: reference to a specific room document.
  DocumentReference<Map<String, dynamic>> _roomDoc(String roomId) =>
      _firestore.collection(_roomsCollection).doc(roomId);

  /// Updates the entire game state object in Firestore.
  Future<void> updateGameState(
    String roomId,
    Map<String, dynamic> gameState,
  ) async {
    try {
      await _roomDoc(roomId).set({
        'gameState': gameState,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating game state: $e');
      if (kDebugMode) rethrow;
    }
  }

  /// Listens to game state changes in real-time.
  Stream<Map<String, dynamic>> listenToGameState(String roomId) {
    return _roomDoc(roomId).snapshots().map((snapshot) {
      final data = snapshot.data();
      return (data?['gameState'] as Map<String, dynamic>?) ?? {};
    });
  }

  /// Records a card play by a player.
  Future<void> playCard(String roomId, String playerId, String card) async {
    try {
      await _roomDoc(roomId).set({
        'gameState.playedCards.$playerId': card,
        'lastAction': {
          'type': 'playCard',
          'playerId': playerId,
          'card': card,
          'timestamp': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error playing card: $e');
      if (kDebugMode) rethrow;
    }
  }

  /// Reveals the trump suit for the round.
  Future<void> revealTrump(String roomId, String trumpSuit) async {
    try {
      await _roomDoc(roomId).set({
        'gameState.trump': trumpSuit,
        'gameState.trumpRevealed': true,
        'lastAction': {
          'type': 'revealTrump',
          'suit': trumpSuit,
          'timestamp': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error revealing trump: $e');
      if (kDebugMode) rethrow;
    }
  }

  /// Updates current turn index.
  Future<void> updateTurn(String roomId, int turnIndex) async {
    try {
      await _roomDoc(roomId).set({
        'gameState.currentTurn': turnIndex,
        'lastAction': {
          'type': 'updateTurn',
          'turnIndex': turnIndex,
          'timestamp': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating turn: $e');
      if (kDebugMode) rethrow;
    }
  }

  /// Clears played cards at the end of a trick.
  Future<void> clearPlayedCards(String roomId) async {
    try {
      await _roomDoc(roomId).set({
        'gameState.playedCards': {},
        'lastAction': {
          'type': 'clearPlayedCards',
          'timestamp': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error clearing played cards: $e');
      if (kDebugMode) rethrow;
    }
  }

  /// Starts a new round and resets round-specific state.
  Future<void> startNewRound(String roomId, int roundNumber) async {
    try {
      await _roomDoc(roomId).set({
        'gameState.roundNumber': roundNumber,
        'gameState.trump': null,
        'gameState.trumpRevealed': false,
        'gameState.playedCards': {},
        'gameState.currentTurn': 0,
        'lastAction': {
          'type': 'startNewRound',
          'roundNumber': roundNumber,
          'timestamp': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error starting new round: $e');
      if (kDebugMode) rethrow;
    }
  }

  /// Updates team scores (accepts int keys, converts to strings for Firestore).
  Future<void> updateScores(String roomId, Map<int, int> teamScores) async {
    try {
      final scoresAsStrings = teamScores.map(
        (k, v) => MapEntry(k.toString(), v),
      );
      await _roomDoc(roomId).set({
        'gameState.teamScores': scoresAsStrings,
        'lastAction': {
          'type': 'updateScores',
          'scores': scoresAsStrings,
          'timestamp': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating scores: $e');
      if (kDebugMode) rethrow;
    }
  }

  /// Ends the game and marks the room as finished.
  Future<void> endGame(String roomId) async {
    try {
      await _roomDoc(roomId).set({
        'status': 'finished',
        'lastAction': {
          'type': 'endGame',
          'timestamp': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error ending game: $e');
      if (kDebugMode) rethrow;
    }
  }

  /// Adds a player to the room.
  Future<void> joinGame(String roomId, Map<String, dynamic> playerData) async {
    try {
      await _roomDoc(roomId)
          .collection('players')
          .doc(playerData['id'].toString())
          .set(playerData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error joining game: $e');
      if (kDebugMode) rethrow;
    }
  }

  /// Removes a player from the room.
  Future<void> leaveGame(String roomId, String playerId) async {
    try {
      await _roomDoc(roomId).collection('players').doc(playerId).delete();
    } catch (e) {
      debugPrint('Error leaving game: $e');
      if (kDebugMode) rethrow;
    }
  }
}
