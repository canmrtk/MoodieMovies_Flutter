import 'film.dart';

class FilmListDetail {
  final String id;
  final String name;
  final String? description;
  final String tag;
  final int? visibility;
  final List<Film> films;

  FilmListDetail({required this.id, required this.name, this.description, required this.tag, this.visibility, required this.films});

  factory FilmListDetail.fromJson(Map<String, dynamic> json) {
    final List<dynamic> filmArr = json['films'] ?? [];
    return FilmListDetail(
      id: json['listId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      tag: json['tag'] ?? '',
      visibility: json['visibility'],
      films: filmArr.map((e) => Film.fromJson(e)).toList(),
    );
  }
} 