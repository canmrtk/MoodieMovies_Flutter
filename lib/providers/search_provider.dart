import 'package:flutter/material.dart';
import '../models/film_suggestion.dart';
import '../services/api_service.dart';

class SearchProvider extends ChangeNotifier {
  List<FilmSuggestion> _suggestions = [];
  bool _loading = false;

  List<FilmSuggestion> get suggestions => _suggestions;
  bool get loading => _loading;

  Future<void> fetchSuggestions(String query) async {
    if (query.isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    final response = await ApiService.get('/films/suggestions?query=${Uri.encodeQueryComponent(query)}');
    if (response.statusCode == 200) {
      final list = response.data as List<dynamic>;
      _suggestions = list.map((e) => FilmSuggestion.fromJson(e)).toList();
    }
    _loading = false;
    notifyListeners();
  }
} 