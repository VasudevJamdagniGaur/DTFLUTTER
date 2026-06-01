import 'package:flutter/material.dart';

/// Circular Detea logo — mirrors landing/signup `DEITECIrc.webp` treatment.
class DeiteLogoAvatar extends StatelessWidget {
  const DeiteLogoAvatar({super.key, this.size = 96});

  final double size;

  static const _assetPath = 'assets/images/DEITECIrc.webp';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
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
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        _assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.favorite,
          size: size * 0.5,
          color: const Color(0xFFA855F7),
        ),
      ),
    );
  }
}
