import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../models/generated_topic.dart';
import '../services/auth_service.dart';
import 'topic_repository.dart';

/// Implementación de TopicRepository que usa la API REST del backend.
///
/// BACKEND: Requiere los siguientes endpoints:
/// - POST /api/topics/generate - Genera un nuevo tema con IA
/// - GET /api/topics/favorites - Lista favoritos del usuario
/// - POST /api/topics/favorites - Guarda un tema como favorito
/// - DELETE /api/topics/favorites/{id} - Elimina un favorito
class ApiTopicRepository implements TopicRepository {
  final _authService = AuthService();

  @override
  Future<GeneratedTopic> generateTopic({
    required TopicCategory category,
    required String level,
    required String languageCode,
  }) async {
    final headers = await _authService.headersWithAuth();
    headers['Content-Type'] = 'application/json';

    final body = jsonEncode({
      'category': category.apiValue,
      'level': level,
      'languageCode': languageCode,
    });

    final response = await http.post(
      Uri.parse(ApiEndpoints.topicsGenerate),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return GeneratedTopic.fromJson(data);
  }

  @override
  Future<List<GeneratedTopic>> getFavorites() async {
    final headers = await _authService.headersWithAuth();

    final response = await http.get(
      Uri.parse(ApiEndpoints.topicsFavorites),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>?;
    if (list == null) return [];

    return list
        .map((e) => GeneratedTopic.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GeneratedTopic> addToFavorites(GeneratedTopic topic) async {
    final headers = await _authService.headersWithAuth();
    headers['Content-Type'] = 'application/json';

    final response = await http.post(
      Uri.parse(ApiEndpoints.topicsFavorites),
      headers: headers,
      body: jsonEncode(topic.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return GeneratedTopic.fromJson(data);
  }

  @override
  Future<void> removeFromFavorites(String topicId) async {
    final headers = await _authService.headersWithAuth();

    final response = await http.delete(
      Uri.parse(ApiEndpoints.topicFavorite(topicId)),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
