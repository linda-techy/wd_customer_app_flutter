class LiveActivity {
  final String customerName;
  final String location;
  final String action;
  final String? timestamp;

  const LiveActivity({
    required this.customerName,
    required this.location,
    required this.action,
    this.timestamp,
  });

  factory LiveActivity.fromJson(Map<String, dynamic> json) {
    return LiveActivity(
      customerName: json['customerName']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      timestamp: json['timestamp']?.toString(),
    );
  }
}

class BlogPost {
  final String id;
  final String title;
  final String slug;
  final String excerpt;
  final String? content;
  final String? imageUrl;
  final String author;
  final String? publishedAt;

  const BlogPost({
    required this.id,
    required this.title,
    required this.slug,
    required this.excerpt,
    this.content,
    this.imageUrl,
    required this.author,
    this.publishedAt,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      excerpt: json['excerpt']?.toString() ?? '',
      content: json['content']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      author: json['author']?.toString() ?? '',
      publishedAt: json['publishedAt']?.toString(),
    );
  }
}

class PortfolioItem {
  final String id;
  final String title;
  final String slug;
  final String? description;
  final String? location;
  final String? projectType;
  final int? areaSqft;
  final String? completionDate;
  final String? coverImageUrl;
  final List<String> imageUrls;

  const PortfolioItem({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.location,
    this.projectType,
    this.areaSqft,
    this.completionDate,
    this.coverImageUrl,
    this.imageUrls = const [],
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    final rawImages = json['imageUrls'];
    final List<String> images = rawImages is List
        ? rawImages.map((e) => e?.toString() ?? '').toList()
        : [];

    return PortfolioItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      location: json['location']?.toString(),
      projectType: json['projectType']?.toString(),
      areaSqft: json['areaSqft'] is int ? json['areaSqft'] as int : null,
      completionDate: json['completionDate']?.toString(),
      coverImageUrl: json['coverImageUrl']?.toString(),
      imageUrls: images,
    );
  }
}
