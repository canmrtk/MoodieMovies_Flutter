import 'package:flutter/material.dart';
import '../data/test_questions.dart';
import '../data/answer_options.dart';
import '../services/api_service.dart';

class TestProvider extends ChangeNotifier {
  Map<String,String> _answers = {}; // questionId -> answerId
  bool _submitting = false;
  String? _error;
  bool get submitting => _submitting;
  String? get error => _error;
  int get total => testQuestions.length;
  int get answered => _answers.length;
  Map<String,String> get answers => _answers;

  List<Map<String,String>> get questions => testQuestions;

  void setAnswer(String qId, String ansId){
    _answers[qId]=ansId;
    notifyListeners();
  }

  List<Map<String,String>> pageQuestions(int page,int perPage){
    final start=(page-1)*perPage;
    final end=(start+perPage).clamp(0, testQuestions.length);
    return testQuestions.sublist(start,end);
  }

  Future<bool> submit() async{
    if(_answers.length<testQuestions.length) return false;
    _submitting=true; _error=null; notifyListeners();
    final payload={
      'answers': _answers.entries.map((e)=>{'questionId':e.key,'answerId':e.value}).toList()
    };
    final resp=await ApiService.post('/tests/submit',body:payload);
    _submitting=false;
    if(resp.statusCode==200){
      return true;
    }else{
      _error='Gönderim hatası';
      notifyListeners();
      return false;
    }
  }
} 