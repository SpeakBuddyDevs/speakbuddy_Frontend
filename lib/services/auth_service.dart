import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../models/auth_result.dart';
import '../models/auth_error.dart';
import 'current_user_service.dart';
import 'stats_service.dart';
import 'websocket_chat_service.dart';


class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Token cacheado en memoria para evitar lecturas repetidas de SecureStorage.
  String? _cachedToken;

  Future<AuthResult> login(String email, String password) async {
    final url = Uri.parse(ApiEndpoints.login);

    try {
      final response = await http.post(
        url,
        headers: AppConstants.jsonHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final token = data['access_token'];

        _cachedToken = token;
        if (token != null) {
          await _storage.write(key: AppConstants.jwtTokenKey, value: token);
        }

        return AuthResult.success(token: token);
      } else {
        return AuthResult.failure(
          AuthError.fromResponse(response.statusCode, response.body),
        );
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
      return AuthResult.failure(NetworkError());
    }
  }

  /// Headers JSON + Authorization Bearer para peticiones autenticadas a /api/*
  Future<Map<String, String>> headersWithAuth() async {
    final token = await getToken();
    final headers = Map<String, String>.from(AppConstants.jsonHeaders);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;

    final token = await _storage.read(key: AppConstants.jwtTokenKey);
    if (token != null) {
      _cachedToken = token;
    }
    return token;
  }

  Future<void> logout() async {
    _cachedToken = null;
    await _storage.delete(key: AppConstants.jwtTokenKey);
    CurrentUserService().clearCache();
    StatsService().clearCache();
    WebSocketChatService().disconnect();
  }

  Future<AuthResult> register(
    String name,
    String email,
    String password,
    int nativeLangId,
    int learnLangId,
    String country,
  ) async {
    final parts = name.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : '';
    final surname = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final url = Uri.parse(ApiEndpoints.register);
    final body = jsonEncode({
      'name': firstName,
      'surname': surname,
      'email': email.trim(),
      'password': password,
      'nativeLanguageId': nativeLangId,
      if (learnLangId > 0) 'learningLanguageId': learnLangId,
      'country': country.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: AppConstants.jsonHeaders,
        body: body,
      );

      if (response.statusCode == 201) {
        return AuthResult.success();
      }

      return AuthResult.failure(
        AuthError.fromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      debugPrint("❌ Register error: $e");
      return AuthResult.failure(NetworkError());
    }
  }
}
