import '../constants/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Film {
  final String id;
  final String title;
  final String? posterUrl;
  final double? rating;

  Film({required this.id, required this.title, this.posterUrl, this.rating});

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      posterUrl: json['imageUrl'] ?? json['posterUrl'] ?? json['poster_url'],
      rating: _toDouble(json['rating'] ?? json['voteAverage'] ?? json['vote_average']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  // Tam URL döndüren yardımcı getter
  String? get fullPosterUrl {
    if (posterUrl == null || posterUrl!.isEmpty) return null;
    if (posterUrl!.startsWith('http')) {
      if (kDebugMode && defaultTargetPlatform == TargetPlatform.android) {
        try {
          final uri = Uri.parse(posterUrl!);
          if (uri.host == 'localhost' || uri.host == '127.0.0.1' || uri.host.startsWith('192.168.')) {
            return uri.replace(host: '10.0.2.2').toString();
          }
        } catch (_) {}
      }
      return posterUrl;
    }
    return '${AppConstants.baseUrl}$posterUrl';
  }
} 