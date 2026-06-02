import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Login starfield — simplified port of `LoginPage.js` twinkling stars.
class AuthStarfieldBackground extends StatefulWidget {
  const AuthStarfieldBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AuthStarfieldBackground> createState() => _AuthStarfieldBackgroundState();
}

class _AuthStarfieldBackgroundState extends State<AuthStarfieldBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(42);
    _stars = List.generate(80, (i) {
      return _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 2 + 1,
        phase: rng.nextDouble() * math.pi * 2,
        speed: rng.nextDouble() * 0.5 + 0.5,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, 1),
              radius: 1.2,
              colors: [Color(0xFF1B2735), Color(0xFF090A0F)],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _StarPainter(
                stars: _stars,
                t: _controller.value * math.pi * 2,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _Star {
  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.speed,
  });

  final double x;
  final double y;
  final double size;
  final double phase;
  final double speed;
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.stars, required this.t});

  final List<_Star> stars;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final opacity =
          0.3 + 0.7 * ((math.sin(t * s.speed + s.phase) + 1) / 2);
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.size);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.t != t;
}
