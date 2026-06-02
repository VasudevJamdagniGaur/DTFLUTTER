import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../widgets/auth_starfield_background.dart';
import '../../widgets/deite_logo_avatar.dart';

/// Login — port of `LoginPage.js` (email/password + forgot password).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _forgotEmail = TextEditingController();
  bool _loaded = false;
  bool _loading = false;
  String? _error;
  bool _showForgot = false;
  bool _forgotSent = false;
  StreamSubscription<User?>? _authSub;

  static const _inputFill = Color(0x0FFFFFFF);
  static const _accentBlue = Color(0xFF8AB4F8);

  @override
  void initState() {
    super.initState();
    _authSub = authService.authStateChanges().listen((user) {
      if (user != null && mounted) context.go('/dashboard');
    });
    Future<void>.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _email.dispose();
    _password.dispose();
    _forgotEmail.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final result = await authService.signInUser(
      email: _email.text.trim(),
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.success) {
      context.go('/dashboard');
    } else {
      if (result.underlyingError != null) {
        debugPrint('Login failed underlying: ${result.underlyingError}');
      }
      setState(() {
        final base = result.code == 'invalid-credential' ||
                result.code == 'wrong-password'
            ? 'Invalid email or password. Please try again.'
            : result.error;
        _error = kDebugMode && result.underlyingError != null
            ? '$base\n[debug] ${result.underlyingError}'
            : base;
      });
    }
  }

  Future<void> _forgot() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final result =
        await authService.sendPasswordReset(_forgotEmail.text.trim());
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        _forgotSent = true;
      } else {
        _error = result.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A0F),
      body: AuthStarfieldBackground(
        child: AnimatedOpacity(
          opacity: _loaded ? 1 : 0,
          duration: const Duration(milliseconds: 1000),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      const DeiteLogoAvatar(size: 72),
                      const SizedBox(height: 32),
                      const Text(
                        'Log in',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Use your email and password',
                        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      if (_showForgot) _buildForgot() else _buildLogin(),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => context.go('/signup'),
                        child: const Text(
                          'Back to sign up',
                          style: TextStyle(color: _accentBlue, fontSize: 14),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/signup/email'),
                        child: const Text(
                          'Create account with email',
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogin() {
    return Column(
      children: [
        _input(_email, 'Email', keyboard: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _input(_password, 'Password', obscure: true),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Color(0xFFF87171), fontSize: 14)),
        ],
        const SizedBox(height: 16),
        _primaryButton(
          label: _loading ? 'Signing in…' : 'Log in',
          onPressed: _loading ? null : _login,
        ),
        TextButton(
          onPressed: () => setState(() {
            _showForgot = true;
            _error = null;
          }),
          child: const Text(
            'Forgot password?',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildForgot() {
    if (_forgotSent) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _inputFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text(
              'Check your email for a link to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            TextButton(
              onPressed: () => setState(() {
                _showForgot = false;
                _forgotSent = false;
                _forgotEmail.clear();
              }),
              child: const Text('Back to log in', style: TextStyle(color: _accentBlue)),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        _input(_forgotEmail, 'Email', keyboard: TextInputType.emailAddress),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Color(0xFFF87171), fontSize: 14)),
        ],
        const SizedBox(height: 16),
        _primaryButton(
          label: _loading ? 'Sending…' : 'Send reset link',
          onPressed: _loading ? null : _forgot,
        ),
        TextButton(
          onPressed: () => setState(() {
            _showForgot = false;
            _error = null;
          }),
          child: const Text(
            'Back to log in',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _input(
    TextEditingController c,
    String hint, {
    TextInputType? keyboard,
    bool obscure = false,
  }) {
    return TextField(
      controller: c,
      obscureText: obscure,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
        filled: true,
        fillColor: _inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accentBlue),
        ),
      ),
    );
  }

  Widget _primaryButton({required String label, VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }
}
