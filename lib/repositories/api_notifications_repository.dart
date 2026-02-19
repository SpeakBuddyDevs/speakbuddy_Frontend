import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../models/notification_model.dart';
import '../services/auth_service.dart';

/// Repositorio de notificaciones que consume la API REST
class ApiNotificationsRepository {
  final _authService = AuthService();

  /// Obtiene el número de notificaciones no leídas
  Future<int> getUnreadCount() async {
    final headers = await _authService.headersWithAuth();
    final response = await http.get(
      Uri.parse(ApiEndpoints.notificationsUnreadCount),
      headers: headers,
    );

    if (response.statusCode != 200) return 0;

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>?;
    final count = data?['count'];
    if (count is int) return count;
    if (count is num) return count.toInt();
    return 0;
  }

  /// Lista notificaciones con paginación
  Future<List<NotificationModel>> getNotifications({
    bool? unreadOnly,
    int page = 0,
    int size = 20,
  }) async {
    final headers = await _authService.headersWithAuth();
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (unreadOnly == true) 'unreadOnly': 'true',
    };
    final uri = Uri.parse(ApiEndpoints.notifications).replace(
      queryParameters: queryParams,
    );
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) return [];

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>?;
    final content = data?['content'] as List<dynamic>?;
    if (content == null) return [];

    return content
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Marca una notificación como leída
  Future<void> markAsRead(int id) async {
    final headers = await _authService.headersWithAuth();
    final response = await http.put(
      Uri.parse(ApiEndpoints.notificationMarkRead(id.toString())),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  /// Marca varias notificaciones como leídas
  Future<void> markAsReadIds(List<int> ids) async {
    if (ids.isEmpty) return;

    final headers = await _authService.headersWithAuth();
    headers['Content-Type'] = 'application/json';
    final response = await http.post(
      Uri.parse(ApiEndpoints.notificationsMarkRead),
      headers: headers,
      body: jsonEncode({'ids': ids}),
    );

    if (response.statusCode != 204) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
