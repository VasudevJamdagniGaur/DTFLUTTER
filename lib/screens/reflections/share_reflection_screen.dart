import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/hub_colors.dart';

class ShareReflectionScreen extends StatelessWidget {
  const ShareReflectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('Share Reflection'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Share your reflection to social platforms.',
              style: TextStyle(color: HubColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Share.share('My reflection from Deite'),
              child: const Text('Share via system sheet'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push('/share-suggestions'),
              child: const Text('Get AI post suggestions'),
            ),
          ],
        ),
      ),
    );
  }
}
