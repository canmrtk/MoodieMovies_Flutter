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
      posterUrl: json['posterUrl'] ?? json['poster_url'],
      rating: (json['rating'] ?? json['voteAverage'] ?? json['vote_average'])?.toDouble(),
    );
  }
} 