import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/hub_colors.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('tea_watchlist');
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      setState(() {
        _items = list.cast<Map<String, dynamic>>();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('Watchlist'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text(
                'No saved tea items.',
                style: TextStyle(color: HubColors.textSecondary),
              ),
            )
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                return ListTile(
                  title: Text(
                    item['title'] as String? ?? 'Item',
                    style: const TextStyle(color: HubColors.text),
                  ),
                );
              },
            ),
    );
  }
}
