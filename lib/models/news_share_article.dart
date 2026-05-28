class NewsShareArticle {
  const NewsShareArticle({
    required this.title,
    required this.url,
    this.description = '',
    this.image,
    this.source = '',
  });

  final String title;
  final String url;
  final String description;
  final String? image;
  final String source;

  factory NewsShareArticle.fromMap(Map<String, dynamic> m) {
    return NewsShareArticle(
      title: m['title'] as String? ?? '',
      url: m['url'] as String? ?? '',
      description: m['description'] as String? ?? '',
      image: m['image'] as String?,
      source: m['source'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'url': url,
        'description': description,
        if (image != null) 'image': image,
        'source': source,
      };
}

class SharePostSuggestion {
  const SharePostSuggestion({
    required this.eventLabel,
    required this.post,
  });

  final String eventLabel;
  final String post;

  factory SharePostSuggestion.fromJson(Map<String, dynamic> j) {
    return SharePostSuggestion(
      eventLabel: j['eventLabel'] as String? ?? 'Post',
      post: j['post'] as String? ?? '',
    );
  }
}
