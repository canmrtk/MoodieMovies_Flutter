import 'package:flutter/material.dart';
import '../models/film_list_summary.dart';
import '../services/api_service.dart';

class UserListsProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<FilmListSummary> _lists = [];

  bool get loading => _loading;
  String? get error => _error;
  List<FilmListSummary> get lists => _lists;

  Future<void> fetchLists() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final response = await ApiService.get('/lists');
    if (response.statusCode == 200) {
      _lists = (response.data as List<dynamic>).map((e) => FilmListSummary.fromJson(e)).toList();
    } else {
      _error = 'Listeler alınamadı';
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> createList({required String name, String? tag, String? description, bool visible = true}) async {
    final body = {
      'name': name,
      if (tag != null) 'tag': tag,
      if (description != null) 'description': description,
      'visible': visible ? 1 : 0,
    };

    final response = await ApiService.post('/lists', body: body);
    if (response.statusCode == 201) {
      await fetchLists();
      return true;
    }
    return false;
  }

  Future<bool> addFilmToList(String listId, String filmId) async {
    final body = {'filmId': filmId};
    final response = await ApiService.post('/lists/$listId/films', body: body);
    return response.statusCode == 200 || response.statusCode == 201;
  }
} 