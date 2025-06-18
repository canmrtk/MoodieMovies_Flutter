class FilmSuggestion {
  final String id;
  final String title;
  final String imageUrl;

  FilmSuggestion({required this.id, required this.title, required this.imageUrl});

  factory FilmSuggestion.fromJson(Map<String, dynamic> json) {
    return FilmSuggestion(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
} 