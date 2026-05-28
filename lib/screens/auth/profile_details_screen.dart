import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final _city = TextEditingController();
  final _country = TextEditingController();
  final _interests = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _city.dispose();
    _country.dispose();
    _interests.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = authService.currentUser;
    if (user == null) return;
    setState(() => _loading = true);
    final interests = _interests.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    await firestoreService.ensureUser(
      user.uid,
      displayName: user.displayName,
      email: user.email,
      city: _city.text.trim().isEmpty ? null : _city.text.trim(),
      country: _country.text.trim().isEmpty ? null : _country.text.trim(),
      interests: interests.isEmpty ? null : interests,
    );
    // Store hub fields via direct merge in ensureUser extension
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.appBg,
      appBar: AppBar(
        title: const Text('Your profile'),
        backgroundColor: Colors.transparent,
        foregroundColor: HubColors.text,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tell us a bit about you (optional)',
              style: TextStyle(color: HubColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _city,
              style: const TextStyle(color: HubColors.text),
              decoration: const InputDecoration(hintText: 'City'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _country,
              style: const TextStyle(color: HubColors.text),
              decoration: const InputDecoration(hintText: 'Country'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _interests,
              style: const TextStyle(color: HubColors.text),
              decoration: const InputDecoration(
                hintText: 'Interests (comma-separated)',
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text('Continue to Deite'),
            ),
            TextButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
    );
  }
}
