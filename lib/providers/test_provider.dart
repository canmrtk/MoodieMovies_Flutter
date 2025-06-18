import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../data/test_questions.dart';
import '../services/api_service.dart';

class TestProvider extends ChangeNotifier {
  Map<String, String> _answers = {};
  bool _submitting = false;
  String? _error;

  TestProvider() {
    _loadAnswersFromStorage();
  }

  bool get submitting => _submitting;
  String? get error => _error;
  int get total => testQuestions.length;
  int get answered => _answers.length;
  Map<String, String> get answers => _answers;

  List<Map<String, String>> get questions => testQuestions;

  Future<void> _loadAnswersFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? answersJson = prefs.getString('testAnswers');
    if (answersJson != null) {
      _answers = Map<String, String>.from(jsonDecode(answersJson));
      notifyListeners();
    }
  }

  Future<void> setAnswer(String qId, String ansId) async {
    _answers[qId] = ansId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('testAnswers', jsonEncode(_answers));
    notifyListeners();
  }

  /// Return the questions for a concrete page (1-indexed)
  List<Map<String, String>> pageQuestions(int page, int perPage) {
    final start = (page - 1) * perPage;
    if (start >= testQuestions.length) return [];
    final end = (start + perPage).clamp(0, testQuestions.length);
    return testQuestions.sublist(start, end);
  }

  /// Convert all stored answers into the payload format expected by the backend
  List<Map<String, String>> _getAllAnswersAsList() {
    return _answers.entries
        .map((e) => {"questionId": e.key, "answerId": e.value})
        .toList();
  }

  /// Submit the test to the backend.  Returns true on success.
  Future<bool> submit() async {
    // Ensure we have the latest answers from disk as well
    await _loadAnswersFromStorage();

    if (_answers.length < testQuestions.length) {
      _error = "Tüm sorular cevaplanmadı.";
      notifyListeners();
      return false;
    }

    _submitting = true;
    _error = null;
    notifyListeners();

    final payload = {"answers": _getAllAnswersAsList()};

    try {
      final response = await ApiService.post('/tests/submit', body: payload);

      if (response.statusCode == 200) {
        final resultData = response.data;
        final prefs = await SharedPreferences.getInstance();

        if (resultData != null &&
            resultData['scores'] != null &&
            (resultData['profile_id'] != null || resultData['profileId'] != null)) {
          final profileId = resultData['profile_id'] ?? resultData['profileId'];
          await prefs.setString('analysisScores', jsonEncode(resultData['scores']));
          await prefs.setString('analysisProfileId', profileId.toString());

          await clearAnswers();

          _submitting = false;
          notifyListeners();
          return true;
        } else {
          throw Exception("API yanıtı eksik veya hatalı formatta.");
        }
      } else {
        final errorData = response.data as Map<String, dynamic>?;
        final msg = errorData?['message'] ?? 'Bilinmeyen bir hata oluştu.';
        throw Exception(msg);
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _submitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> clearAnswers() async {
    _answers.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('testAnswers');
    notifyListeners();
  }
} 