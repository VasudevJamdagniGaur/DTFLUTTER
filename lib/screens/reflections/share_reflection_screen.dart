import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/hub_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class ShareReflectionScreen extends StatefulWidget {
  const ShareReflectionScreen({super.key});

  @override
  State<ShareReflectionScreen> createState() => _ShareReflectionScreenState();
}

class _ShareReflectionScreenState extends State<ShareReflectionScreen> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _share(String platform) async {
    final content = _text.text.trim();
    if (content.isEmpty) return;
    final user = authService.currentUser;
    if (user != null) {
      await firestoreService.saveSocialShare(
        user.uid,
        platform: platform,
        reflectionDate: DeiteDateUtils.getDateId(),
        reflectionSnippet: content,
      );
    }
    await Share.share(content);
  }

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
              'Paste your reflection, then share or get AI suggestions.',
              style: TextStyle(color: HubColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _text,
              maxLines: 6,
              style: const TextStyle(color: HubColors.text),
              decoration: const InputDecoration(hintText: 'Your reflection...'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _share('native'),
              child: const Text('Share via system sheet'),
            ),
            const SizedBox(height: 10),
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
