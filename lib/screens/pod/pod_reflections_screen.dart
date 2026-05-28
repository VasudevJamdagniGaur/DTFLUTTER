import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';

class PodReflectionsScreen extends StatelessWidget {
  const PodReflectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('Pod Reflections'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.push('/reflections'),
          child: const Text('View all day reflections'),
        ),
      ),
    );
  }
}
