import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  /// ✅ Inject all dependencies for testability
  AuthService({
    required FirebaseAuth auth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  })  : _auth = auth,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  /// Main entry point for login (except phone)
  Future<User?> login(LoginMethod method) async {
    switch (method) {
      case LoginMethod.guest:
        return await loginAsGuest();
      case LoginMethod.facebook:
        return await loginWithFacebook();
      case LoginMethod.gmail:
      case LoginMethod.google:
        return await loginWithGoogle();
      case LoginMethod.whatsapp:
        debugPrint('⚠️ Use startPhoneVerification + confirmPhoneCode for WhatsApp login.');
        return null;
      case LoginMethod.local:
        debugPrint('⚠️ Local login not implemented.');
        return null;
    }
  }

  /// Login with Facebook
  Future<User?> loginWithFacebook() async {
    try {
      final result = await _facebookAuth.login();
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken;
        if (accessToken == null) {
          debugPrint('❌ Facebook access token is null');
          return null;
        }
        final credential = FacebookAuthProvider.credential(accessToken.tokenString); // ✅ FIXED
        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      } else {
        debugPrint('❌ Facebook login failed: ${result.status}');
        return null;
      }
    } catch (e) {
      debugPrint('⚠️ Facebook login error: $e');
      return null;
    }
  }

  /// Login with Google (Gmail)
  Future<User?> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      debugPrint('⚠️ Google login error: $e');
      return null;
    }
  }

  /// Step 1: Start phone number verification (WhatsApp-style)
  Future<void> startPhoneVerification({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(User)? onAutoVerified,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final userCredential = await _auth.signInWithCredential(credential);
          final user = userCredential.user;
          if (user != null) {
            onAutoVerified?.call(user);
          } else {
            onError('⚠️ Auto-verification failed: user is null');
          }
        } catch (e) {
          onError('⚠️ Auto-verification failed: $e');
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  /// Step 2: Confirm SMS code manually
  Future<User?> confirmPhoneCode({
    required String smsCode,
    required String verificationId,
    required Function(String error) onError,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      onError('⚠️ Phone login error: $e');
      return null;
    }
  }

  /// Anonymous guest login
  Future<User?> loginAsGuest() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      debugPrint('⚠️ Guest login error: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> logout() async {
    try {
      await _auth.signOut();

      // Skip platform plugins in test mode
      final isTest = Platform.environment.containsKey('FLUTTER_TEST');
      if (!isTest && !kIsWeb) {
        await _googleSignIn.signOut();
        await _facebookAuth.logOut();
      }
    } catch (e) {
      debugPrint('⚠️ Logout error: $e');
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;
}