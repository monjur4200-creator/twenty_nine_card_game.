import '../models/user.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

abstract class SessionRepository {
  Future<LoginResult> logIn();
  Future<User?> get user;
  Future<void> logOut();
}