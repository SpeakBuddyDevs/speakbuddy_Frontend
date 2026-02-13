import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../models/joined_exchange.dart';
import '../services/auth_service.dart';

/// Repositorio para crear y confirmar intercambios.
/// POST /api/exchanges, GET /api/exchanges/{id}, POST /api/exchanges/{id}/confirm
class ApiExchangeRepository {
  final _authService = AuthService();

  Future<JoinedExchange?> create({
    required DateTime scheduledAt,
    required int durationMinutes,
    String? title,
    List<int>? participantUserIds,
  }) async {
    try {
      final headers = await _authService.headersWithAuth();
      headers['Content-Type'] = 'application/json';

      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return null;

      final body = {
        'scheduledAt': scheduledAt.toIso8601String(),
        'durationMinutes': durationMinutes,
        if (title != null && title.isNotEmpty) 'title': title,
        if (participantUserIds != null && participantUserIds.isNotEmpty)
          'participantUserIds': participantUserIds,
      };

      final response = await http.post(
        Uri.parse(ApiEndpoints.exchanges),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
      return JoinedExchange.fromJson(data);
    } catch (e, st) {
      print('🔴 [Exchange] create error: $e');
      print(st);
      rethrow;
    }
  }

  Future<JoinedExchange?> getById(String exchangeId) async {
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return null;

      final response = await http.get(
        Uri.parse(ApiEndpoints.exchangeDetail(exchangeId)),
        headers: headers,
      );

      if (response.statusCode != 200) return null;

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return JoinedExchange.fromJson(data);
    } catch (e, st) {
      print('🔴 [Exchange] getById error: $e');
      print(st);
      rethrow;
    }
  }

  Future<JoinedExchange?> confirm(String exchangeId) async {
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return null;

      final response = await http.post(
        Uri.parse(ApiEndpoints.exchangeConfirm(exchangeId)),
        headers: headers,
      );

      if (response.statusCode != 200) return null;

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return JoinedExchange.fromJson(data);
    } catch (e, st) {
      print('🔴 [Exchange] confirm error: $e');
      print(st);
      rethrow;
    }
  }
}
