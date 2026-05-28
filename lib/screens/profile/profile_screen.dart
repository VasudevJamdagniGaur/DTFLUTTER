import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/hub_colors.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = authService.currentUser;
    if (user == null) return;
    final result = await firestoreService.getUser(user.uid);
    if (mounted) setState(() => _userData = result.data);
  }

  Future<void> _signOut() async {
    await authService.signOut();
    if (mounted) context.go('/landing');
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final name = _userData?['displayName'] as String? ??
        user?.displayName ??
        'User';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: _userData?['profilePicture'] != null
                ? NetworkImage(_userData!['profilePicture'] as String)
                : null,
            child: _userData?['profilePicture'] == null
                ? const Icon(Icons.person, size: 48)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: HubColors.text,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: HubColors.textSecondary),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.help_outline, color: HubColors.accent),
            title: const Text('Help improve Deite',
                style: TextStyle(color: HubColors.text)),
            onTap: () => context.push('/help-improve-deite'),
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined, color: HubColors.accent),
            title: const Text('Share suggestions',
                style: TextStyle(color: HubColors.text)),
            onTap: () => context.push('/share-suggestions'),
          ),
          const Divider(color: HubColors.divider),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Sign out',
                style: TextStyle(color: Colors.redAccent)),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }
}
