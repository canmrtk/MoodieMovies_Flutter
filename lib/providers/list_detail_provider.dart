import 'package:flutter/material.dart';
import '../models/film_list_detail.dart';
import '../services/api_service.dart';

class ListDetailProvider extends ChangeNotifier {
  FilmListDetail? _detail;
  bool _loading = false;
  String? _error;

  FilmListDetail? get detail => _detail;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchDetail(String listId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final response = await ApiService.get('/lists/$listId');
    if (response.statusCode == 200) {
      _detail = FilmListDetail.fromJson(response.data);
    } else {
      _error = 'Liste getirilemedi';
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> removeFilm(String listId, String filmId) async {
    final response = await ApiService.delete('/lists/$listId/films/$filmId');
    if (response.statusCode == 204) {
      await fetchDetail(listId);
    }
  }

  Future<bool> updateList(String listId, {String? name, String? tag, String? description, bool? visible}) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (tag != null) 'tag': tag,
      if (description != null) 'description': description,
      if (visible != null) 'visible': visible ? 1 : 0,
    };
    if (body.isEmpty) return false;
    final response = await ApiService.put('/lists/$listId', body: body);
    if (response.statusCode == 200) {
      await fetchDetail(listId);
      return true;
    }
    return false;
  }

  Future<bool> deleteList(String listId) async {
    final response = await ApiService.delete('/lists/$listId');
    return response.statusCode == 204;
  }
} 