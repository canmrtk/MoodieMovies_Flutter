import 'package:flutter/material.dart';
import '../models/film.dart';
import '../services/api_service.dart';

class FilmsCatalogProvider extends ChangeNotifier {
  int _currentPage = 0;
  bool _hasNext = true;
  bool _loading = false;
  List<Film> _films = [];
  String? _error;

  List<Film> get films => _films;
  bool get loading => _loading;
  bool get hasNext => _hasNext;
  String? get error => _error;

  Future<void> refresh() async {
    _currentPage = 0;
    _films.clear();
    _hasNext = true;
    await loadMore();
  }

  Future<void> loadMore() async {
    if (!_hasNext || _loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    final response = await ApiService.get('/films?page=$_currentPage&size=20');
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final List<dynamic> content = data['content'] ?? [];
      _films.addAll(content.map((e) => Film.fromJson(e)).toList());
      final bool last = data['last'] as bool? ?? true;
      _hasNext = !last;
      _currentPage++;
    } else {
      _error = 'Filmler alınamadı';
    }

    _loading = false;
    notifyListeners();
  }
} 