import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _forgotEmail = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _showForgot = false;
  bool _forgotSent = false;

  @override
  void dispose() {
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
      setState(() {
        _error = result.code == 'invalid-credential' ||
                result.code == 'wrong-password'
            ? 'Invalid email or password.'
            : result.error;
      });
    }
  }

  Future<void> _forgot() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final result = await authService.sendPasswordReset(_forgotEmail.text.trim());
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _showForgot ? _buildForgot() : _buildLogin(),
      ),
    );
  }

  Widget _buildLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Welcome back',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Email',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _password,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Password',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loading ? null : _login,
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Log in'),
        ),
        TextButton(
          onPressed: () => setState(() => _showForgot = true),
          child: const Text('Forgot password?'),
        ),
        TextButton(
          onPressed: () => context.push('/signup'),
          child: const Text('Create account'),
        ),
      ],
    );
  }

  Widget _buildForgot() {
    if (_forgotSent) {
      return const Text(
        'Password reset email sent! Check your inbox.',
        style: TextStyle(color: HubColors.accent),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Reset password',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _forgotEmail,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Email'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loading ? null : _forgot,
          child: const Text('Send reset link'),
        ),
        TextButton(
          onPressed: () => setState(() => _showForgot = false),
          child: const Text('Back to login'),
        ),
      ],
    );
  }
}
