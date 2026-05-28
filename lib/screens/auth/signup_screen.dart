import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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

  Future<void> _google() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final result = await authService.signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.success && result.uid != null) {
      await firestoreService.ensureUser(
        result.uid!,
        email: result.email,
        displayName: result.displayName,
        profilePicture: result.photoURL,
      );
      if (!mounted) return;
      if (result.isNewUser) {
        context.go('/signup/profile-details');
      } else {
        context.go('/dashboard');
      }
    } else {
      setState(() => _error = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.appBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: HubColors.text,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create account',
              style: TextStyle(
                color: HubColors.text,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _name,
              style: const TextStyle(color: HubColors.text),
              decoration: const InputDecoration(hintText: 'Display name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: HubColors.text),
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              style: const TextStyle(color: HubColors.text),
              decoration: const InputDecoration(hintText: 'Password (6+ chars)'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _signUp,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign up'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loading ? null : _google,
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: const Text('Continue with Google'),
              style: OutlinedButton.styleFrom(
                foregroundColor: HubColors.text,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text('Already have an account? Log in'),
            ),
          ],
        ),
      ),
    );
  }
}
