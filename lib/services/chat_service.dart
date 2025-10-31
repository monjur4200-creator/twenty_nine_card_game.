// lib/services/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore firestore;
  final String _roomsCollection = 'rooms';
  final String _usersCollection = 'users';

  ChatService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> sendRoomMessage({
    required String roomId,
    required String channel, // "global" | "team1" | "team2"
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    await firestore
        .collection(_roomsCollection)
        .doc(roomId)
        .collection('chats')
        .doc(channel)
        .collection('messages')
        .add({
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> listenToRoomMessages({
    required String roomId,
    required String channel,
  }) {
    return firestore
        .collection(_roomsCollection)
        .doc(roomId)
        .collection('chats')
        .doc(channel)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => d.data())
            .toList());
  }

  Future<void> sendFriendMessage({
    required String userId,
    required String friendId,
    required String senderName,
    required String text,
  }) async {
    final message = {
      'senderId': userId,
      'senderName': senderName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Write to both users for simple reads
    final base = firestore.collection(_usersCollection);
    await base.doc(userId).collection('friends').doc(friendId)
        .collection('messages').add(message);
    await base.doc(friendId).collection('friends').doc(userId)
        .collection('messages').add(message);
  }

  Stream<List<Map<String, dynamic>>> listenToFriendMessages({
    required String userId,
    required String friendId,
  }) {
    return firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection('friends')
        .doc(friendId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => d.data())
            .toList());
  }
}