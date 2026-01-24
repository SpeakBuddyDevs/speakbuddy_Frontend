import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../models/auth_result.dart';
import '../models/auth_error.dart';

// --- VARIABLE GLOBAL (A prueba de fallos de instancia) ---
String? globalAccessToken;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

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

        // --- DIAGNÓSTICO: Imprimimos el JSON crudo ---
        debugPrint("📦 JSON Recibido del Back: $data");

        // Intentamos obtener el token
        final token = data['access_token'];

        // --- DIAGNÓSTICO: ¿Qué vale el token? ---
        debugPrint("🔑 Valor del token extraído: '$token'");

        // Guardamos en la variable global
        globalAccessToken = token;

        // Guardamos en disco
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
    // 1. Mirar variable global
    if (globalAccessToken != null) {
      debugPrint("💎 Token recuperado de variable GLOBAL.");
      return globalAccessToken;
    }

    // 2. Mirar disco
    debugPrint("⚠️ Variable global vacía. Leyendo disco...");
    String? token = await _storage.read(key: AppConstants.jwtTokenKey);

    if (token != null) {
      globalAccessToken = token; // Restaurar global
      debugPrint("💾 Token recuperado del disco.");
    } else {
      debugPrint("💀 Token NO encontrado en disco.");
    }

    return token;
  }

  Future<void> logout() async {
    globalAccessToken = null;
    await _storage.delete(key: AppConstants.jwtTokenKey);
  }

  Future<AuthResult> register(
    String name,
    String email,
    String password,
    int nativeLangId,
    int learnLangId,
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
