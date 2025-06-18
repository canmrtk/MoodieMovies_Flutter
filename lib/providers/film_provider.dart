import 'package:flutter/material.dart';
import '../models/film.dart';
import '../services/api_service.dart';

class FilmProvider extends ChangeNotifier {
  bool _loading = false;
  List<Film> _films = [];
  String? _error;

  bool get loading => _loading;
  List<Film> get films => _films;
  String? get error => _error;

  Future<void> fetchPopular() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final response = await ApiService.get('/films/popular/favorites');
    if (response.statusCode == 200) {
      final List<dynamic> list = response.data is List ? response.data : [];
      _films = list.map((e) => Film.fromJson(e)).toList();
    } else {
      _error = 'Filmler alınamadı';
    }

    _loading = false;
    notifyListeners();
  }
} 