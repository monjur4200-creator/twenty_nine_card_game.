import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twenty_nine_card_game/widgets/login_selector.dart';
import 'package:twenty_nine_card_game/services/auth_service.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';

class MockUser extends Mock implements User {}

class MockAuthService extends Mock implements AuthService {
  @override
  Future<User?> login(LoginMethod method) async {
    return Future.value(MockUser());
  }
}

void main() {
  testWidgets('LoginSelector triggers login and callback', (tester) async {
    final mockAuth = MockAuthService();
    User? captured;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold( // ✅ Needed for SnackBar
        body: LoginSelector(
          authService: mockAuth,
          onLogin: (user) => captured = user,
        ),
      ),
    ));

    await tester.tap(find.byKey(const Key('login_Guest')));
    await tester.pumpAndSettle();

    expect(captured, isA<User>());
  });
}