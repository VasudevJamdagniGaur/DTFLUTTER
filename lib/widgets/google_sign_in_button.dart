import 'package:flutter/material.dart';

/// White pill Google button — port of `SignupPage.js`.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _GoogleGlyph(),
                    const SizedBox(width: 10),
                    Text(
                      loading ? 'Signing in…' : 'Continue with Google',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleGlyphPainter()),
    );
  }
}

class _GoogleGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    void arc(Color color, double start, double sweep) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        start,
        sweep,
        true,
        Paint()..color = color,
      );
    }

    arc(const Color(0xFF4285F4), -0.4, 1.6);
    arc(const Color(0xFF34A853), 1.2, 1.4);
    arc(const Color(0xFFFBBC05), 2.6, 1.2);
    arc(const Color(0xFFEA4335), 3.8, 1.4);
    canvas.drawCircle(c, r * 0.55, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
