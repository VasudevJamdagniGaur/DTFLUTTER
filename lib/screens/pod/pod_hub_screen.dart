import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';

/// Base layout for pod vertical screens (Sports, AI/Tech, etc.).
class PodHubScreen extends StatelessWidget {
  const PodHubScreen({
    super.key,
    required this.title,
    required this.topics,
    this.exploreSection,
  });

  final String title;
  final List<PodTopic> topics;
  final String? exploreSection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: topics.length,
        itemBuilder: (_, i) {
          final t = topics[i];
          return Card(
            color: HubColors.bgSecondary,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(t.label, style: const TextStyle(color: HubColors.text)),
              subtitle: t.subtitle != null
                  ? Text(t.subtitle!, style: const TextStyle(color: HubColors.textSecondary))
                  : null,
              trailing: const Icon(Icons.chevron_right, color: HubColors.textSecondary),
              onTap: () {
                if (t.sportsTopic) {
                  context.push('/pod/sports/topic/${t.id}');
                } else if (exploreSection != null) {
                  context.push('/pod/explore/$exploreSection/${t.id}');
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class PodTopic {
  const PodTopic({
    required this.id,
    required this.label,
    this.subtitle,
    this.sportsTopic = false,
  });
  final String id;
  final String label;
  final String? subtitle;
  final bool sportsTopic;
}
