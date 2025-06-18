import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiResponse {
  final int statusCode;
  final dynamic data;
  ApiResponse(this.statusCode, this.data);
}

class ApiService {
  static Future<Map<String, String>> _defaultHeaders({Map<String, String>? extra}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final headers = <String, String>{'Accept': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  static Future<ApiResponse> get(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final response = await http.get(uri, headers: await _defaultHeaders(extra: headers));
    return _processResponse(response);
  }

  static Future<ApiResponse> post(String path, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final mergedHeaders = await _defaultHeaders(extra: headers);
    mergedHeaders['Content-Type'] = 'application/json';
    final response = await http.post(uri, headers: mergedHeaders, body: jsonEncode(body));
    return _processResponse(response);
  }

  static Future<ApiResponse> put(String path, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final mergedHeaders = await _defaultHeaders(extra: headers);
    mergedHeaders['Content-Type'] = 'application/json';
    final response = await http.put(uri, headers: mergedHeaders, body: jsonEncode(body));
    return _processResponse(response);
  }

  static Future<ApiResponse> delete(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final response = await http.delete(uri, headers: await _defaultHeaders(extra: headers));
    return _processResponse(response);
  }

  static ApiResponse _processResponse(http.Response response) {
    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = response.body;
    }
    return ApiResponse(response.statusCode, data);
  }
} 