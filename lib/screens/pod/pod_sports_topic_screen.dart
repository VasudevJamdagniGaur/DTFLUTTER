import 'package:flutter/material.dart';

import 'pod_topic_feed_screen.dart';

class PodSportsTopicScreen extends StatelessWidget {
  const PodSportsTopicScreen({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context) {
    return PodTopicFeedScreen(
      title: topicId[0].toUpperCase() + topicId.substring(1),
      topicId: topicId,
    );
  }
}
