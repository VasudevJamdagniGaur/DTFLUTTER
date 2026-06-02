import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../widgets/deite_logo_avatar.dart';

/// Splash — port of `SplashScreen.js`.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  StreamSubscription<User?>? _sub;
  Timer? _fallback;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  void _bootstrap() {
    var navigated = false;
    var authDetermined = false;

    void navigate(User? user, {required bool skipDelay}) {
      if (navigated || !mounted) return;
      navigated = true;
      _sub?.cancel();
      _fallback?.cancel();

      Future<void> go() async {
        if (!skipDelay && user == null) {
          await Future<void>.delayed(const Duration(seconds: 2));
        }
        if (!mounted) return;
        if (user != null) {
          context.go('/dashboard');
        } else {
          context.go('/landing');
        }
      }

      go();
    }

    final current = authService.currentUser;
    if (current != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigate(current, skipDelay: true);
      });
      return;
    }

    _sub = authService.authStateChanges().listen((user) {
      if (authDetermined) return;
      authDetermined = true;
      navigate(user, skipDelay: user == null);
    });

    _fallback = Timer(const Duration(milliseconds: 2500), () {
      if (!authDetermined && !navigated && mounted) {
        authDetermined = true;
        navigate(authService.currentUser, skipDelay: true);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _fallback?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          ..._decorHearts(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DeiteLogoAvatar(size: 96),
                const SizedBox(height: 32),
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E22CE).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA855F7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _decorHearts() {
    const spots = [
      (0.15, 0.22, Color(0xFF81C995), 16.0),
      (0.82, 0.28, Color(0xFFFDD663), 12.0),
      (0.12, 0.72, Color(0xFF8AB4F8), 20.0),
      (0.88, 0.65, Color(0xFF81C995), 14.0),
    ];
    return spots.map((s) {
      return Positioned(
        left: MediaQuery.sizeOf(context).width * s.$1,
        top: MediaQuery.sizeOf(context).height * s.$2,
        child: Icon(Icons.favorite, size: s.$4, color: s.$3.withValues(alpha: 0.2)),
      );
    }).toList();
  }
}
