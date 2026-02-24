import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';

/// Contexto de autenticación común a todos los repositorios API.
class AuthContext {
  AuthContext({
    required this.headers,
    required this.token,
  });

  final Map<String, String> headers;
  final String? token;

  bool get hasValidToken => token != null && token!.isNotEmpty;
}

/// Clase base para repositorios que llaman a la API HTTP autenticada.
///
/// Centraliza:
/// - Acceso a `AuthService`.
/// - Construcción de headers con Authorization.
/// - Helpers para decodificar respuestas JSON.
class BaseApiRepository {
  final AuthService _authService = AuthService();

  @protected
  AuthService get authService => _authService;

  /// Construye el contexto de autenticación (headers + token) para una llamada.
  ///
  /// - `extraHeaders` permite añadir cabeceras específicas (por ejemplo Content-Type).
  @protected
  Future<AuthContext> buildAuthContext({
    Map<String, String>? extraHeaders,
  }) async {
    final headers = await _authService.headersWithAuth();
    if (extraHeaders != null && extraHeaders.isNotEmpty) {
      headers.addAll(extraHeaders);
    }
    final token = await _authService.getToken();
    return AuthContext(headers: headers, token: token);
  }

  /// Decodifica el cuerpo de una respuesta HTTP como JSON usando utf8.
  @protected
  dynamic decodeJsonBody(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}

