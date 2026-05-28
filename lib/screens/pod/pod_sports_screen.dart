import 'package:flutter/material.dart';

import 'pod_hub_screen.dart';

class PodSportsScreen extends StatelessWidget {
  const PodSportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PodHubScreen(
      title: 'Sports',
      topics: [
        PodTopic(id: 'cricket', label: 'Cricket', sportsTopic: true),
        PodTopic(id: 'football', label: 'Football', sportsTopic: true),
        PodTopic(id: 'basketball', label: 'Basketball', sportsTopic: true),
        PodTopic(id: 'tennis', label: 'Tennis', sportsTopic: true),
      ],
    );
  }
}
