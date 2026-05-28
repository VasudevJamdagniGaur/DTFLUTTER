import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';

/// Pod / Crew hub — port of `PodPage.js`.
class PodScreen extends StatelessWidget {
  const PodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hubs = [
      _Hub('Sports', Icons.sports_soccer, '/pod/sports'),
      _Hub('AI & Tech', Icons.memory, '/pod/ai-tech'),
      _Hub('Entrepreneurship', Icons.rocket_launch, '/pod/entrepreneurship'),
      _Hub('Current Affairs', Icons.newspaper, '/pod/current-affairs'),
    ];

    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('Crew'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => context.push('/pod/chat'),
          ),
          IconButton(
            icon: const Icon(Icons.auto_stories_outlined),
            onPressed: () => context.push('/pod/reflections'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Your Crew hubs',
            style: TextStyle(
              color: HubColors.text,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore topics with your crew — sports, tech, business, and news.',
            style: TextStyle(color: HubColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ...hubs.map(
            (h) => Card(
              color: HubColors.bgSecondary,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(h.icon, color: HubColors.accent, size: 32),
                title: Text(
                  h.title,
                  style: const TextStyle(
                    color: HubColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: HubColors.textSecondary),
                onTap: () => context.push(h.route),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hub {
  const _Hub(this.title, this.icon, this.route);
  final String title;
  final IconData icon;
  final String route;
}
