import 'package:flutter/material.dart';

import 'pod_hub_screen.dart';

class PodCurrentAffairsScreen extends StatelessWidget {
  const PodCurrentAffairsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PodHubScreen(
      title: 'Current Affairs',
      exploreSection: 'current-affairs',
      topics: [
        PodTopic(id: 'world', label: 'World News'),
        PodTopic(id: 'politics', label: 'Politics'),
        PodTopic(id: 'economy', label: 'Economy'),
      ],
    );
  }
}
