import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';

/// Pod-scoped reflections list — route wired for parity with web app.
class AllReflectionsScreen extends StatelessWidget {
  const AllReflectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('Crew Reflections'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.push('/reflections'),
          child: const Text('Open day reflections'),
        ),
      ),
    );
  }
}
