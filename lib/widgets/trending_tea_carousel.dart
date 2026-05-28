import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/hub_colors.dart';
import '../models/tea_item.dart';
import '../models/news_share_article.dart';
import '../services/reddit_service.dart';
/// Horizontal tea carousel — port of `TrendingTea.js` on Pod page.
class TrendingTeaCarousel extends StatefulWidget {
  const TrendingTeaCarousel({super.key, this.returnPath = '/pod'});

  final String returnPath;

  @override
  State<TrendingTeaCarousel> createState() => _TrendingTeaCarouselState();
}

class _TrendingTeaCarouselState extends State<TrendingTeaCarousel> {
  List<TeaItem> _items = [];
  bool _loading = true;
  String? _error;

  static const _gradients = [
    [Color(0xFF1a1a2e), Color(0xFF0f3460)],
    [Color(0xFF2d132c), Color(0xFFc72c41)],
    [Color(0xFF0f2027), Color(0xFF2c5364)],
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await redditService.fetchTrendingTea();
      if (mounted) {
        setState(() {
          _items = items;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _openFeed() {
    if (_items.isEmpty) return;
    context.push(
      '/tea-feed',
      extra: {'teaItems': _items, 'returnTo': widget.returnPath},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_fire_department, color: HubColors.accent, size: 22),
            const SizedBox(width: 8),
            const Text(
              'Trending Tea',
              style: TextStyle(
                color: HubColors.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (_items.isNotEmpty)
              TextButton(onPressed: _openFeed, child: const Text('See all')),
          ],
        ),
        const SizedBox(height: 12),
        if (_loading)
          const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: HubColors.accent),
            ),
          )
        else if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_items.isEmpty)
          const Text(
            'Could not load tea feed.',
            style: TextStyle(color: HubColors.textSecondary),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final item = _items[i];
                final hero = item.heroImageUrl;
                final grad = _gradients[i % _gradients.length];
                return GestureDetector(
                  onTap: _openFeed,
                  onLongPress: () {
                    context.push(
                      '/share-suggestions',
                      extra: {
                        'newsArticle': NewsShareArticle(
                          title: item.title,
                          url: item.url,
                          image: item.heroImageUrl,
                          source: item.source,
                        ).toMap(),
                        'platform': 'linkedin',
                      },
                    );
                  },
                  child: Container(
                    width: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: HubColors.divider),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hero != null)
                          CachedNetworkImage(
                            imageUrl: hero,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _gradient(grad),
                          )
                        else
                          _gradient(grad),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black87, Colors.transparent],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Text(
                            item.title,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _gradient(List<Color> colors) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: const Center(
        child: Text('☕', style: TextStyle(fontSize: 40)),
      ),
    );
  }
}
