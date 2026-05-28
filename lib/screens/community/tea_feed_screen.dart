import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/hub_colors.dart';
import '../../models/news_share_article.dart';
import '../../models/tea_item.dart';
import '../../services/reddit_service.dart';
import '../../services/tea_watchlist_service.dart';
import '../../widgets/tea_comments_sheet.dart';

/// Fullscreen vertical Tea feed — port of `TeaFeedPage.js`.
class TeaFeedScreen extends StatefulWidget {
  const TeaFeedScreen({
    super.key,
    this.initialItems,
    this.returnTo = '/dashboard',
  });

  final List<TeaItem>? initialItems;
  final String returnTo;

  @override
  State<TeaFeedScreen> createState() => _TeaFeedScreenState();
}

class _TeaFeedScreenState extends State<TeaFeedScreen> {
  List<TeaItem> _items = [];
  bool _loading = true;
  Set<String> _watchlisted = {};
  String _tab = 'forYou';

  static const _gradients = [
    [Color(0xFF1a1a2e), Color(0xFF0f3460)],
    [Color(0xFF2d132c), Color(0xFFc72c41)],
    [Color(0xFF0f2027), Color(0xFF2c5364)],
    [Color(0xFF1e3c72), Color(0xFF7e8ba3)],
    [Color(0xFF232526), Color(0xFF414345)],
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.initialItems != null && widget.initialItems!.isNotEmpty) {
      _items = widget.initialItems!;
      _loading = false;
    } else {
      _items = await redditService.fetchTrendingTea(maxItems: 20);
      _loading = false;
    }
    await _loadWatchlist();
    if (mounted) setState(() {});
  }

  Future<void> _loadWatchlist() async {
    final list = await teaWatchlistService.getAll();
    _watchlisted = list.map((e) => '${e['id']}').toSet();
  }

  List<TeaItem> get _displayItems {
    if (_tab == 'trending') {
      final sorted = [..._items]..sort((a, b) => b.score.compareTo(a.score));
      return sorted;
    }
    return _items;
  }

  Future<void> _toggleWatchlist(TeaItem item) async {
    await teaWatchlistService.toggle(item.toWatchlistMap());
    await _loadWatchlist();
    setState(() {});
  }

  void _openComments(TeaItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TeaCommentsSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: HubColors.accent),
            )
          else if (_displayItems.isEmpty)
            const Center(
              child: Text(
                'No tea posts available.',
                style: TextStyle(color: HubColors.textSecondary),
              ),
            )
          else
            PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _displayItems.length,
              itemBuilder: (_, i) => _TeaCard(
                item: _displayItems[i],
                gradient: _gradients[i % _gradients.length],
                watchlisted: _watchlisted.contains(_displayItems[i].id),
                onWatchlist: () => _toggleWatchlist(_displayItems[i]),
                onComments: () => _openComments(_displayItems[i]),
                onOpen: () async {
                  final uri = Uri.tryParse(_displayItems[i].url);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go(widget.returnTo),
                  ),
                  const Spacer(),
                  SegmentedButton<String>(
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                    segments: const [
                      ButtonSegment(value: 'forYou', label: Text('For you')),
                      ButtonSegment(value: 'trending', label: Text('Top')),
                    ],
                    selected: {_tab},
                    onSelectionChanged: (s) => setState(() => _tab = s.first),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_outline, color: Colors.white),
                    onPressed: () => context.push('/watchlist'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeaCard extends StatelessWidget {
  const _TeaCard({
    required this.item,
    required this.gradient,
    required this.watchlisted,
    required this.onWatchlist,
    required this.onComments,
    required this.onOpen,
  });

  final TeaItem item;
  final List<Color> gradient;
  final bool watchlisted;
  final VoidCallback onWatchlist;
  final VoidCallback onComments;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final hero = item.heroImageUrl;
    return GestureDetector(
      onTap: onOpen,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hero != null)
            CachedNetworkImage(imageUrl: hero, fit: BoxFit.cover)
          else
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
              ),
              child: const Center(
                child: Text('☕', style: TextStyle(fontSize: 64)),
              ),
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 120,
            child: Column(
              children: [
                IconButton(
                  onPressed: onWatchlist,
                  icon: Icon(
                    watchlisted ? Icons.bookmark : Icons.bookmark_border,
                    color: watchlisted ? HubColors.accentHighlight : Colors.white,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: onComments,
                  icon: const Icon(Icons.chat_bubble_outline,
                      color: Colors.white, size: 28),
                ),
                Text(
                  '${item.numComments}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                IconButton(
                  onPressed: () {
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
                  icon: const Icon(Icons.share_outlined,
                      color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 72,
            bottom: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: HubColors.accent.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: HubColors.accent.withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'GOSSIP',
                    style: TextStyle(
                      color: HubColors.accentHighlight,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'u/${item.author} · ${item.score} upvotes',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
