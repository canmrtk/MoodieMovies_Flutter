import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  User? _currentUser;

  bool get isAuthenticated => _token != null;
  User? get currentUser => _currentUser;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      log('[Auth] Token loaded from storage.');
      await _fetchCurrentUser();
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    log('[Auth] Attempting to login with email: $email');
    try {
      final response = await ApiService.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['accessToken'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        _token = token;
        log('[Auth] Login successful. Token received.');
        await _fetchCurrentUser();
        notifyListeners();
        return true;
      } else {
        log('[Auth] Login failed. Status: ${response.statusCode}, Body: ${jsonEncode(response.data)}');
      }
    } catch (e) {
      log('[Auth] Login error.', error: e);
    }
    return false;
  }

  Future<bool> register({required String email, required String password, required String username}) async {
    log('[Auth] Attempting to register with email: $email');
    try {
      final response = await ApiService.post('/auth/register', body: {
        'email': email,
        'password': password,
        'username': username,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        log('[Auth] Registration successful.');
        // Backend'in cevabına göre ya direkt login yap ya da login sayfasına yönlendir
        if (response.data != null && response.data['accessToken'] != null) {
          final token = response.data['accessToken'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          _token = token;
          log('[Auth] Token received after registration.');
          await _fetchCurrentUser();
          notifyListeners();
        }
        return true;
      } else {
        log('[Auth] Registration failed. Status: ${response.statusCode}, Body: ${jsonEncode(response.data)}');
      }
    } catch (e) {
      log('[Auth] Registration error.', error: e);
    }
    return false;
  }

  Future<void> logout() async {
    log('[Auth] Logging out.');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> loginWithGoogle() async {
    log('[Auth] Attempting Google Sign-In.');
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      final account = await _googleSignIn.signIn();
      if (account == null) {
        log('[Auth] Google Sign-In cancelled by user.');
        return false;
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        log('[Auth] Google Sign-In failed to get idToken.');
        return false;
      }

      log('[Auth] Google idToken received, verifying with backend...');
      final response = await ApiService.post('/auth/google/verify', body: {'idToken': idToken});

      if (response.statusCode == 200 && response.data['accessToken'] != null) {
        final token = response.data['accessToken'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        _token = token;
        log('[Auth] Google Sign-In successful. Token received from backend.');
        await _fetchCurrentUser();
        notifyListeners();
        return true;
      } else {
        log('[Auth] Google Sign-In backend verification failed. Status: ${response.statusCode}, Body: ${jsonEncode(response.data)}');
      }
    } catch (e) {
      log('[Auth] Google Sign-In error.', error: e);
    }
    return false;
  }

  String? get token => _token;

  Future<void> _fetchCurrentUser() async {
    log('[Auth] Fetching current user details...');
    final response = await ApiService.get('/users/me');
    if (response.statusCode == 200) {
      _currentUser = User.fromJson(response.data);
      log('[Auth] Current user loaded: ${_currentUser!.name}');
      notifyListeners();
    } else {
      log('[Auth] Failed to fetch current user. Status: ${response.statusCode}');
    }
  }
} 