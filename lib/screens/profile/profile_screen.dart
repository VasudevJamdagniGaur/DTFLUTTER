import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _uploadingPhoto = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = authService.currentUser;
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getString('user_profile_picture_${user.uid}');
    final result = await firestoreService.getUser(user.uid);
    if (mounted) {
      setState(() {
        _userData = result.data;
        if (local != null && _userData != null) {
          _userData = {..._userData!, 'profilePicture': local};
        }
      });
    }
  }

  Future<void> _changePhoto() async {
    final user = authService.currentUser;
    if (user == null) return;
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 90,
    );
    if (file == null) return;
    setState(() => _uploadingPhoto = true);
    final raw = await file.readAsBytes();
    final compressed = await FlutterImageCompress.compressWithList(
      raw,
      quality: 80,
      minWidth: 512,
      minHeight: 512,
    );
    final url = await firestoreService.uploadProfileImage(user.uid, compressed);
    if (url != null) {
      await firestoreService.ensureUser(
        user.uid,
        profilePicture: url,
        displayName: user.displayName,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_picture_${user.uid}', url);
    }
    if (mounted) {
      setState(() => _uploadingPhoto = false);
      await _load();
    }
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
    final photo = _userData?['profilePicture'] as String?;

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
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundImage:
                    photo != null ? NetworkImage(photo) : null,
                child: photo == null
                    ? const Icon(Icons.person, size: 48)
                    : null,
              ),
              if (_uploadingPhoto)
                const Positioned.fill(
                  child: CircularProgressIndicator(color: HubColors.accent),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _uploadingPhoto ? null : _changePhoto,
              child: const Text('Change photo'),
            ),
          ),
          const SizedBox(height: 8),
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
          ListTile(
            leading: const Icon(Icons.local_cafe_outlined, color: HubColors.accent),
            title: const Text('Tea feed',
                style: TextStyle(color: HubColors.text)),
            onTap: () => context.push('/tea-feed'),
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
