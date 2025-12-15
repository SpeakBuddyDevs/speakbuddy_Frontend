import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../models/auth_result.dart';
import '../models/auth_error.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  // --- LOGIN ---
  Future<AuthResult> login(String email, String password) async {
    final url = Uri.parse(ApiEndpoints.login);
    
    try {
      final response = await http.post(
        url,
        headers: AppConstants.jsonHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['accessToken']; 

        // Guardamos el token en el almacenamiento seguro del móvil
        await _storage.write(key: AppConstants.jwtTokenKey, value: token);
        debugPrint("Login Exitoso. Token guardado.");
        return AuthResult.success(token: token);
      } else {
        debugPrint("Error Login: ${response.body}");
        return AuthResult.failure(
          AuthError.fromResponse(response.statusCode, response.body),
        );
      }
    } catch (e) {
      debugPrint("Error de conexión: $e");
      return AuthResult.failure(NetworkError());
    }
  }

  // --- REGISTER ---
  Future<AuthResult> register(String name, String email, String password, int nativeLangId, int learnLangId) async {
    final url = Uri.parse(ApiEndpoints.register);

    
    List<String> names = name.split(" ");
    String firstName = names[0];
    String lastName = names.length > 1 ? names.sublist(1).join(" ") : "";

    try {
      final response = await http.post(
        url,
        headers: AppConstants.jsonHeaders,
        body: jsonEncode({
          'name': firstName,
          'surname': lastName,
          'email': email,
          'password': password,
          'nativeLanguageId': nativeLangId,
          // El backend espera una lista o un ID para aprender. 
          // Ajusta esto según tu AddLearningLanguageDTO o RegisterDTO
          // Asumiremos que el backend acepta IDs simples por ahora en el registro
          // NOTA: Tu register actual en Java solo pedía nativeLanguageId.
          // El idioma a aprender se añade DESPUÉS en la HU 1.2.
          // Así que en el registro inicial solo mandamos el nativo.
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint("Registro Exitoso");
        return AuthResult.success();
      } else {
        debugPrint("Error Registro: ${response.body}");
        return AuthResult.failure(
          AuthError.fromResponse(response.statusCode, response.body),
        );
      }
    } catch (e) {
      debugPrint("Error de conexión: $e");
      return AuthResult.failure(NetworkError());
    }
  }

  // Método para obtener el token guardado 
  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.jwtTokenKey);
  }
  
  // Logout
  Future<void> logout() async {
    await _storage.delete(key: AppConstants.jwtTokenKey);
  }
}