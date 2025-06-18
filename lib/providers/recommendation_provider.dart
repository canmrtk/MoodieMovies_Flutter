import 'package:flutter/material.dart';
import '../models/film.dart';
import '../services/api_service.dart';

class RecommendationProvider extends ChangeNotifier {
  static const int visibleCount = 20;
  List<Film> _all = [];
  List<Film> _visible = [];
  bool _loading = false;
  String? _error;

  List<Film> get visible => _visible;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetch() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final response = await ApiService.get('/recommendations');
    if (response.statusCode == 200) {
      _all = (response.data as List<dynamic>).map((e) => Film.fromJson(e)).toList();
      _visible = _all.take(visibleCount).toList();
    } else {
      _error = 'Öneriler alınamadı';
    }

    _loading = false;
    notifyListeners();
  }

  void markWatched(String filmId) {
    _visible.removeWhere((f) => f.id == filmId);
    if (_all.isNotEmpty) {
      final next = _all.firstWhere((f) => !_visible.contains(f) && f.id != filmId, orElse: () => Film(id: '', title: ''));
      if (next.id.isNotEmpty) {
        _visible.add(next);
      }
    }
    notifyListeners();
  }
} 