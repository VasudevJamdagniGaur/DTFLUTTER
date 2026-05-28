import 'package:flutter/material.dart';

import 'pod_hub_screen.dart';

class PodEntrepreneurshipScreen extends StatelessWidget {
  const PodEntrepreneurshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PodHubScreen(
      title: 'Entrepreneurship',
      exploreSection: 'entrepreneurship',
      topics: [
        PodTopic(id: 'funding', label: 'Funding & VC'),
        PodTopic(id: 'saas', label: 'SaaS'),
        PodTopic(id: 'marketing', label: 'Marketing'),
      ],
    );
  }
}
