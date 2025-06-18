class User {
  final String id;
  final String name;
  final String email;
  final String? avatarImageUrl;
  final int ratingCount;
  final int favoriteCount;
  final int listCount;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarImageUrl,
    this.ratingCount = 0,
    this.favoriteCount = 0,
    this.listCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      avatarImageUrl: json['avatarImageUrl'] ?? json['avatar_url'],
      ratingCount: _toInt(json['ratingCount'] ?? json['rating_count']),
      favoriteCount: _toInt(json['favoriteCount'] ?? json['favorite_count']),
      listCount: _toInt(json['listCount'] ?? json['list_count']),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
} 