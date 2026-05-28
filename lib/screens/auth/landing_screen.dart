import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.favorite, size: 72, color: HubColors.accent),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Deite',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HubColors.text,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your emotional wellness companion — reflect, connect, and grow.',
                textAlign: TextAlign.center,
                style: TextStyle(color: HubColors.textSecondary, fontSize: 16),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push('/welcome'),
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: HubColors.text,
                  side: const BorderSide(color: HubColors.divider),
                ),
                child: const Text('I already have an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
