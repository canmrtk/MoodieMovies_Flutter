class ForumComment {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final DateTime createdAt;

  ForumComment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.createdAt,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? {};
    return ForumComment(
      id: json['id'].toString(),
      content: json['content'] ?? '',
      authorId: author['id']?.toString() ?? '',
      authorName: author['name'] ?? '',
      authorAvatarUrl: author['avatarImageUrl'],
      createdAt: _parseDate(json['created'] ?? json['createdAt'] ?? json['created_at']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse(value.toString());
    return parsed ?? DateTime.now();
  }
} 