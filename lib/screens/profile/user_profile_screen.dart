import 'package:flutter/material.dart';

import '../../core/theme/hub_colors.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _data;
  bool _following = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await firestoreService.getUser(widget.userId);
    final me = authService.currentUser;
    var following = false;
    if (me != null) {
      final list = await firestoreService.getFollowing(me.uid);
      following = list.contains(widget.userId);
    }
    if (mounted) {
      setState(() {
        _data = result.data;
        _following = following;
      });
    }
  }

  Future<void> _toggleFollow() async {
    final me = authService.currentUser;
    if (me == null) return;
    if (_following) {
      await firestoreService.unfollowUser(me.uid, widget.userId);
    } else {
      await firestoreService.followUser(me.uid, widget.userId);
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final name = _data?['displayName'] as String? ?? 'User';
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: Text(name),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: _data?['profilePicture'] != null
                  ? NetworkImage(_data!['profilePicture'] as String)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(color: HubColors.text, fontSize: 22)),
            const SizedBox(height: 16),
            if (authService.currentUser?.uid != widget.userId)
              ElevatedButton(
                onPressed: _toggleFollow,
                child: Text(_following ? 'Unfollow' : 'Follow'),
              ),
          ],
        ),
      ),
    );
  }
}
