import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/user.dart';
import 'session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final FacebookAuth _auth;

  SessionRepositoryImpl(this._auth);

  @override
  Future<LoginResult> logIn() {
    return _auth.login();
  }

  @override
  Future<User?> get user async {
    if (await _auth.accessToken != null) {
      final userData = await _auth.getUserData();

      if (userData.isNotEmpty) {
        return User(
          userId: userData['id'],
          name: userData['name'],
          email: userData['email'],
          profilePicture: userData['picture']?['data']?['url'],
        );
      }
    }
    return null;
  }

  @override
  Future<void> logOut() {
    return _auth.logOut();
  }
}