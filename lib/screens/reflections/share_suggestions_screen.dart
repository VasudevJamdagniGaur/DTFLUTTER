import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/hub_colors.dart';
import '../../models/news_share_article.dart';
import '../../models/share_style.dart';
import '../../services/auth_service.dart';
import '../../services/share_suggestions_service.dart';
import '../../widgets/tweet_share_card.dart';

class ShareSuggestionsScreen extends StatefulWidget {
  const ShareSuggestionsScreen({
    super.key,
    this.initialReflection,
    this.newsArticle,
  });

  final String? initialReflection;
  final NewsShareArticle? newsArticle;

  @override
  State<ShareSuggestionsScreen> createState() => _ShareSuggestionsScreenState();
}

class _ShareSuggestionsScreenState extends State<ShareSuggestionsScreen> {
  final _reflection = TextEditingController();
  final _screenshot = ScreenshotController();
  String _platform = 'linkedin';
  String _styleId = 'minimal';
  List<SharePostSuggestion> _posts = [];
  bool _loading = false;
  NewsShareArticle? _news;

  bool get _isNewsMode => _news != null;

  @override
  void initState() {
    super.initState();
    _news = widget.newsArticle;
    if (widget.initialReflection != null &&
        widget.initialReflection!.isNotEmpty) {
      _reflection.text = widget.initialReflection!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is Map) {
      if (_news == null && extra['newsArticle'] is Map) {
        _news = NewsShareArticle.fromMap(
          Map<String, dynamic>.from(extra['newsArticle'] as Map),
        );
      }
      if (_reflection.text.isEmpty && extra['reflection'] is String) {
        _reflection.text = extra['reflection'] as String;
      }
      if (extra['platform'] is String) {
        _platform = extra['platform'] as String;
      }
    }
    if (_isNewsMode && _posts.isEmpty && !_loading) {
      _generate();
    }
  }

  @override
  void dispose() {
    _reflection.dispose();
    super.dispose();
  }

  ShareStyle get _style => ShareStyle.variants.firstWhere(
        (s) => s.id == _styleId,
        orElse: () => ShareStyle.variants.first,
      );

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _posts = [];
    });
    try {
      if (_isNewsMode && _news != null) {
        final posts = await shareSuggestionsService.generateNewsPosts(
          article: _news!,
          platform: _platform,
        );
        if (mounted) setState(() => _posts = posts);
      } else {
        final text = _reflection.text.trim();
        if (text.isEmpty) return;
        final posts = await shareSuggestionsService.generateReflectionPosts(
          reflection: text,
          platform: _platform,
          style: _style,
        );
        if (mounted) setState(() => _posts = posts);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _shareTweetCard(String postText) async {
    final image = await _screenshot.capture();
    if (image == null) return;
    await Share.shareXFiles(
      [
        XFile.fromData(image, name: 'deite-post.png', mimeType: 'image/png'),
      ],
      text: postText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: Text(_isNewsMode ? 'Share article' : 'Share Suggestions'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isNewsMode && _news != null) ...[
              Text(
                _news!.title,
                style: const TextStyle(
                  color: HubColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_news!.source.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _news!.source,
                    style: const TextStyle(color: HubColors.accent),
                  ),
                ),
              const SizedBox(height: 16),
            ] else ...[
              const Text(
                'Turn your reflection into social posts with AI.',
                style: TextStyle(color: HubColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reflection,
                maxLines: 6,
                style: const TextStyle(color: HubColors.text),
                decoration: const InputDecoration(hintText: 'Your reflection...'),
              ),
              const SizedBox(height: 16),
              const Text('Style',
                  style: TextStyle(
                      color: HubColors.text, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ShareStyle.variants.map((s) {
                  return FilterChip(
                    label: Text(s.label),
                    selected: s.id == _styleId,
                    onSelected: (_) => setState(() => _styleId = s.id),
                    selectedColor: HubColors.accent.withValues(alpha: 0.3),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            const Text('Platform',
                style:
                    TextStyle(color: HubColors.text, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'linkedin', label: Text('LinkedIn')),
                ButtonSegment(value: 'x', label: Text('X')),
                ButtonSegment(value: 'reddit', label: Text('Reddit')),
              ],
              selected: {_platform},
              onSelectionChanged: (s) {
                setState(() => _platform = s.first);
                if (_isNewsMode) _generate();
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _generate,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isNewsMode ? 'Regenerate' : 'Generate suggestions'),
            ),
            if (_posts.isNotEmpty) ...[
              const SizedBox(height: 24),
              ..._posts.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.eventLabel,
                        style: const TextStyle(
                          color: HubColors.accentHighlight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_platform == 'x')
                        Screenshot(
                          controller: _screenshot,
                          child: TweetShareCard(
                            text: p.post,
                            heroImageUrl: _news?.image,
                            displayName:
                                authService.currentUser?.displayName ?? 'Deite User',
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: HubColors.bgSecondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            p.post,
                            style: const TextStyle(
                              color: HubColors.text,
                              height: 1.5,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: p.post));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied')),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Copy'),
                          ),
                          TextButton.icon(
                            onPressed: () => _platform == 'x'
                                ? _shareTweetCard(p.post)
                                : Share.share(p.post),
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('Share'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
