import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../models/achievement.dart';
import '../services/auth_service.dart';
import 'achievements_repository.dart';

class ApiAchievementsRepository implements AchievementsRepository {
  final _authService = AuthService();

  @override
  Future<List<Achievement>> getAchievements() async {
    try {
      final headers = await _authService.headersWithAuth();
      final response = await http.get(
        Uri.parse(ApiEndpoints.achievements),
        headers: headers,
      );

      if (response.statusCode != 200) {
        print('🔴 [Achievements] Error ${response.statusCode}: ${response.body}');
        return [];
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>?;
      if (data == null) return [];

      return data
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      print('🔴 [Achievements] Error: $e\n$st');
      return [];
    }
  }

  @override
  Future<List<Achievement>> getUnlockedAchievements() async {
    final all = await getAchievements();
    return all.where((a) => a.isUnlocked).toList();
  }

  @override
  Future<List<Achievement>> getLockedAchievements() async {
    final all = await getAchievements();
    return all.where((a) => !a.isUnlocked).toList();
  }

  @override
  Future<void> updateProgress(String achievementId, int newProgress) async {
    // El progreso se actualiza desde el backend automáticamente
    // Este método podría implementarse si se necesita actualización manual
  }
}
