import 'package:flutter/material.dart';

import '../../core/theme/hub_colors.dart';
import '../../models/news_item.dart';
import '../../services/hub_news_service.dart';
import '../../widgets/news_article_card.dart';

class PodTopicFeedScreen extends StatefulWidget {
  const PodTopicFeedScreen({
    super.key,
    required this.title,
    required this.topicId,
  });

  final String title;
  final String topicId;

  @override
  State<PodTopicFeedScreen> createState() => _PodTopicFeedScreenState();
}

class _PodTopicFeedScreenState extends State<PodTopicFeedScreen> {
  List<NewsItem> _items = [];
  bool _loading = true;
  String? _error;

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
      final items = await hubNewsService.fetchForTopic(widget.topicId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: HubColors.accent),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _items.isEmpty
                  ? const Center(
                      child: Text(
                        'No articles found. Check your connection.',
                        style: TextStyle(color: HubColors.textSecondary),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (_, i) => NewsArticleCard(item: _items[i]),
                      ),
                    ),
    );
  }
}
