class TeaItem {
  const TeaItem({
    required this.id,
    required this.title,
    required this.url,
    this.postUrl = '',
    this.thumbnail = '',
    this.author = 'unknown',
    this.score = 0,
    this.numComments = 0,
    this.source = 'r/BollyBlindsNGossip',
  });

  final String id;
  final String title;
  final String url;
  final String postUrl;
  final String thumbnail;
  final String author;
  final int score;
  final int numComments;
  final String source;

  String? get heroImageUrl {
    if (_isDirectImage(postUrl)) return postUrl;
    if (thumbnail.startsWith('http')) return thumbnail;
    return null;
  }

  static bool _isDirectImage(String url) {
    final path = url.split('?').first.split('#').first;
    return RegExp(r'\.(jpe?g|png|gif|webp)$', caseSensitive: false).hasMatch(path);
  }

  factory TeaItem.fromRedditPost(Map<String, dynamic> d) {
    final permalink = d['permalink'] as String? ?? '';
    final url = permalink.isNotEmpty
        ? 'https://www.reddit.com${permalink.startsWith('/') ? '' : '/'}$permalink'
        : '';
    return TeaItem(
      id: d['id'] as String? ?? d['name'] as String? ?? '',
      title: d['title'] as String? ?? '',
      url: url,
      postUrl: d['url'] as String? ?? '',
      thumbnail: d['thumbnail'] as String? ?? '',
      author: d['author'] as String? ?? 'unknown',
      score: (d['score'] as num?)?.toInt() ?? 0,
      numComments: (d['num_comments'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toWatchlistMap() => {
        'id': id,
        'title': title,
        'url': url,
        'postUrl': postUrl,
        'thumbnail': thumbnail,
        'author': author,
        'source': source,
      };
}

class RedditComment {
  const RedditComment({
    required this.id,
    required this.author,
    required this.body,
    this.score = 0,
    this.createdUtc,
  });

  final String id;
  final String author;
  final String body;
  final int score;
  final double? createdUtc;
}
