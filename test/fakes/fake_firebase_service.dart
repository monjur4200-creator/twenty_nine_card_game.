import 'package:twenty_nine_card_game/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart'; // ✅ Required for Fake

/// ✅ Firebase mock that avoids Firebase.initializeApp()
class FakeFirebaseService implements FirebaseService {
  @override
  final FirebaseAuth auth = _FakeAuth();

  @override
  final FirebaseFirestore firestore = _FakeFirestore();

  @override
  Future<void> addPlayer(String roomId, Map<String, dynamic> playerData) async {}

  @override
  Future<void> createRoom(String roomId, Map<String, dynamic> data) async {}

  @override
  Future<int> getPlayerCount(String roomId) async => 0;

  @override
  Future<void> removePlayer(String roomId, Map<String, dynamic> playerData) async {}

  Future<void> initialize() async {}

  @override
  Future<UserCredential?> signInAnonymously() async => null;

  Future<void> signOut() async {}

  String getCurrentUserId() => 'fake-user-id';

  Stream<String> getUserIdStream() async* {
    yield 'fake-user-id';
  }

  bool isSignedIn() => true;
}

/// ✅ Safe stub that satisfies FirebaseAuth type
class _FakeAuth extends Fake implements FirebaseAuth {}

/// ✅ Safe stub that satisfies FirebaseFirestore type
class _FakeFirestore extends Fake implements FirebaseFirestore {}