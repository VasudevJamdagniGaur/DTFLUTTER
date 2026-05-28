class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    this.image,
    this.source = '',
    this.url = '',
    this.category = '',
    this.description = '',
  });

  final String id;
  final String title;
  final String? image;
  final String source;
  final String url;
  final String category;
  final String description;

  factory NewsItem.fromMap(String id, Map<String, dynamic> m) {
    return NewsItem(
      id: id,
      title: m['title'] as String? ?? '',
      image: m['image'] as String?,
      source: m['source'] as String? ?? '',
      url: m['url'] as String? ?? '',
      category: m['category'] as String? ?? '',
      description: m['description'] as String? ?? '',
    );
  }
}
