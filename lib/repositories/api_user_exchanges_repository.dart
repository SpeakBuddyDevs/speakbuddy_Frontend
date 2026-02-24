import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../models/joined_exchange.dart';
import 'base_api_repository.dart';
import 'user_exchanges_repository.dart';

/// Implementación API: GET /api/exchanges/joined
class ApiUserExchangesRepository extends BaseApiRepository
    implements UserExchangesRepository {

  @override
  Future<List<JoinedExchange>> getJoinedExchanges() async {
    try {
      final auth = await buildAuthContext();
      if (!auth.hasValidToken) return [];

      final response = await http.get(
        Uri.parse(ApiEndpoints.exchangesJoined),
        headers: auth.headers,
      );

      if (response.statusCode != 200) return [];

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final list = data is List ? data : (data['content'] ?? data);
      if (list is! List) return [];

      return list
          .map((e) => JoinedExchange.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      print('🔴 [UserExchanges] Error: $e');
      print(st);
      rethrow;
    }
  }
}
