import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';
import '../../models/news_item.dart';
import '../../services/hub_news_service.dart';
import '../../widgets/news_article_card.dart';
import '../../widgets/trending_tea_carousel.dart';

class PodScreen extends StatefulWidget {
  const PodScreen({super.key});

  @override
  State<PodScreen> createState() => _PodScreenState();
}

class _PodScreenState extends State<PodScreen> {
  List<NewsItem> _trending = [];
  bool _loadingNews = true;

  static const _hubs = [
    _Hub('Sports', Icons.sports_soccer, '/pod/sports'),
    _Hub('AI & Tech', Icons.memory, '/pod/ai-tech'),
    _Hub('Entrepreneurship', Icons.rocket_launch, '/pod/entrepreneurship'),
    _Hub('Current Affairs', Icons.newspaper, '/pod/current-affairs'),
  ];

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  Future<void> _loadTrending() async {
    final items = await hubNewsService.fetchForTopic('world', limit: 5);
    if (mounted) {
      setState(() {
        _trending = items;
        _loadingNews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('Crew'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => context.push('/pod/chat'),
          ),
          IconButton(
            icon: const Icon(Icons.auto_stories_outlined),
            onPressed: () => context.push('/pod/reflections'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTrending,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Trending',
              style: TextStyle(
                color: HubColors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_loadingNews)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(color: HubColors.accent),
                ),
              )
            else if (_trending.isEmpty)
              const Text(
                'Pull to refresh for news.',
                style: TextStyle(color: HubColors.textSecondary),
              )
            else
              ..._trending.take(3).map((n) => NewsArticleCard(item: n)),
            const SizedBox(height: 28),
            const TrendingTeaCarousel(returnPath: '/pod'),
            const SizedBox(height: 28),
            const Text(
              'Your Crew hubs',
              style: TextStyle(
                color: HubColors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explore topics with your crew.',
              style: TextStyle(color: HubColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ..._hubs.map(
              (h) => Card(
                color: HubColors.bgSecondary,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(h.icon, color: HubColors.accent, size: 32),
                  title: Text(
                    h.title,
                    style: const TextStyle(
                      color: HubColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right,
                      color: HubColors.textSecondary),
                  onTap: () => context.push(h.route),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hub {
  const _Hub(this.title, this.icon, this.route);
  final String title;
  final IconData icon;
  final String route;
}
