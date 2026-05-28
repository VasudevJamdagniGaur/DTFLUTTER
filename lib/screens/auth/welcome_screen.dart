import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.appBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: HubColors.text),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create your space',
              style: TextStyle(
                color: HubColors.text,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign up to start chatting with Detea and tracking your emotional journey.',
              style: TextStyle(color: HubColors.textSecondary),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.push('/signup'),
              child: const Text('Sign up with Email'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push('/login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: HubColors.text,
                side: const BorderSide(color: HubColors.divider),
              ),
              child: const Text('Log in instead'),
            ),
          ],
        ),
      ),
    );
  }
}
