import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import '../models/news_item.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

/// Hub & pod topic news — port of `hubNewsService.js` + Google News RSS fallback.
class HubNewsService {
  HubNewsService({
    FirebaseFirestore? firestore,
    FirestoreService? fs,
    AuthService? auth,
    http.Client? client,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _fs = fs ?? firestoreService,
        _auth = auth ?? authService,
        _client = client ?? http.Client();

  final FirebaseFirestore _db;
  final FirestoreService _fs;
  final AuthService _auth;
  final http.Client _client;

  static String docIdFromUrl(String url) {
    final s = url;
    var h = 0;
    for (var i = 0; i < s.length; i++) {
      h = ((h << 5) - h + s.codeUnitAt(i)) & 0x7fffffff;
    }
    return 'hn_${h.abs().toRadixString(36)}';
  }

  /// Topic id → Google News RSS search query.
  static const topicQueries = {
    'cricket': 'cricket OR IPL when:2d',
    'football': 'soccer OR Premier League when:2d',
    'basketball': 'NBA OR basketball when:2d',
    'tennis': 'tennis ATP WTA when:2d',
    'ai': 'artificial intelligence OR OpenAI when:2d',
    'startups': 'tech startups funding when:2d',
    'gadgets': 'new gadgets technology when:2d',
    'funding': 'venture capital funding when:2d',
    'saas': 'SaaS business when:2d',
    'marketing': 'digital marketing when:2d',
    'world': 'world news when:1d',
    'politics': 'politics when:1d',
    'economy': 'economy markets when:1d',
  };

  Future<List<NewsItem>> fetchForTopic(String topicId, {int limit = 20}) async {
    final fromFirestore = await _fetchFromFirestore(topicId, limit: limit);
    if (fromFirestore.length >= 5) return fromFirestore;

    final query = topicQueries[topicId] ?? '$topicId news when:2d';
    final fromRss = await _fetchGoogleNewsRss(query, limit: limit);
    final seen = <String>{};
    final merged = <NewsItem>[];
    for (final item in [...fromFirestore, ...fromRss]) {
      if (item.url.isEmpty || seen.contains(item.url)) continue;
      seen.add(item.url);
      merged.add(item);
      if (merged.length >= limit) break;
    }
    return merged;
  }

  Future<List<NewsItem>> _fetchFromFirestore(
    String category, {
    int limit = 20,
  }) async {
    try {
      final user = _auth.currentUser;
      var country = 'US';
      if (user != null) {
        final profile = await _fs.getUser(user.uid);
        final c = profile.data?['country'] as String?;
        if (c != null && c.length == 2) country = c.toUpperCase();
      }
      final snap = await _db
          .collection('news')
          .where('country', isEqualTo: country)
          .where('category', isEqualTo: category.toLowerCase())
          .orderBy('trendingScore', descending: true)
          .limit(limit)
          .get();
      return snap.docs
          .map((d) => NewsItem.fromMap(d.id, d.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<NewsItem>> _fetchGoogleNewsRss(String searchQuery, {int limit = 20}) async {
    try {
      final url = Uri.parse(
        'https://news.google.com/rss/search?q=${Uri.encodeComponent(searchQuery)}&hl=en-US&gl=US&ceid=US:en',
      );
      final res = await _client.get(url).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return [];
      return _parseRss(res.body, limit: limit);
    } catch (_) {
      return [];
    }
  }

  List<NewsItem> _parseRss(String xmlBody, {int limit = 20}) {
    final items = <NewsItem>[];
    try {
      final doc = xml.XmlDocument.parse(xmlBody);
      final elements = doc.findAllElements('item');
      for (final item in elements) {
        if (items.length >= limit) break;
        final title = item.getElement('title')?.innerText.trim() ?? '';
        final link = item.getElement('link')?.innerText.trim() ?? '';
        final source = item.getElement('source')?.innerText.trim() ?? 'News';
        final desc = item.getElement('description')?.innerText.trim() ?? '';
        if (title.isEmpty || link.isEmpty) continue;
        items.add(NewsItem(
          id: docIdFromUrl(link),
          title: _stripHtml(title),
          url: link,
          source: source,
          description: _stripHtml(desc).length > 200
              ? '${_stripHtml(desc).substring(0, 200)}...'
              : _stripHtml(desc),
        ));
      }
    } catch (_) {
      return items;
    }
    return items;
  }

  String _stripHtml(String s) {
    return s
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }
}

final hubNewsService = HubNewsService();
