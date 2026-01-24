import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../models/user_profile.dart';
import '../models/language_item.dart';
import '../services/auth_service.dart';

class ApiUsersRepository {
  final _authService = AuthService();

  // Obtener mi perfil completo
  Future<UserProfile?> getMyProfile() async {
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return null;

      final url = Uri.parse(ApiEndpoints.me);

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return _mapJsonToProfile(data);
      }
      return null;
    } catch (e, stackTrace) {
      print('🔴 [Profile] Error: $e');
      print(stackTrace);
      return null;
    }
  }

  // Mapeador manual (Json -> UserProfile)
  UserProfile _mapJsonToProfile(Map<String, dynamic> json) {
    // Mapear la lista de idiomas
    List<LanguageItem> learningLangs = [];
    if (json['learningLanguages'] != null) {
      learningLangs = (json['learningLanguages'] as List).map((l) {
        return LanguageItem(
          code: l['code'] ?? 'EN',
          name: l['name'] ?? 'Inglés',
          level:
              l['level']?.toString().split(' - ')[0] ??
              'A1', // "A1 - Principiante" -> "A1"
          active: true, // Por defecto activos
        );
      }).toList();
    }

    return UserProfile(
      name: json['name'] ?? 'Usuario',
      email: json['email'] ?? '',
      level: json['level'] ?? 1,
      progressPct: (json['progressPct'] ?? 0.0).toDouble(),
      exchanges: json['exchanges'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      languagesCount: json['languagesCount'] ?? 0,
      hoursTotal: json['hoursTotal'] ?? 0,
      currentStreakDays: json['currentStreakDays'] ?? 0,
      bestStreakDays: json['bestStreakDays'] ?? 0,
      medals: json['medals'] ?? 0,
      learningLanguages: learningLangs,
      isPro: json['isPro'] ?? false,
      nativeLanguage: json['nativeLanguage'] ?? 'ES',
      description: json['description'] ?? '',
      avatarPath: null,
    );
  }
}
