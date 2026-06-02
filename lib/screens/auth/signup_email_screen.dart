import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/deite_logo_avatar.dart';
import '../../widgets/space_background.dart';

/// Email/password registration (not in SignupPage.js; kept for full auth parity).
class SignupEmailScreen extends StatefulWidget {
  const SignupEmailScreen({super.key});

  @override
  State<SignupEmailScreen> createState() => _SignupEmailScreenState();
}

class _SignupEmailScreenState extends State<SignupEmailScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final result = await authService.signUpUser(
      email: _email.text.trim(),
      password: _password.text,
      displayName: _name.text.trim(),
    );
    if (!mounted) return;
    if (result.success && result.uid != null) {
      await firestoreService.ensureUser(
        result.uid!,
        email: result.email,
        displayName: result.displayName ?? _name.text.trim(),
      );
      if (!mounted) return;
      setState(() => _loading = false);
      context.go('/signup/profile-details');
    } else {
      setState(() {
        _loading = false;
        _error = result.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030308),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: HubColors.text,
      ),
      body: SpaceBackground(
        nebulaCenterY: 0.38,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: DeiteLogoAvatar(size: 96)),
                const SizedBox(height: 24),
                const Text(
                  'Create account with email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: HubColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _field(_name, 'Display name'),
                const SizedBox(height: 12),
                _field(_email, 'Email', keyboard: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _field(_password, 'Password (6+ chars)', obscure: true),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA855F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Sign up'),
                ),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String hint, {
    TextInputType? keyboard,
    bool obscure = false,
  }) {
    return TextField(
      controller: c,
      obscureText: obscure,
      keyboardType: keyboard,
      style: const TextStyle(color: HubColors.text),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.35),
      ),
    );
  }
}
