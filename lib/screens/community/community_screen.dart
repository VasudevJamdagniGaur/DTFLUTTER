import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
  bool _posting = false;
  final _composer = TextEditingController();
  Uint8List? _pendingImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final posts = await firestoreService.getCommunityPosts(limit: 40);
    if (mounted) {
      setState(() {
        _posts = posts;
        _loading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (file == null) return;
    final raw = await file.readAsBytes();
    final compressed = await FlutterImageCompress.compressWithList(
      raw,
      quality: 75,
      minWidth: 1080,
    );
    setState(() => _pendingImage = compressed);
  }

  Future<void> _post() async {
    final user = authService.currentUser;
    final text = _composer.text.trim();
    if (user == null || (text.isEmpty && _pendingImage == null)) return;
    setState(() => _posting = true);
    String? imageUrl;
    if (_pendingImage != null) {
      imageUrl = await firestoreService.uploadPostImageBytes(
        user.uid,
        _pendingImage!,
      );
    }
    await firestoreService.createCommunityPost(
      authorId: user.uid,
      text: text.isEmpty ? '📷' : text,
      imageUrl: imageUrl,
      displayName: user.displayName,
    );
    _composer.clear();
    setState(() {
      _pendingImage = null;
      _posting = false;
    });
    await _load();
  }

  Future<void> _like(String postId, int index) async {
    final ok = await firestoreService.incrementCommunityPostLike(postId);
    if (ok && mounted) {
      setState(() {
        final likes = (_posts[index]['likes'] as int? ?? 0) + 1;
        _posts[index] = {..._posts[index], 'likes': likes};
      });
    }
  }

  String _timeAgo(dynamic ts) {
    if (ts == null) return '';
    DateTime? dt;
    if (ts is DateTime) {
      dt = ts;
    } else {
      try {
        dt = (ts as dynamic).toDate() as DateTime?;
      } catch (_) {}
    }
    if (dt == null) return '';
    return DateFormat.MMMd().add_jm().format(dt);
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
            onPressed: () => context.push(
              '/tea-feed',
              extra: {'returnTo': '/community'},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (_pendingImage != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _pendingImage!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() => _pendingImage = null),
                        ),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image_outlined,
                          color: HubColors.accent),
                    ),
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
                      onPressed: _posting ? null : _post,
                      icon: _posting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send, color: HubColors.accent),
                    ),
                  ],
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
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _posts.length,
                          itemBuilder: (_, i) {
                            final p = _posts[i];
                            final authorId = p['authorId'] as String? ?? '';
                            final imageUrl = p['image_url'] as String? ??
                                p['image'] as String?;
                            final likes = p['likes'] as int? ?? 0;
                            return Card(
                              color: HubColors.bgSecondary,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: authorId.isNotEmpty
                                          ? () => context.push('/user/$authorId')
                                          : null,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: HubColors.accent,
                                            child: Text(
                                              (p['authorName'] as String? ?? 'U')
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  p['authorName'] as String? ??
                                                      'User',
                                                  style: const TextStyle(
                                                    color: HubColors.text,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  _timeAgo(p['createdAt']),
                                                  style: const TextStyle(
                                                    color: HubColors.textSecondary,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      p['text_content'] as String? ??
                                          p['content'] as String? ??
                                          '',
                                      style: const TextStyle(
                                        color: HubColors.text,
                                        height: 1.4,
                                      ),
                                    ),
                                    if (imageUrl != null &&
                                        imageUrl.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) =>
                                              const SizedBox.shrink(),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.favorite_border,
                                            color: HubColors.textSecondary,
                                            size: 20,
                                          ),
                                          onPressed: () => _like(
                                            p['id'] as String,
                                            i,
                                          ),
                                        ),
                                        Text(
                                          '$likes',
                                          style: const TextStyle(
                                            color: HubColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
