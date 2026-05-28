import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/hub_colors.dart';
import '../models/news_item.dart';
import '../models/news_share_article.dart';

class NewsArticleCard extends StatelessWidget {
  const NewsArticleCard({super.key, required this.item});

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: HubColors.bgSecondary,
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openUrl(item.url),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.image != null && item.image!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: item.image!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _placeholderImage(),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.source.isNotEmpty)
                    Text(
                      item.source,
                      style: const TextStyle(
                        color: HubColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: HubColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: HubColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        context.push(
                          '/share-suggestions',
                          extra: {
                            'newsArticle': NewsShareArticle(
                              title: item.title,
                              url: item.url,
                              description: item.description,
                              image: item.image,
                              source: item.source,
                            ).toMap(),
                            'platform': 'linkedin',
                          },
                        );
                      },
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 120,
      color: HubColors.divider,
      child: const Center(
        child: Icon(Icons.article_outlined, color: HubColors.textSecondary, size: 40),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
