import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// X/Twitter-style share preview — port of `TweetShareCard.js`.
class TweetShareCard extends StatelessWidget {
  const TweetShareCard({
    super.key,
    required this.text,
    this.displayName = 'Detea User',
    this.username = 'detea_user',
    this.profileImageUrl,
    this.heroImageUrl,
    this.width = 340,
  });

  final String text;
  final String displayName;
  final String username;
  final String? profileImageUrl;
  final String? heroImageUrl;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : null,
                child: profileImageUrl == null
                    ? Text(displayName.substring(0, 1).toUpperCase())
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F1419),
                      ),
                    ),
                    Text(
                      '@$username',
                      style: const TextStyle(
                        color: Color(0xFF536471),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: Color(0xFF536471)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF0F1419),
              fontSize: 15,
              height: 1.35,
            ),
          ),
          if (heroImageUrl != null && heroImageUrl!.startsWith('http')) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: heroImageUrl!,
                width: width - 32,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
