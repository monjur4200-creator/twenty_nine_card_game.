import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/login_method.dart';

class LoginSelector extends StatelessWidget {
  final AuthService authService;
  final void Function(User user) onLogin;

  const LoginSelector({
    super.key,
    required this.authService,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Login Method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: [
            _buildLoginButton(context, 'Facebook', LoginMethod.facebook, key: const Key('facebookLoginButton')),
            _buildLoginButton(context, 'WhatsApp', LoginMethod.whatsapp, key: const Key('whatsappLoginButton')),
            _buildLoginButton(context, 'Gmail', LoginMethod.gmail, key: const Key('gmailLoginButton')),
            _buildLoginButton(context, 'Guest', LoginMethod.guest, key: const Key('login_Guest')), // ✅ Matches test
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, String label, LoginMethod method, {Key? key}) {
    return ElevatedButton(
      key: key,
      onPressed: () async {
        final user = await authService.login(method);
        if (!context.mounted) return;

        if (user != null) {
          onLogin(user);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Logged in as ${user.displayName ?? 'Guest'}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Login failed')),
          );
        }
      },
      child: Text(label),
    );
  }
}