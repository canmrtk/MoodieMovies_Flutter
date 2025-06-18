class ForumPostSummary {
  final String id;
  final String title;
  final String authorName;
  final String? authorAvatarUrl;
  final int commentCount;
  final DateTime createdAt;
  final String? tag;

  ForumPostSummary({
    required this.id,
    required this.title,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.commentCount,
    required this.createdAt,
    this.tag,
  });

  factory ForumPostSummary.fromJson(Map<String, dynamic> json) {
    return ForumPostSummary(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      authorName: json['author'] != null ? json['author']['name'] ?? '' : (json['authorName'] ?? ''),
      authorAvatarUrl: json['author'] != null ? json['author']['avatarImageUrl'] : null,
      commentCount: _extractCommentCount(json),
      createdAt: _parseDate(json['created'] ?? json['createdAt'] ?? json['created_at']),
      tag: json['tag'],
    );
  }

  // ---- helpers ----
  static int _extractCommentCount(Map<String, dynamic> json) {
    final cc = json['commentCount'];
    if (cc is int) return cc;
    if (cc is String) return int.tryParse(cc) ?? 0;
    // Fallback to comments array length if provided
    final commentsField = json['comments'];
    if (commentsField is List) return commentsField.length;
    return 0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse(value.toString());
    return parsed ?? DateTime.now();
  }
} 