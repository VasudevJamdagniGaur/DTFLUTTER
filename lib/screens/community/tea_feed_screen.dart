import 'package:flutter/material.dart';

import '../../core/theme/hub_colors.dart';

class TeaFeedScreen extends StatelessWidget {
  const TeaFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('Tea Feed'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: const Center(
        child: Text(
          'Short-form Tea content feed (TeaFeedPage).',
          style: TextStyle(color: HubColors.textSecondary),
        ),
      ),
    );
  }
}
