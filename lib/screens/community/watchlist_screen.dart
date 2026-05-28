import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/hub_colors.dart';
import '../../services/tea_watchlist_service.dart';

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
    final list = await teaWatchlistService.getAll();
    if (mounted) setState(() => _items = list);
  }

  Future<void> _remove(String id) async {
    await teaWatchlistService.removeById(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Tea Watchlist'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text(
                'Save items from the Tea feed to see them here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: HubColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                final url = item['url'] as String? ?? '';
                return Dismissible(
                  key: Key('${item['id']}'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _remove('${item['id']}'),
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    color: HubColors.bgSecondary,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        item['title'] as String? ?? 'Saved item',
                        style: const TextStyle(color: HubColors.text),
                      ),
                      subtitle: Text(
                        item['author'] as String? ?? '',
                        style: const TextStyle(color: HubColors.textSecondary),
                      ),
                      trailing: const Icon(Icons.open_in_new,
                          color: HubColors.textSecondary, size: 18),
                      onTap: () async {
                        final uri = Uri.tryParse(url);
                        if (uri != null) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
