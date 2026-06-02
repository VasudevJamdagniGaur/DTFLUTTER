import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/assets/app_assets.dart';
import '../providers/theme_provider.dart';

/// Bottom nav — port of `BottomNavigation.js`.
class DeiteBottomNavigation extends StatelessWidget {
  const DeiteBottomNavigation({super.key, required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bg = isDark ? const Color(0xFF262626) : Colors.white;

    return Material(
      color: isDark ? Colors.black : Colors.white,
      child: SafeArea(
        top: false,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              _HomeNav(
                active: currentPath == '/dashboard',
                isDark: isDark,
                onTap: () => context.go('/dashboard'),
              ),
              _HeartNav(
                active: currentPath == '/wellbeing',
                isDark: isDark,
                onTap: () => context.go('/wellbeing'),
              ),
              _ImageNav(
                asset: AppAssets.crewIcon,
                size: 64,
                active: currentPath == '/pod',
                isDark: isDark,
                onTap: () => context.go('/pod'),
              ),
              _ImageNav(
                asset: AppAssets.communityIcon,
                size: 48,
                active: currentPath == '/community',
                isDark: isDark,
                onTap: () => context.go('/community'),
                inCircle: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeNav extends StatelessWidget {
  const _HomeNav({
    required this.active,
    required this.isDark,
    required this.onTap,
  });

  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stroke = active
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280));
    final opacity = active ? 1.0 : 0.4;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: opacity,
          child: CustomPaint(
            size: const Size(28, 28),
            painter: _HomeIconPainter(color: stroke, filled: active),
          ),
        ),
      ),
    );
  }
}

class _HomeIconPainter extends CustomPainter {
  _HomeIconPainter({required this.color, required this.filled});

  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = filled ? 2.5 : 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.15)
      ..lineTo(size.width * 0.88, size.height * 0.5)
      ..lineTo(size.width * 0.88, size.height * 0.85)
      ..lineTo(size.width * 0.12, size.height * 0.85)
      ..close();
    canvas.drawPath(path, paint);
    if (filled) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * 0.38,
          size.height * 0.55,
          size.width * 0.24,
          size.height * 0.3,
        ),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HomeIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.filled != filled;
}

class _HeartNav extends StatelessWidget {
  const _HeartNav({
    required this.active,
    required this.isDark,
    required this.onTap,
  });

  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280));

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Icon(
          active ? Icons.favorite : Icons.favorite_border,
          color: color.withValues(alpha: active ? 1 : 0.4),
          size: 28,
        ),
      ),
    );
  }
}

class _ImageNav extends StatelessWidget {
  const _ImageNav({
    required this.asset,
    required this.size,
    required this.active,
    required this.isDark,
    required this.onTap,
    this.inCircle = false,
  });

  final String asset;
  final double size;
  final bool active;
  final bool isDark;
  final VoidCallback onTap;
  final bool inCircle;

  @override
  Widget build(BuildContext context) {
    final opacity = active ? 1.0 : 0.4;
    Widget img = Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: active ? (isDark ? Colors.white : Colors.black) : null,
      colorBlendMode: active ? BlendMode.srcIn : null,
      errorBuilder: (_, __, ___) => Icon(
        Icons.groups,
        size: size * 0.5,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );

    if (inCircle) {
      img = SizedBox(
        width: 56,
        height: 56,
        child: Center(
          child: AnimatedScale(
            scale: active ? 1.08 : 1,
            duration: const Duration(milliseconds: 200),
            child: img,
          ),
        ),
      );
    }

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Opacity(opacity: opacity, child: Center(child: img)),
      ),
    );
  }
}

bool showBottomNav(String path) {
  return path == '/dashboard' ||
      path == '/pod' ||
      path == '/community' ||
      path == '/wellbeing';
}
