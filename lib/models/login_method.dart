import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum LoginMethod {
  guest,
  facebook,
  gmail,
  google,
  whatsapp,
  local,
}

/// ✅ Default instance for production use
final AuthService _defaultAuthService = AuthService(auth: FirebaseAuth.instance);

/// ✅ Flexible login function that allows injection for tests
Future<User?> login(LoginMethod method, {AuthService? authService}) async {
  final service = authService ?? _defaultAuthService;

  switch (method) {
    case LoginMethod.guest:
      return await service.loginAsGuest();
    case LoginMethod.facebook:
      return await service.loginWithFacebook();
    case LoginMethod.gmail:
    case LoginMethod.google:
      return await service.loginWithGoogle();
    case LoginMethod.whatsapp:
      debugPrint('⚠️ Use startPhoneVerification + confirmPhoneCode for WhatsApp login.');
      return null;
    case LoginMethod.local:
      debugPrint('⚠️ Local login not implemented.');
      return null;
  }
}