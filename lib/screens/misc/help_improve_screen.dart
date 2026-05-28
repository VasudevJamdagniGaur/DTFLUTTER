import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/hub_colors.dart';

/// Feedback via WhatsApp — port of `HelpImproveDeitePage.js`.
class HelpImproveScreen extends StatefulWidget {
  const HelpImproveScreen({super.key});

  @override
  State<HelpImproveScreen> createState() => _HelpImproveScreenState();
}

class _HelpImproveScreenState extends State<HelpImproveScreen> {
  static const _whatsapp = '919536138120';
  String _objective = 'feature';
  final _message = TextEditingController();

  @override
  void initState() {
    super.initState();
    _message.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _message.text.trim();
    if (text.isEmpty) return;
    final label = _objective == 'feature' ? 'Request Feature' : 'Report a Bug';
    final body = 'Objective: $label\n\nMessage:\n$text';
    final uri = Uri.parse(
      'https://wa.me/$_whatsapp?text=${Uri.encodeComponent(body)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bgSecondary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Help improve Deite ✨'),
        backgroundColor: HubColors.bgSecondary,
        foregroundColor: HubColors.text,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'What are you sending?',
              style: TextStyle(color: HubColors.text, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'feature', label: Text('Request feature')),
                ButtonSegment(value: 'bug', label: Text('Report a bug')),
              ],
              selected: {_objective},
              onSelectionChanged: (s) => setState(() => _objective = s.first),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _message,
              maxLines: 6,
              style: const TextStyle(color: HubColors.text),
              decoration: const InputDecoration(
                hintText: 'Describe your idea or the issue...',
                alignLabelWithHint: true,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _message.text.trim().isEmpty ? null : _send,
              icon: const Icon(Icons.chat),
              label: const Text('Send via WhatsApp'),
            ),
          ],
        ),
      ),
    );
  }
}
