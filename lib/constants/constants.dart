import 'package:flutter/material.dart';

class AppConstants {
  static const String baseUrl = 'http://192.168.68.102:8080/api/v1'; // Local LAN backend URL

  // Colors (derived from React app)
  static const int backgroundColor = 0xFF1E1F26;
  static const int primaryGreen = 0xFF1D6A31;
  static const int accentBlue = 0xFF60A5FA;
  static const int cardGrey = 0xFF4A4B4E;

  static const double cardRadius = 16.0;
  static const List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
} 