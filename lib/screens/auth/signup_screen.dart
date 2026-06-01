import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/deite_logo_avatar.dart';
import '../../widgets/space_background.dart';

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
      backgroundColor: const Color(0xFF030308),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: HubColors.text,
      ),
      body: SpaceBackground(
        nebulaCenterY: 0.38,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Center(child: DeiteLogoAvatar(size: 125)),
                const SizedBox(height: 32),
                const Text(
                  'Create account',
                  textAlign: TextAlign.center,
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
                  decoration: InputDecoration(
                    hintText: 'Display name',
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.35),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: HubColors.text),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.35),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  style: const TextStyle(color: HubColors.text),
                  decoration: InputDecoration(
                    hintText: 'Password (6+ chars)',
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.35),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
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
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _google,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HubColors.text,
                    backgroundColor: Colors.white.withValues(alpha: 0.92),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const StadiumBorder(),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('Already have an account? Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
