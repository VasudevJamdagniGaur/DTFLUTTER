import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../widgets/deite_logo_avatar.dart';
import '../../widgets/space_background.dart';

/// Landing — port of `LandingPage.js` (auth redirect + Get Started → signup).
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _authSub = authService.authStateChanges().listen((user) {
      if (user != null && mounted) {
        context.go('/dashboard');
      }
    });
  }

  void _checkAuth() {
    if (authService.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/dashboard');
      });
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  void _getStarted() {
    context.go('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030308),
      body: SpaceBackground(
        nebulaCenterY: 0.42,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const DeiteLogoAvatar(size: 96),
                  const SizedBox(height: 32),
                  const Text(
                    'Detea',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Social Tea',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFD1D5DB),
                      fontSize: 18,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Material(
                    color: const Color(0xFFA855F7),
                    elevation: 8,
                    shadowColor: const Color(0xFF7E22CE).withValues(alpha: 0.5),
                    shape: const StadiumBorder(
                      side: BorderSide(
                        color: Color(0x80A855F7),
                      ),
                    ),
                    child: InkWell(
                      onTap: _getStarted,
                      customBorder: const StadiumBorder(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC084FC)
                                  .withValues(alpha: 0.3),
                              blurRadius: 20,
                            ),
                            BoxShadow(
                              color: const Color(0xFF7E22CE)
                                  .withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
