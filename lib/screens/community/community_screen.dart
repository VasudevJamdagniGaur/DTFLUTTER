import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;
  final _composer = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final posts = await firestoreService.getCommunityPosts();
    if (mounted) {
      setState(() {
        _posts = posts;
        _loading = false;
      });
    }
  }

  Future<void> _post() async {
    final user = authService.currentUser;
    final text = _composer.text.trim();
    if (user == null || text.isEmpty) return;
    await firestoreService.createCommunityPost(
      authorId: user.uid,
      text: text,
      displayName: user.displayName,
    );
    _composer.clear();
    await _load();
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => context.push('/watchlist'),
          ),
          IconButton(
            icon: const Icon(Icons.local_cafe_outlined),
            onPressed: () => context.push('/tea-feed'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _composer,
                    style: const TextStyle(color: HubColors.text),
                    decoration: InputDecoration(
                      hintText: 'Share with the community...',
                      filled: true,
                      fillColor: HubColors.bgSecondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _post,
                  icon: const Icon(Icons.send, color: HubColors.accent),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: HubColors.accent),
                  )
                : _posts.isEmpty
                    ? const Center(
                        child: Text(
                          'No posts yet. Be the first!',
                          style: TextStyle(color: HubColors.textSecondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          itemCount: _posts.length,
                          itemBuilder: (_, i) {
                            final p = _posts[i];
                            final authorId = p['authorId'] as String? ?? '';
                            return ListTile(
                              title: Text(
                                p['authorName'] as String? ?? 'User',
                                style: const TextStyle(
                                  color: HubColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                p['text_content'] as String? ??
                                    p['content'] as String? ??
                                    '',
                                style: const TextStyle(color: HubColors.text),
                              ),
                              onTap: authorId.isNotEmpty
                                  ? () => context.push('/user/$authorId')
                                  : null,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
