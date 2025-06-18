import 'forum_post_summary.dart';
import 'forum_comment.dart';

class ForumPostDetail {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final DateTime createdAt;
  final List<ForumComment> comments;

  ForumPostDetail({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.createdAt,
    required this.comments,
  });

  factory ForumPostDetail.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? {};
    return ForumPostDetail(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorId: author['id']?.toString() ?? '',
      authorName: author['name'] ?? '',
      authorAvatarUrl: author['avatarImageUrl'],
      createdAt: _parseDate(json['created'] ?? json['createdAt'] ?? json['created_at']),
      comments: (json['comments'] as List<dynamic>? ?? []).map((e) => ForumComment.fromJson(e)).toList(),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse(value.toString());
    return parsed ?? DateTime.now();
  }
} 