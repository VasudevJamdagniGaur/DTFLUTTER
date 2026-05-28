import 'package:flutter/material.dart';

import '../core/theme/hub_colors.dart';
import '../models/tea_item.dart';
import '../services/reddit_service.dart';

class TeaCommentsSheet extends StatefulWidget {
  const TeaCommentsSheet({super.key, required this.item});

  final TeaItem item;

  @override
  State<TeaCommentsSheet> createState() => _TeaCommentsSheetState();
}

class _TeaCommentsSheetState extends State<TeaCommentsSheet> {
  List<RedditComment> _comments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final comments = await redditService.fetchThreadComments(widget.item.url);
    if (mounted) {
      setState(() {
        _comments = comments;
        _loading = false;
        if (comments.isEmpty) _error = 'No comments loaded';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: HubColors.bgSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: HubColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Comments',
                  style: const TextStyle(
                    color: HubColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: HubColors.accent),
                      )
                    : _comments.isEmpty
                        ? Center(
                            child: Text(
                              _error ?? 'No comments',
                              style: const TextStyle(color: HubColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _comments.length,
                            itemBuilder: (_, i) {
                              final c = _comments[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: HubColors.divider,
                                      child: Text(
                                        c.author.isNotEmpty
                                            ? c.author[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: HubColors.text,
                                          fontSize: 12,
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
                                            'u/${c.author}',
                                            style: const TextStyle(
                                              color: HubColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            c.body,
                                            style: const TextStyle(
                                              color: HubColors.text,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
