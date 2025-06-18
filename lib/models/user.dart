import 'package:flutter/foundation.dart';
import '../constants/constants.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? avatarImageUrl; // Backend'den gelen orijinal URL'i tutar
  final int ratingCount;
  final int favoriteCount;
  final int listCount;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarImageUrl,
    this.ratingCount = 0,
    this.favoriteCount = 0,
    this.listCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      avatarImageUrl: json['avatarImageUrl'], // Backend'den gelen URL'i direkt alıyoruz
      ratingCount: _toInt(json['ratingCount']),
      favoriteCount: _toInt(json['favoriteCount']),
      listCount: _toInt(json['listCount']),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  // === SORUNU ÇÖZEN AKILLI GETTER (TÜM DURUMLAR İÇİN) ===
  String? get fullAvatarUrl {
    if (avatarImageUrl == null || avatarImageUrl!.isEmpty) {
      return null;
    }
    
    String finalUrl = avatarImageUrl!;

    // 1. Gelen URL göreli bir yol mu? (örn: /api/v1/...)
    if (finalUrl.startsWith('/')) {
        // Geliştirme modunda ve Android'de miyiz?
        if (kDebugMode && defaultTargetPlatform == TargetPlatform.android) {
            // Emulatör için doğru base URL'i oluştur
            return 'http://10.0.2.2:8080$finalUrl'; 
        }
        // Diğer durumlar için (iOS, web, release) AppConstants'daki baseUrl'i kullan
        return '${AppConstants.baseUrl}$finalUrl';
    }
    
    // 2. Gelen URL tam bir URL mi? (örn: http://...)
    if (finalUrl.startsWith('http')) {
        // Geliştirme modunda ve Android'de miyiz?
        if (kDebugMode && defaultTargetPlatform == TargetPlatform.android) {
            // URL'deki host'u emulatörün anlayacağı şekilde değiştir
            return finalUrl.replaceFirst(RegExp(r'localhost|127.0.0.1|192.168.[\d.]+'), '10.0.2.2');
        }
    }

    // Yukarıdaki koşullara uymuyorsa, orijinal URL'i döndür
    return finalUrl;
  }
}