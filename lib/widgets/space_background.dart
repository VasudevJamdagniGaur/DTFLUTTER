import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Deep space + star field + cyan/purple nebula — port of `SpaceBackground.js`.
class SpaceBackground extends StatefulWidget {
  const SpaceBackground({
    super.key,
    required this.child,
    this.nebulaCenterY = 0.38,
    this.starCount = 140,
  });

  /// Vertical center of nebula as fraction of height (e.g. 0.42 = 42%).
  final double nebulaCenterY;
  final int starCount;
  final Widget child;

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_StarData> _stars;

  @override
  void initState() {
    super.initState();
    _stars = _buildStarField(widget.starCount);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
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
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _SpaceBackgroundPainter(
                stars: _stars,
                timeSeconds: _controller.value * 8,
                nebulaCenterY: widget.nebulaCenterY,
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

List<_StarData> _buildStarField(int count) {
  return List.generate(count, (i) {
    final sizeBase = i % 5 == 0
        ? 2.5
        : i % 3 == 0
            ? 1.5
            : 1.0;
    return _StarData(
      leftFraction: (i * 17.3) % 100 / 100,
      topFraction: (i * 23.7 + 11) % 100 / 100,
      size: sizeBase + (i % 2) * 0.5,
      baseOpacity: 0.35 + (i % 7) * 0.08,
      delay: (i % 11) * 0.4,
      duration: 3 + (i % 5).toDouble(),
    );
  });
}

class _StarData {
  const _StarData({
    required this.leftFraction,
    required this.topFraction,
    required this.size,
    required this.baseOpacity,
    required this.delay,
    required this.duration,
  });

  final double leftFraction;
  final double topFraction;
  final double size;
  final double baseOpacity;
  final double delay;
  final double duration;
}

class _SpaceBackgroundPainter extends CustomPainter {
  _SpaceBackgroundPainter({
    required this.stars,
    required this.timeSeconds,
    required this.nebulaCenterY,
  });

  final List<_StarData> stars;
  final double timeSeconds;
  final double nebulaCenterY;

  static const _baseColors = [
    Color(0xFF0d1228),
    Color(0xFF06060f),
    Color(0xFF020205),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _paintBaseGradient(canvas, size);
    _paintNebula(canvas, size);
    _paintStars(canvas, size);
  }

  void _paintBaseGradient(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.3),
        radius: 1.2,
        colors: _baseColors,
        stops: [0.0, 0.45, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _paintNebula(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * nebulaCenterY);
    final outerSize = math.min(size.width * 0.92, 420.0);
    final innerSize = math.min(size.width * 0.70, 280.0);

    final outerRect = Rect.fromCircle(center: center, radius: outerSize / 2);
    canvas.drawCircle(
      center,
      outerSize / 2,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0x3838BDF8),
            Color(0x2E581C87),
            Color(0x1E1E0A3C),
            Color(0x00000000),
          ],
          stops: const [0.0, 0.28, 0.48, 0.72],
        ).createShader(outerRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    final innerRect = Rect.fromCircle(center: center, radius: innerSize / 2);
    canvas.drawCircle(
      center,
      innerSize / 2,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0x269333EA),
            Color(0x1406B6D4),
            Color(0x00000000),
          ],
          stops: const [0.0, 0.4, 0.7],
        ).createShader(innerRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );
  }

  void _paintStars(Canvas canvas, Size size) {
    for (final star in stars) {
      final phase = ((timeSeconds + star.delay) % star.duration) / star.duration;
      final t = phase <= 0.5
          ? Curves.easeInOut.transform(phase * 2)
          : Curves.easeInOut.transform((1 - phase) * 2);
      final opacityFactor = 0.25 + t * 0.75;
      final scale = 1 + t * 0.15;
      final opacity = (star.baseOpacity * opacityFactor).clamp(0.0, 1.0);
      final radius = star.size * scale / 2;

      final center = Offset(
        size.width * star.leftFraction,
        size.height * star.topFraction,
      );

      final glow = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size * 2);
      canvas.drawCircle(center, radius * 2, glow);

      final core = Paint()
        ..color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(center, radius, core);
    }
  }

  @override
  bool shouldRepaint(covariant _SpaceBackgroundPainter oldDelegate) {
    return oldDelegate.timeSeconds != timeSeconds ||
        oldDelegate.nebulaCenterY != nebulaCenterY;
  }
}
