import 'package:flutter/material.dart';

import '../../core/theme/hub_colors.dart';

/// Topic feed (news/Reddit) — simplified port of topic pages.
class PodTopicFeedScreen extends StatelessWidget {
  const PodTopicFeedScreen({
    super.key,
    required this.title,
    required this.topicId,
  });

  final String title;
  final String topicId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Trending in $topicId',
            style: const TextStyle(
              color: HubColors.text,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'News and Reddit feeds connect via Firebase Cloud Functions '
            'and news APIs (see hubNewsService in the original app). '
            'Wire REACT_APP_NEWS_* keys server-side for live content.',
            style: TextStyle(color: HubColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),
          ...List.generate(
            5,
            (i) => Card(
              color: HubColors.bgSecondary,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  'Sample headline ${i + 1} — $topicId',
                  style: const TextStyle(color: HubColors.text),
                ),
                subtitle: const Text(
                  'Connect news API for live articles',
                  style: TextStyle(color: HubColors.textSecondary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
