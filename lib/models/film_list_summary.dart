import 'film.dart';

class FilmListSummary {
  final String id;
  final String name;
  final String tag;
  final int filmCount;
  final int? visibility;
  final List<Film> films; // preview films

  FilmListSummary({required this.id, required this.name, required this.tag, required this.filmCount, this.visibility, required this.films});

  factory FilmListSummary.fromJson(Map<String, dynamic> json) {
    final List<dynamic> filmArr = json['films'] ?? [];
    return FilmListSummary(
      id: json['listId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      tag: json['tag'] ?? '',
      filmCount: _toInt(json['filmCount']),
      visibility: json['visibility'],
      films: filmArr.map((e) => Film.fromJson(e)).toList(),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
} 