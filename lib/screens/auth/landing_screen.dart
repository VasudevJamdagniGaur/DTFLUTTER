import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';
import '../../widgets/space_background.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030308),
      body: SpaceBackground(
        nebulaCenterY: 0.42,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF121212),
                    border: Border.all(
                      color: const Color(0xFFA855F7).withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC084FC).withValues(alpha: 0.35),
                        blurRadius: 24,
                      ),
                      BoxShadow(
                        color: const Color(0xFF7E22CE).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 48,
                    color: HubColors.accent,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Detea',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: HubColors.text,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your Social Tea',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => context.push('/signup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA855F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(),
                    elevation: 8,
                    shadowColor: const Color(0xFF7E22CE).withValues(alpha: 0.5),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/login'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HubColors.text,
                    side: BorderSide(
                      color: HubColors.divider.withValues(alpha: 0.6),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('I already have an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
