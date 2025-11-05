import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/widgets/login_selector.dart';
import 'package:twenty_nine_card_game/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';

class DummyAuthService implements AuthService {
  Future<User?> signInAnonymously() async => null;

  @override
  Future<User?> confirmPhoneCode({
    Function(User)? onAutoVerified,
    required String smsCode,
    required String verificationId,
    required Function(String) onError,
  }) async => null;

  @override
  Future<User?> login(LoginMethod method) async => null;

  @override
  Future<User?> loginAsGuest() async => null;

  @override
  Future<User?> loginWithFacebook() async => null;

  @override
  Future<User?> loginWithGoogle() async => null;

  Future<User?> loginWithPhone(String phoneNumber) async => null;

  @override
  Future<void> logout() async {}

  Future<bool> isLoggedIn() async => true;

  String? getUserId() => 'dummy_user_id';
  String? getUserName() => 'DummyUser';
  String? getUserEmail() => 'dummy@example.com';

  @override
  Future<void> startPhoneVerification({
    Function(User)? onAutoVerified,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required String phoneNumber,
  }) async {}

  @override
  User? get currentUser => null;
}

void main() {
  testWidgets('LoginSelector golden test', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: RepaintBoundary(
            child: Scaffold(
              body: LoginSelector(
                authService: DummyAuthService(),
                onLogin: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(LoginSelector),
      matchesGoldenFile('goldens/login_selector.png'),
    );
  });
}