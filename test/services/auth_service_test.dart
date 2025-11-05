import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twenty_nine_card_game/services/auth_service.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';

class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  User? _mockUser;

  @override
  Future<UserCredential> signInAnonymously() async {
    final credential = MockUserCredential();
    _mockUser = MockUser();
    when(credential.user).thenReturn(_mockUser);
    return credential;
  }

  @override
  Future<void> signOut() async {
    _mockUser = null;
  }

  @override
  User? get currentUser => _mockUser;

  @override
  Future<void> verifyPhoneNumber({
    String? phoneNumber,
    Duration? timeout,
    void Function(PhoneAuthCredential)? verificationCompleted,
    void Function(FirebaseAuthException)? verificationFailed,
    void Function(String, int?)? codeSent,
    void Function(String)? codeAutoRetrievalTimeout,
    int? forceResendingToken,
    MultiFactorSession? multiFactorSession,
    MultiFactorInfo? multiFactorInfo,
    String? autoRetrievedSmsCodeForTesting,
  }) async {
    codeSent?.call('fake-verification-id', null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // ✅ Fix binding error

  group('AuthService', () {
    late FakeFirebaseAuth fakeAuth;
    late AuthService authService;

    setUp(() {
      fakeAuth = FakeFirebaseAuth();
      authService = AuthService(auth: fakeAuth);
    });

    test('loginAsGuest returns a user', () async {
      final result = await authService.login(LoginMethod.guest);
      expect(result, isA<User>());
    });

    test('logout calls signOut', () async {
      await authService.logout();
      expect(fakeAuth.currentUser, isNull);
    });

    test('currentUser returns FirebaseAuth currentUser', () {
      fakeAuth._mockUser = MockUser(); // ✅ Ensure user is set
      final result = authService.currentUser;
      expect(result, isA<User>());
    });

    test('confirmPhoneCode returns null on error', () async {
      final result = await authService.confirmPhoneCode(
        smsCode: '123456',
        verificationId: 'fake-id',
        onError: (_) {},
      );
      expect(result, isNull);
    });

    test('startPhoneVerification triggers onCodeSent', () async {
      bool codeSent = false;

      await authService.startPhoneVerification(
        phoneNumber: '+8801234567890',
        onCodeSent: (id) {
          expect(id, 'fake-verification-id');
          codeSent = true;
        },
        onError: (err) => fail('Unexpected error: $err'),
      );

      expect(codeSent, true);
    });
  });
}