import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/news_share_article.dart';
import '../models/share_style.dart';
import 'vertex_api_client.dart';

/// AI share post generation — port of ShareSuggestionsPage + chatService helpers.
class ShareSuggestionsService {
  ShareSuggestionsService({VertexApiClient? vertex})
      : _vertex = vertex ?? vertexApiClient;

  final VertexApiClient _vertex;
  static const _cacheKey = 'deite_share_suggestions_cache_v1';

  Future<List<SharePostSuggestion>> generateReflectionPosts({
    required String reflection,
    required String platform,
    ShareStyle? style,
  }) async {
    final styleGuide = style?.instruction ?? ShareStyle.variants.first.instruction;
    final platformGuide = _platformGuide(platform);
    final prompt = '''
Turn this reflection into 1-3 separate social posts for $platformGuide

Style: $styleGuide

Rules:
- Output ONLY valid JSON: {"posts":[{"eventLabel":"...","post":"..."}]}
- Each post is standalone publishable text only.

Reflection:
$reflection
''';
    return _generatePosts(prompt, platform: platform);
  }

  Future<List<SharePostSuggestion>> generateNewsPosts({
    required NewsShareArticle article,
    required String platform,
  }) async {
    final cached = await getCachedForUrl(article.url, platform);
    if (cached.isNotEmpty) return cached;

    final platformGuide = _platformGuide(platform);
    final prompt = '''
Write 1-3 social posts for $platformGuide as if the poster just saw this in their news feed and is sharing their reaction — NOT a neutral news summary.

Title: ${article.title}
${article.source.isNotEmpty ? 'Source: ${article.source}\n' : ''}${article.description.isNotEmpty ? 'Summary: ${article.description}\n' : ''}URL: ${article.url}

Rules:
- First person, human, opinionated where appropriate.
- Output ONLY valid JSON: {"posts":[{"eventLabel":"News","post":"..."}]}

''';
    final posts = await _generatePosts(prompt, platform: platform, temperature: 0.7);
    await cacheForUrl(article.url, platform, posts);
    return posts;
  }

  Future<List<SharePostSuggestion>> _generatePosts(
    String prompt, {
    required String platform,
    double temperature = 0.65,
  }) async {
    if (!_vertex.isConfigured) {
      return [
        SharePostSuggestion(
          eventLabel: 'Draft',
          post: 'Configure BACKEND_URL to generate AI suggestions.',
        ),
      ];
    }
    try {
      final raw = await _vertex.generateContent(
        prompt: prompt,
        temperature: temperature,
        maxOutputTokens: platform == 'linkedin' ? 4096 : 2048,
      );
      return _parsePostsJson(raw);
    } catch (_) {
      return [
        const SharePostSuggestion(
          eventLabel: 'Error',
          post: 'Could not generate suggestions. Try again.',
        ),
      ];
    }
  }

  List<SharePostSuggestion> _parsePostsJson(String raw) {
    try {
      final match = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
      if (match == null) return _fallbackFromText(raw);
      final json = jsonDecode(match.group(0)!) as Map<String, dynamic>;
      final posts = json['posts'] as List<dynamic>? ?? [];
      return posts
          .whereType<Map<String, dynamic>>()
          .map(SharePostSuggestion.fromJson)
          .where((p) => p.post.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return _fallbackFromText(raw);
    }
  }

  List<SharePostSuggestion> _fallbackFromText(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return [];
    return [SharePostSuggestion(eventLabel: 'Post', post: t)];
  }

  String _platformGuide(String platform) {
    return switch (platform) {
      'x' => 'X (Twitter) — under 280 characters per post',
      'reddit' => 'Reddit — casual, conversational',
      _ => 'LinkedIn — professional but personal',
    };
  }

  Future<List<SharePostSuggestion>> getCachedForUrl(
    String url,
    String platform,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return [];
    try {
      final all = jsonDecode(raw) as Map<String, dynamic>;
      final key = _cacheKeyFor(url, platform);
      final list = all[key] as List<dynamic>?;
      if (list == null) return [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(SharePostSuggestion.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> cacheForUrl(
    String url,
    String platform,
    List<SharePostSuggestion> posts,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> all = {};
    final raw = prefs.getString(_cacheKey);
    if (raw != null) {
      try {
        all = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {}
    }
    all[_cacheKeyFor(url, platform)] =
        posts.map((p) => {'eventLabel': p.eventLabel, 'post': p.post}).toList();
    await prefs.setString(_cacheKey, jsonEncode(all));
  }

  String _cacheKeyFor(String url, String platform) => '$platform::$url';
}

final shareSuggestionsService = ShareSuggestionsService();
