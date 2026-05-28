import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';

/// Mirrors `SplashScreen.js` — auth check then dashboard or landing.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  StreamSubscription<User?>? _sub;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() {
    final current = authService.currentUser;
    if (current != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/dashboard');
      });
      return;
    }

    var navigated = false;
    void go(User? user, {bool skipDelay = false}) {
      if (navigated || !mounted) return;
      navigated = true;
      Future<void> navigate() async {
        if (user != null) {
          context.go('/dashboard');
        } else {
          if (!skipDelay) await Future<void>.delayed(const Duration(seconds: 2));
          if (mounted) context.go('/landing');
        }
      }

      navigate();
    }

    _sub = authService.authStateChanges().listen((user) {
      if (!navigated) go(user);
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!navigated && mounted) go(null, skipDelay: true);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 1),
            radius: 1.2,
            colors: [Color(0xFF1B2735), Color(0xFF090A0F)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text(
                'Deite',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
