import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../models/user_stats.dart';
import '../services/auth_service.dart';

/// Repositorio para obtener estadísticas del usuario autenticado.
///
/// GET /api/users/me/stats
class StatsRepository {
  final AuthService _authService = AuthService();

  Future<UserStats> getUserStats() async {
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        return const UserStats.zero();
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.userStats),
        headers: headers,
      );

      if (response.statusCode != 200) {
        return const UserStats.zero();
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map<String, dynamic>) {
        return const UserStats.zero();
      }

      return UserStats.fromJson(data);
    } catch (e, st) {
      // Para diagnóstico en desarrollo
      // ignore: avoid_print
      print('🔴 [StatsRepository] Error: $e');
      // ignore: avoid_print
      print(st);
      return const UserStats.zero();
    }
  }
}

