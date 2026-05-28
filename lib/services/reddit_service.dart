import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/tea_item.dart';

/// Reddit public JSON API — port of TrendingTea + redditThreadComments.
class RedditService {
  RedditService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _teaSubreddit = 'BollyBlindsNGossip';
  static const _hotUrl =
      'https://www.reddit.com/r/$_teaSubreddit/hot.json?limit=50&raw_json=1';

  static const _excludedTitleKeywords = [
    'subreddit',
    'moderator',
    'mods',
    'rules',
    'banned',
    'removed',
    'fanclub',
    'announcement',
    'meta',
    'policy',
  ];

  static const _bollywoodKeywords = [
    'bollywood',
    'movie',
    'film',
    'actor',
    'actress',
    'box office',
    'trailer',
    'release',
  ];

  Future<List<TeaItem>> fetchTrendingTea({int maxItems = 12}) async {
    final json = await _fetchJson(_hotUrl);
    if (json == null) return [];

    final children = json['data']?['children'] as List<dynamic>? ?? [];
    final posts = children
        .map((c) => c is Map ? c['data'] as Map<String, dynamic>? : null)
        .whereType<Map<String, dynamic>>()
        .toList();

    final filtered = posts.where(_isValidTeaPost).toList();
    final items = filtered
        .map(TeaItem.fromRedditPost)
        .where((t) => t.url.isNotEmpty && t.title.isNotEmpty)
        .take(maxItems)
        .toList();
    return items;
  }

  bool _isValidTeaPost(Map<String, dynamic> post) {
    if (post['stickied'] == true) return false;
    final title = (post['title'] as String? ?? '').toLowerCase();
    for (final kw in _excludedTitleKeywords) {
      if (title.contains(kw)) return false;
    }
    final score = (post['score'] as num?)?.toInt() ?? 0;
    if (score < 10) return false;
    final selftext = (post['selftext'] as String? ?? '').trim();
    if (post['is_self'] == true && selftext.length < 20) return false;
    final haystack = '$title ${selftext.toLowerCase()}';
    return _bollywoodKeywords.any(haystack.contains);
  }

  Future<List<RedditComment>> fetchThreadComments(String discussionUrl) async {
    final jsonUrl = _threadJsonUrl(discussionUrl);
    if (jsonUrl == null) return [];
    final json = await _fetchJson(jsonUrl);
    if (json == null || json is! List || json.length < 2) return [];

    final listing = json[1]?['data']?['children'] as List<dynamic>? ?? [];
    final rows = <RedditComment>[];
    for (final child in listing) {
      if (child is! Map || child['kind'] != 't1') continue;
      final d = child['data'] as Map<String, dynamic>?;
      if (d == null || d['stickied'] == true) continue;
      final body = (d['body'] as String? ?? '').trim();
      if (body.isEmpty || body == '[deleted]' || body == '[removed]') {
        continue;
      }
      rows.add(RedditComment(
        id: d['id'] as String? ?? '${rows.length}',
        author: d['author'] as String? ?? 'unknown',
        body: body,
        score: (d['score'] as num?)?.toInt() ?? 0,
        createdUtc: (d['created_utc'] as num?)?.toDouble(),
      ));
    }
    rows.sort((a, b) => b.score.compareTo(a.score));
    return rows.take(40).toList();
  }

  String? _threadJsonUrl(String url) {
    final u = url.trim().replaceAll(RegExp(r'/?(\?.*)?$'), '');
    if (!u.contains('reddit.com/r/')) return null;
    return '$u.json?raw_json=1&limit=50&depth=1&sort=top';
  }

  Future<dynamic> _fetchJson(String url) async {
    try {
      final res = await _client
          .get(
            Uri.parse(url),
            headers: {'Accept': 'application/json', 'User-Agent': 'Deite/1.0'},
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return _fetchViaProxy(url);
  }

  Future<dynamic> _fetchViaProxy(String targetUrl) async {
    final encoded = Uri.encodeComponent(targetUrl);
    final proxies = [
      'https://api.codetabs.com/v1/proxy?quest=$encoded',
      'https://corsproxy.io/?$encoded',
      'https://api.allorigins.win/get?url=$encoded',
    ];
    for (final proxy in proxies) {
      try {
        final res = await _client.get(Uri.parse(proxy)).timeout(
              const Duration(seconds: 15),
            );
        if (res.statusCode < 200 || res.statusCode >= 300) continue;
        if (proxy.contains('allorigins')) {
          final j = jsonDecode(res.body) as Map<String, dynamic>;
          final txt = j['contents'] as String?;
          if (txt != null) return jsonDecode(txt);
        } else {
          return jsonDecode(res.body);
        }
      } catch (_) {}
    }
    return null;
  }
}

final redditService = RedditService();
