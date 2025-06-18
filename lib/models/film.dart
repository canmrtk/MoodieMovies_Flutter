import '../constants/constants.dart';

class Film {
  final String id;
  final String title;
  final String? posterUrl;
  final double? rating;

  Film({required this.id, required this.title, this.posterUrl, this.rating});

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      posterUrl: json['imageUrl'] ?? json['posterUrl'] ?? json['poster_url'],
      rating: _toDouble(json['rating'] ?? json['voteAverage'] ?? json['vote_average']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  // Tam URL döndüren yardımcı getter
  String? get fullPosterUrl {
    if (posterUrl == null || posterUrl!.isEmpty) return null;
    if (posterUrl!.startsWith('http')) return posterUrl;
    return '${AppConstants.baseUrl}$posterUrl';
  }
} 