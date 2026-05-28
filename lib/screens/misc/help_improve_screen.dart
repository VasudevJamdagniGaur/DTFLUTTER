import 'package:flutter/material.dart';

import '../../core/theme/hub_colors.dart';

class HelpImproveScreen extends StatelessWidget {
  const HelpImproveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('Help Improve Deite'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Feedback form (HelpImproveDeitePage). '
          'Connect to Firestore or your feedback endpoint.',
          style: TextStyle(color: HubColors.textSecondary, height: 1.5),
        ),
      ),
    );
  }
}
