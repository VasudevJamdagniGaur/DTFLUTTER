import 'package:flutter/material.dart';

import 'pod_hub_screen.dart';

class PodAiTechScreen extends StatelessWidget {
  const PodAiTechScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PodHubScreen(
      title: 'AI & Tech',
      exploreSection: 'ai-tech',
      topics: [
        PodTopic(id: 'ai', label: 'Artificial Intelligence'),
        PodTopic(id: 'startups', label: 'Startups'),
        PodTopic(id: 'gadgets', label: 'Gadgets'),
      ],
    );
  }
}
