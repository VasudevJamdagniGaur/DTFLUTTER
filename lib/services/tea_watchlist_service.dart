import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Mirrors `src/lib/teaWatchlistStorage.js`.
class TeaWatchlistService {
  static const _key = 'deite_tea_watchlist_v1';

  Future<List<Map<String, dynamic>>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final arr = jsonDecode(raw) as List<dynamic>;
      return arr.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _save(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items));
  }

  Map<String, dynamic> normalizeItem(Map<String, dynamic> item) {
    return {
      'id': '${item['id'] ?? ''}',
      'title': item['title'] as String? ?? '',
      'url': item['url'] as String? ?? '',
      'postUrl': item['postUrl'] as String? ?? '',
      'thumbnail': item['thumbnail'] as String? ?? '',
      'author': item['author'] as String? ?? '',
      'savedAt': DateTime.now().toIso8601String(),
      'source': 'tea',
    };
  }

  Future<List<Map<String, dynamic>>> toggle(Map<String, dynamic> item) async {
    final id = '${item['id'] ?? ''}';
    if (id.isEmpty) return getAll();
    final list = await getAll();
    final idx = list.indexWhere((x) => '${x['id']}' == id);
    if (idx >= 0) {
      list.removeAt(idx);
    } else {
      final row = normalizeItem(item);
      if ('${row['url']}'.isEmpty) return list;
      list.insert(0, row);
    }
    await _save(list);
    return list;
  }

  Future<List<Map<String, dynamic>>> removeById(String postId) async {
    final list = await getAll();
    list.removeWhere((x) => '${x['id']}' == postId);
    await _save(list);
    return list;
  }

  Future<bool> isWatchlisted(String postId) async {
    final list = await getAll();
    return list.any((x) => '${x['id']}' == postId);
  }
}

final teaWatchlistService = TeaWatchlistService();
