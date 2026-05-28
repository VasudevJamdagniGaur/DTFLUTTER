import 'package:flutter/material.dart';

import 'pod_topic_feed_screen.dart';

class PodExploreTopicScreen extends StatelessWidget {
  const PodExploreTopicScreen({
    super.key,
    required this.section,
    required this.topicId,
  });

  final String section;
  final String topicId;

  @override
  Widget build(BuildContext context) {
    return PodTopicFeedScreen(
      title: '$section · $topicId',
      topicId: topicId,
    );
  }
}
