import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreSync {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _roomsCollection = 'rooms';

  /// Updates the entire game state object in Firestore
  Future<void> updateGameState(String roomId, Map<String, dynamic> gameState) async {
    try {
      await _firestore.collection(_roomsCollection).doc(roomId).update({
        'gameState': gameState,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating game state: $e');
    }
  }

  /// Listens to game state changes in real-time
  Stream<Map<String, dynamic>> listenToGameState(String roomId) {
    return _firestore.collection(_roomsCollection).doc(roomId).snapshots().map(
      (snapshot) => snapshot.data()?['gameState'] ?? {},
    );
  }

  /// Records a card play by a player
  Future<void> playCard(String roomId, String playerId, String card) async {
    try {
      await _firestore.collection(_roomsCollection).doc(roomId).update({
        'playedCards.$playerId': card,
        'lastAction': {
          'type': 'playCard',
          'playerId': playerId,
          'card': card,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      debugPrint('Error playing card: $e');
    }
  }

  /// Reveals the trump suit for the round
  Future<void> revealTrump(String roomId, String trumpSuit) async {
    try {
      await _firestore.collection(_roomsCollection).doc(roomId).update({
        'trump': trumpSuit,
        'trumpRevealed': true,
        'lastAction': {
          'type': 'revealTrump',
          'suit': trumpSuit,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      debugPrint('Error revealing trump: $e');
    }
  }

  /// Updates current turn index
  Future<void> updateTurn(String roomId, int turnIndex) async {
    try {
      await _firestore.collection(_roomsCollection).doc(roomId).update({
        'currentTurn': turnIndex,
        'lastAction': {
          'type': 'updateTurn',
          'turnIndex': turnIndex,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      debugPrint('Error updating turn: $e');
    }
  }

  /// Clears played cards at the end of a trick
  Future<void> clearPlayedCards(String roomId) async {
    try {
      await _firestore.collection(_roomsCollection).doc(roomId).update({
        'playedCards': {},
        'lastAction': {
          'type': 'clearPlayedCards',
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      debugPrint('Error clearing played cards: $e');
    }
  }

  /// Starts a new round and resets round-specific state
  Future<void> startNewRound(String roomId, int roundNumber) async {
    try {
      await _firestore.collection(_roomsCollection).doc(roomId).update({
        'gameState.roundNumber': roundNumber,
        'gameState.trump': null,
        'gameState.trumpRevealed': false,
        'gameState.playedCards': {},
        'currentTurn': 0,
        'lastAction': {
          'type': 'startNewRound',
          'roundNumber': roundNumber,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      debugPrint('Error starting new round: $e');
    }
  }

  /// Updates team scores
  Future<void> updateScores(String roomId, Map<String, int> teamScores) async {
    try {
      await _firestore.collection(_roomsCollection).doc(roomId).update({
        'teamScores': teamScores,
        'lastAction': {
          'type': 'updateScores',
          'scores': teamScores,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      debugPrint('Error updating scores: $e');
    }
  }

  /// Ends the game and marks the room as finished
  Future<void> endGame(String roomId) async {
    try {
      await _firestore.collection(_roomsCollection).doc(roomId).update({
        'status': 'finished',
        'lastAction': {
          'type': 'endGame',
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      debugPrint('Error ending game: $e');
    }
  }
}