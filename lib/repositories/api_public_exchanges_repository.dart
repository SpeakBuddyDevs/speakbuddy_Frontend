import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../constants/languages.dart';
import '../models/join_request.dart';
import '../models/public_exchange.dart';
import '../models/public_exchange_filters.dart';
import '../services/auth_service.dart';
import 'public_exchanges_repository.dart';

/// Implementación API: GET /api/exchanges/public con filtros y paginación.
class ApiPublicExchangesRepository implements PublicExchangesRepository {
  final _authService = AuthService();

  @override
  Future<List<PublicExchange>> searchExchanges({
    String query = '',
    PublicExchangeFilters? filters,
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      final headers = await _authService.headersWithAuth();

      String? nativeLang;
      String? targetLang;
      if (filters != null) {
        if (filters.nativeLanguage != null &&
            filters.nativeLanguage!.isNotEmpty) {
          nativeLang = AppLanguages.getCodeFromName(filters.nativeLanguage!) ??
              filters.nativeLanguage!.toLowerCase();
        }
        if (filters.targetLanguage != null &&
            filters.targetLanguage!.isNotEmpty) {
          targetLang = AppLanguages.getCodeFromName(filters.targetLanguage!) ??
              filters.targetLanguage!.toLowerCase();
        }
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (query.trim().isNotEmpty) 'q': query.trim(),
        if (filters?.requiredLevel != null &&
            filters!.requiredLevel!.isNotEmpty)
          'requiredLevel': filters.requiredLevel!,
        if (filters?.minDate != null)
          'minDate': _formatDate(filters!.minDate!),
        if (filters?.maxDuration != null && filters!.maxDuration! > 0)
          'maxDuration': filters.maxDuration.toString(),
        if (nativeLang != null) 'nativeLang': nativeLang,
        if (targetLang != null) 'targetLang': targetLang,
      };

      final uri =
          Uri.parse(ApiEndpoints.exchangesPublic).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final content = data['content'] as List?;
      if (content == null) return [];

      return content
          .map((e) => PublicExchange.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<PublicExchange> createExchange({
    required String title,
    required String description,
    required String nativeLanguage,
    required String targetLanguage,
    required int requiredLevelMinOrder,
    required int requiredLevelMaxOrder,
    required DateTime date,
    required int durationMinutes,
    required int maxParticipants,
    List<String>? topics,
    List<String>? platforms,
    required bool isPublic,
  }) async {
    final headers = await _authService.headersWithAuth();
    headers['Content-Type'] = 'application/json';

    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesión para crear un intercambio');
    }

    final nativeCode = AppLanguages.getCodeFromName(nativeLanguage) ??
        (nativeLanguage.length >= 2
            ? nativeLanguage.toLowerCase().substring(0, 2)
            : 'es');
    final targetCode = AppLanguages.getCodeFromName(targetLanguage) ??
        (targetLanguage.length >= 2
            ? targetLanguage.toLowerCase().substring(0, 2)
            : 'en');

    final body = {
      'scheduledAt': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'title': title.isNotEmpty ? title : 'Intercambio',
      'isPublic': isPublic,
      if (isPublic) 'maxParticipants': maxParticipants,
      if (description.isNotEmpty) 'description': description,
      if (isPublic) 'nativeLanguageCode': nativeCode,
      if (isPublic) 'targetLanguageCode': targetCode,
      if (isPublic) 'requiredLevelMinOrder': requiredLevelMinOrder,
      if (isPublic) 'requiredLevelMaxOrder': requiredLevelMaxOrder,
      if (topics != null && topics.isNotEmpty) 'topics': topics,
      if (platforms != null && platforms.isNotEmpty) 'platforms': platforms,
    };

    final response = await http.post(
      Uri.parse(ApiEndpoints.exchanges),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      final msg = _parseErrorMessage(response);
      throw Exception(msg);
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return _exchangeResponseToPublicExchange(
      data,
      description: description,
      nativeLanguage: nativeLanguage,
      targetLanguage: targetLanguage,
      maxParticipants: maxParticipants,
      topics: topics,
      platforms: platforms,
      isPublic: isPublic,
    );
  }

  PublicExchange _exchangeResponseToPublicExchange(
    Map<String, dynamic> json, {
    required String description,
    required String nativeLanguage,
    required String targetLanguage,
    required int maxParticipants,
    List<String>? topics,
    List<String>? platforms,
    required bool isPublic,
  }) {
    final participants = json['participants'] as List? ?? [];
    Map<String, dynamic>? creator;
    for (final p in participants) {
      final m = p as Map<String, dynamic>?;
      if (m != null && m['role'] == 'creator') {
        creator = m;
        break;
      }
    }

    final scheduledAt = json['scheduledAt'] as String?;
    final date = scheduledAt != null && scheduledAt.isNotEmpty
        ? DateTime.parse(scheduledAt)
        : DateTime.now();

    final requiredLevelLabel = (json['requiredLevel'] ?? 'A1 – C2').toString();
    final minLevel = (json['requiredLevelMinOrder'] is int)
        ? json['requiredLevelMinOrder'] as int
        : (json['minLevel'] is int) ? json['minLevel'] as int : 1;

    return PublicExchange(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'Intercambio').toString(),
      description: description,
      creatorId: (creator?['userId'] ?? '').toString(),
      creatorName: (creator?['username'] ?? '').toString(),
      creatorAvatarUrl: null,
      creatorIsPro: false,
      requiredLevel: requiredLevelLabel,
      minLevel: minLevel,
      date: date,
      durationMinutes: (json['durationMinutes'] is int)
          ? json['durationMinutes'] as int
          : 0,
      currentParticipants: participants.length,
      maxParticipants: maxParticipants,
      nativeLanguage: nativeLanguage,
      targetLanguage: targetLanguage,
      topics: topics?.isNotEmpty == true ? topics : null,
      platforms: platforms?.isNotEmpty == true ? platforms : null,
      isEligible: true,
      unmetRequirements: null,
      isJoined: true,
      isPublic: isPublic,
      shareLink: null,
    );
  }

  @override
  Future<void> joinExchange(String id) async {
    final headers = await _authService.headersWithAuth();
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesión para unirte a un intercambio');
    }

    final response = await http.post(
      Uri.parse(ApiEndpoints.exchangeJoin(id)),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final msg = _parseErrorMessage(response);
      throw Exception(msg);
    }
  }

  @override
  Future<void> leaveExchange(String id) async {
    final headers = await _authService.headersWithAuth();
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesión para abandonar un intercambio');
    }

    final response = await http.delete(
      Uri.parse(ApiEndpoints.exchangeLeave(id)),
      headers: headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      final msg = _parseErrorMessage(response);
      throw Exception(msg);
    }
  }

