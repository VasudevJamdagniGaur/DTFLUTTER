import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/deite_logo_avatar.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../widgets/space_background.dart';

/// Sign up — port of `SignupPage.js` (Google + link to email login).
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _loaded = false;
  bool _googleLoading = false;

  @override
  void initState() {
    super.initState();
    // Mirrors web: if user becomes authenticated, go to dashboard.
    authService.authStateChanges().listen((user) {
      if (user != null && mounted) context.go('/dashboard');
    });
    Future<void>.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _loaded = true);
    });
  }

  Future<void> _google() async {
    if (_googleLoading) return;
    setState(() => _googleLoading = true);
    final result = await authService.signInWithGoogle();
    if (!mounted) return;
    setState(() => _googleLoading = false);
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
    } else if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030308),
      body: AnimatedOpacity(
        opacity: _loaded ? 1 : 0,
        duration: const Duration(milliseconds: 700),
        child: SpaceBackground(
          nebulaCenterY: 0.38,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedScale(
                      scale: _loaded ? 1 : 0.9,
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOut,
                      child: AnimatedOpacity(
                        opacity: _loaded ? 1 : 0,
                        duration: const Duration(milliseconds: 1000),
                        child: const DeiteLogoAvatar(size: 124),
                      ),
                    ),
                  ),
                ),
                AnimatedSlide(
                  offset: _loaded ? Offset.zero : const Offset(0, 0.08),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 350),
                            child: GoogleSignInButton(
                              loading: _googleLoading,
                              onPressed: _google,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Colors.white.withValues(alpha: 0.95),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text('Log in with email and password'),
                          ),
                          SizedBox(height: MediaQuery.paddingOf(context).bottom),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
