import 'package:flutter/material.dart';

import '../../core/theme/hub_colors.dart';

class ShareSuggestionsScreen extends StatelessWidget {
  const ShareSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('Share Suggestions'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'AI-generated LinkedIn, X, and Reddit post suggestions '
          'from chatService (port generateShareSuggestions next).',
          style: TextStyle(color: HubColors.textSecondary, height: 1.5),
        ),
      ),
    );
  }
}
