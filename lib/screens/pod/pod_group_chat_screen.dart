import 'package:flutter/material.dart';

import '../../core/theme/hub_colors.dart';

class PodGroupChatScreen extends StatelessWidget {
  const PodGroupChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('Crew Group Chat'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Crew group chat uses Firestore crewSpheres/messages. '
            'Port PodGroupChatPage real-time listeners next.',
            textAlign: TextAlign.center,
            style: TextStyle(color: HubColors.textSecondary, height: 1.5),
          ),
        ),
      ),
    );
  }
}