  /// Usuario no elegible solicita unirse. BACKEND: POST /api/exchanges/{id}/join-request
  Future<void> requestToJoin(String exchangeId) async {
    final headers = await _authService.headersWithAuth();
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesión para solicitar unirte');
    }

    final response = await http.post(
      Uri.parse(ApiEndpoints.exchangeJoinRequest(exchangeId)),
      headers: headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      final msg = _parseErrorMessage(response);
      throw Exception(msg);
    }
  }

  /// Lista solicitudes pendientes (solo creador). BACKEND: GET /api/exchanges/{id}/join-requests
  Future<List<JoinRequest>> getJoinRequests(String exchangeId) async {
    final headers = await _authService.headersWithAuth();
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesión para ver las solicitudes');
    }

    final response = await http.get(
      Uri.parse(ApiEndpoints.exchangeJoinRequests(exchangeId)),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final msg = _parseErrorMessage(response);
      throw Exception(msg);
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (data is! List) return [];
    return data.map<JoinRequest>((e) => JoinRequest.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  /// Aceptar solicitud (solo creador). BACKEND: POST .../join-requests/{requestId}/accept
  Future<void> acceptJoinRequest(String exchangeId, String requestId) async {
    final headers = await _authService.headersWithAuth();
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesión');
    }

    final response = await http.post(
      Uri.parse(ApiEndpoints.exchangeJoinRequestAccept(exchangeId, requestId)),
      headers: headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      final msg = _parseErrorMessage(response);
      throw Exception(msg);
    }
  }

  /// Rechazar solicitud (solo creador). BACKEND: POST .../join-requests/{requestId}/reject
  Future<void> rejectJoinRequest(String exchangeId, String requestId) async {
    final headers = await _authService.headersWithAuth();
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesión');
    }

    final response = await http.post(
      Uri.parse(ApiEndpoints.exchangeJoinRequestReject(exchangeId, requestId)),
      headers: headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      final msg = _parseErrorMessage(response);
      throw Exception(msg);
    }
  }

  String _parseErrorMessage(http.Response response) {
    try {
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>?;
      final message = data?['message'] as String?;
      if (message != null && message.isNotEmpty) return message;
    } catch (_) {}
    return 'Error ${response.statusCode}';
  }
}
